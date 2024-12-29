import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:reflect/components/setting/device_setting.dart';
import 'package:reflect/components/setting/save_setting.dart';
import 'package:reflect/components/setting/keys_component.dart';
import 'package:reflect/components/setting/server_setting.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/user_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<SettingsPage> {
  UserService userService = UserService();
  UserSetting userSetting = UserService().getUserSettingFromCache();

  void getUserSetting() async {
    if(userSetting == null || userSetting!.encryptionMode != 'local'){
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
    getUserSetting();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      //height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Settings', style: themeData.textTheme.titleLarge),

                const SizedBox(height: 20),
                if(userSetting != null) EncryptionSetting(themeData: themeData, encryptionMode: userSetting!.encryptionMode, refreshPage: getUserSetting),
                
                const SizedBox(height: 20),
                if(userSetting != null && userSetting!.encryptionMode != 'local') ServerSetting(ref: ref,),
                
                const SizedBox(height: 20),
                if(userSetting != null && userSetting!.encryptionMode != 'local') DeviceSetting(ref: ref, devices: [userSetting!.primaryDevice, ...userSetting!.devices], refreshPage: getUserSetting, encryptionMode: userSetting!.encryptionMode),
                
                const SizedBox(height: 20),
                if(userSetting != null /*&& userSetting!.encryptionMode == 'encrypted'*/) KeyComponent(themeData: themeData)
              ],
            ),
            Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.4.3.13" , style: themeData.textTheme.titleSmall))
          ],
        ),
      ),
    );
  }
}