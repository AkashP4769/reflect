import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/main.dart';

class ServerSetting extends StatefulWidget {
  final WidgetRef ref;
  const ServerSetting({super.key, required this.ref});

  @override
  State<ServerSetting> createState() => _ServerSettingState();
}

class _ServerSettingState extends State<ServerSetting> {
  final settingBox = Hive.box('settings');
  late String selectedServer;
  final servers = {
    'Localhost (Kv)': /*'http://192.168.29.226:3000/api'*/ /*'http://192.168.18.239:3000/api'*/ "http://192.168.18.105:3000/api",
    'Localhost (Jio)': 'http://192.168.29.226:3000/api',
    'Vercel': 'https://reflect-server.vercel.app/api',
    'AWS': 'http://3.109.5.25:3000/api',
    'Railway': 'https://reflect-backend-production-646a.up.railway.app/api',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getServer();
  }

  void getServer(){
    final String server = settingBox.get('baseUrl', defaultValue: /*'http://13.233.167.195:3000/api'*/ 'http://192.168.18.105:3000/api');
    selectedServer = server;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.ref.watch(themeManagerProvider);
    return SettingContainer(
      maxHeight: 100,
      themeData: themeData,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Server', style: themeData.textTheme.titleMedium!.copyWith(color: themeData.colorScheme.primary)),
          const SizedBox(height: 10),
          Theme(
            data: themeData,
            child: DropdownButtonFormField<String?>(
              value: selectedServer,
              style: themeData.textTheme.bodyMedium,
              
              items: servers.entries.map((server) {
                return DropdownMenuItem<String>(
                  value: server.value,
                  child: Text(server.key),
                );
              }).toList(),
              onChanged: (String? value) async {
                await settingBox.put('baseUrl', value);
              },
            ),
          )
        ],
      ),
    );
  }
}