import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/setting/device_setting.dart';
import 'package:reflect/components/setting/keys_component.dart';
import 'package:reflect/components/setting/server_setting.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/services/user_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<SettingsPage> {
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
                ServerSetting(ref: ref,),
                const SizedBox(height: 20),
                //ElevatedButton(onPressed: getDevices, child: Text('Get Devices', style: themeData.textTheme.titleSmall)),
                //const SizedBox(height: 20),
                DeviceSetting(ref: ref),
                KeyComponent(themeData: themeData)
              ],
            ),
            Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.3.0" , style: themeData.textTheme.titleSmall))
          ],
        ),
      ),
    );
  }
}