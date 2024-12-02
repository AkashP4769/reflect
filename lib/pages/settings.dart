import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/main.dart';
import 'package:reflect/models/device.dart';
import 'package:reflect/services/user_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<SettingsPage> {
  final UserService userService = UserService();
  final settingBox = Hive.box('settings');
  late String selectedServer;
  final servers = {
    'Localhost': 'http://192.168.29.226:3000/api',
    'Vercel': 'https://reflect-server.vercel.app/api',
    'AWS': 'http://13.233.167.195:3000/api'
  };

  List<Device> devices = [];
  List<Device> newDevice = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final String server = settingBox.get('baseUrl', defaultValue: 'http://13.233.167.195:3000/api');
    selectedServer = server;
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
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Settings', style: themeData.textTheme.titleLarge),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color:  Color.fromARGB(64, 0, 0, 0),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 6), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Server', style: themeData.textTheme.titleMedium),
                      const SizedBox(height: 20),
                      Theme(
                        data: themeData,
                        child: DropdownMenu<String?>(
                          label: Text('Server', style: themeData.textTheme.titleSmall),
                          initialSelection: selectedServer,
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(themeData.colorScheme.surface),
                          ),
                          textStyle: themeData.textTheme.bodyMedium,
                          
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: servers['Localhost'],
                              label:  'Localhost',
                            ),
                            DropdownMenuEntry(
                              value: servers['Vercel'],
                              label:  'Vercel'
                            ),
                            DropdownMenuEntry(
                              value: servers['AWS'],
                              label:  'AWS'
                            ),
                          ],
                          onSelected: (String? value) {
                            settingBox.put('baseUrl', value);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //ElevatedButton(onPressed: getDevices, child: Text('Get Devices', style: themeData.textTheme.titleSmall)),
                //const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color:  Color.fromARGB(64, 0, 0, 0),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 6), // changes position of shadow
                      ),
                    ],
                  ),
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
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.2.2" , style: themeData.textTheme.titleSmall))
        ],
      ),
    );
  }
}