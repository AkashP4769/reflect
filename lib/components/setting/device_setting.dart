import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/services/user_service.dart';

class DeviceSetting extends StatefulWidget {
  final WidgetRef ref;
  const DeviceSetting({super.key, required this.ref});

  @override
  State<DeviceSetting> createState() => _DeviceSettingState();
}

class _DeviceSettingState extends State<DeviceSetting> {
  final UserService userService = UserService();
  
  List<Device> devices = [];
  List<Device> newDevice = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDevices();
  }

  void getDevices() async {
    final _devices = await userService.getUserDevice();
    devices.clear();
    newDevice.clear();
    for(var device in _devices){
      if(["", null].contains(device.encryptedKey)) newDevice.add(device);
      else devices.add(device);
    }

    setState(() {});
    print(devices);
  }

  void handleNewDevice(String deviceId, bool choice) async {
    await userService.handleNewDevice(deviceId, choice);
    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.ref.watch(themeManagerProvider);
    return SettingContainer(
      themeData: themeData,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Devices", style: themeData.textTheme.titleMedium),
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Device ${devices[index].deviceName}', style: themeData.textTheme.bodyMedium),
                subtitle: Text('Platform: ${devices[index].deviceType}', style: themeData.textTheme.bodySmall),
                trailing: index == 0 ? IconButton(icon: Icon(Icons.star, color: themeData.colorScheme.primary), onPressed: null,) : null
              );
            },
          ),
          const SizedBox(height: 20),
          if(newDevice.isNotEmpty) Text("New Devices Login", style: themeData.textTheme.titleMedium),
          if(newDevice.isNotEmpty) ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: newDevice.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Device ${newDevice[index].deviceName}', style: themeData.textTheme.bodyMedium),
                subtitle: Text('Platform: ${newDevice[index].deviceType}', style: themeData.textTheme.bodySmall),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(icon: Icon(Icons.close, color: themeData.colorScheme.error), onPressed: (){handleNewDevice(newDevice[index].deviceId, false);}),
                      IconButton(icon: Icon(Icons.check, color: themeData.colorScheme.primary, weight: 40, fill: 0.8,), onPressed: (){handleNewDevice(newDevice[index].deviceId, true);}),
                    ],
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