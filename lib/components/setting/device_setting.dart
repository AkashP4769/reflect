import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/services/encryption_service.dart';
import 'package:reflect/services/user_service.dart';

class DeviceSetting extends StatefulWidget {
  final WidgetRef ref;
  final List<Device> devices;
  final void Function(bool explicit) refreshPage;
  final String encryptionMode;
  const DeviceSetting({super.key, required this.ref, required this.devices, required this.refreshPage, required this.encryptionMode});

  @override
  State<DeviceSetting> createState() => _DeviceSettingState();
}

class _DeviceSettingState extends State<DeviceSetting> {
  final UserService userService = UserService();
  
  void handleNewDevice(String deviceId, bool choice, Map<String, String> publicKey) async {
    await userService.handleNewDevice(deviceId, choice, publicKey);
    widget.refreshPage(true);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.ref.watch(themeManagerProvider);

    List<Device> devices = [];
    List<Device> newDevices = [];
    
    final _devices = widget.devices;
    devices.clear();
    newDevices.clear();
    for(var device in _devices){
      if(["", null].contains(device.encryptedKey) && widget.encryptionMode == 'encrypted'){newDevices.add(device); /*newDevices.add(device); newDevices.add(device);*/}
      else devices.add(device);
    }

    return SettingContainer(
      //maxHeight: 400,
      themeData: themeData,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.centerLeft, child: Text("• Devices", style: themeData.textTheme.titleMedium!.copyWith(color:themeData.colorScheme.primary))),
          ListView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            //physics: ScrollPhysics(),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: themeData.colorScheme.secondaryContainer
                ),
                child: ListTile(
                  leading: Icon(devices[index].deviceType == 'Android' ? Icons.android : (devices[index].deviceType == "Apple" ? Icons.apple : Icons.phone) , color: themeData.colorScheme.onPrimary),
                  contentPadding: EdgeInsets.zero,
                  title: Text('${devices[index].deviceName}', style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${devices[index].deviceType}', style: themeData.textTheme.bodySmall),
                  trailing: index == 0 ? IconButton(icon: Icon(Icons.star, color: themeData.colorScheme.primary), onPressed: null,) : IconButton(icon: Icon(Icons.logout_outlined, color: themeData.colorScheme.error), onPressed: (){handleNewDevice(devices[index].deviceId, false, devices[index].publicKey);}),
                ),
              );
            },
          ),
          if(newDevices.isNotEmpty) const SizedBox(height: 20),
          if(newDevices.isNotEmpty) Align(alignment: Alignment.centerLeft, child: Text("• New Devices Login", style: themeData.textTheme.titleMedium)),
          if(newDevices.isNotEmpty) ListView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: newDevices.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: themeData.colorScheme.secondaryContainer
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(newDevices[index].deviceType == 'Android' ? Icons.android : (newDevices[index].deviceType == "Apple" ? Icons.apple : Icons.phone) , color: themeData.colorScheme.onPrimary),
                  title: Text('${newDevices[index].deviceName}', style: themeData.textTheme.bodyMedium),
                  subtitle: Text('${newDevices[index].deviceType}', style: themeData.textTheme.bodySmall),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(icon: Icon(Icons.close, color: themeData.colorScheme.error), onPressed: (){handleNewDevice(newDevices[index].deviceId, false, newDevices[index].publicKey);}),
                        IconButton(icon: Icon(Icons.check, color: themeData.colorScheme.primary, weight: 40, fill: 0.8,), onPressed: (){handleNewDevice(newDevices[index].deviceId, true, newDevices[index].publicKey);}),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}