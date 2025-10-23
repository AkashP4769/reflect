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
    final columnCount = MediaQuery.of(context).size.width < 640 ? 1 : 2;
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
      //SizedBox(width: 20, height: 20,),
      EncryptionSetting(themeData: themeData, encryptionMode: userSetting.encryptionMode, refreshPage: getUserSetting),
      
      if(userSetting.encryptionMode != 'local') ServerSetting(ref: ref,),
      
      if(userSetting.encryptionMode != 'local') DeviceSetting(ref: ref, devices: [userSetting.primaryDevice, ...userSetting.devices], refreshPage: getUserSetting, encryptionMode: userSetting.encryptionMode),
    ];

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Settings', style: themeData.textTheme.titleLarge),

            columnCount == 1 ? Wrap(
              spacing: 20,
              runSpacing: 20,
              children: settingWidgets,
              //children: settingWidgets,
            ) : 
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    spacing: 20,
                    children: [settingWidgets[0], settingWidgets[2], if (settingWidgets.length > 3) settingWidgets[3]],
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    spacing: 20,
                    children: [settingWidgets[1],],
                  ),
                )
              ]
            ),
            Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.9.3:31" , style: themeData.textTheme.titleSmall))
          ],
        ),
      ),
    );
  }
}