import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:reflect/components/setting/device_setting.dart';
import 'package:reflect/components/setting/save_setting.dart';
import 'package:reflect/components/setting/keys_component.dart';
import 'package:reflect/components/setting/server_setting.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/services/user_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<SettingsPage> {
  UserService userService = UserService();
  UserSetting userSetting = UserService().getUserSettingFromCache();

  void getUserSetting(bool explicit) async {
    if(userSetting.encryptionMode != 'local' || explicit){
      userSetting = await userService.getUserSetting();
    }

    if(mounted) setState(() {});
    //print(userSetting.toString());
    print("refreshing pge");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserSetting(false);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final columnCount = max(1, (MediaQuery.of(context).size.width / 400).floor());
    final settingWidgets = [
      SettingContainer(
        themeData: themeData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("• Your Account", style: themeData.textTheme.titleMedium!.copyWith(color:themeData.colorScheme.primary)),
            const SizedBox(height: 10),
            Text("Name: ${userSetting.name}", style: themeData.textTheme.bodyMedium),
            Text("Email: ${userSetting.email}", style: themeData.textTheme.bodyMedium),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                AuthService.signOut();
              },
              child: Text('Logout', style: themeData.textTheme.bodyMedium,),
            ),
          ],
        ), 
      ),
  
      EncryptionSetting(themeData: themeData, encryptionMode: userSetting.encryptionMode, refreshPage: getUserSetting),
      
      if(userSetting.encryptionMode != 'local') ServerSetting(ref: ref,),
      
      if(userSetting.encryptionMode != 'local') DeviceSetting(ref: ref, devices: [userSetting.primaryDevice, ...userSetting.devices], refreshPage: getUserSetting, encryptionMode: userSetting.encryptionMode),
    ];

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.secondaryContainer]
        )
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Settings', style: themeData.textTheme.titleLarge),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                childAspectRatio: 1.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: settingWidgets.length,
              itemBuilder: (BuildContext context, int index) => settingWidgets[index],
            ),
            /*Wrap(
              spacing: 20,
              runSpacing: 20,
              children: settingWidgets.map((widget) => SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: widget,
              )).toList(),
              //children: settingWidgets,
            ),*/
            Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.8.0:27" , style: themeData.textTheme.titleSmall))
          ],
        ),
      ),
    );
  }
}