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
    'Localhost': /*'http://192.168.29.226:3000/api'*/ 'http://192.168.18.239:3000/api',
    'Vercel': 'https://reflect-server.vercel.app/api',
    'AWS': 'http://13.233.167.195:3000/api'
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final String server = settingBox.get('baseUrl', defaultValue: 'http://13.233.167.195:3000/api' /*'http://192.168.18.239:3000/api'*/);
    selectedServer = server;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.ref.watch(themeManagerProvider);
    return SettingContainer(
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