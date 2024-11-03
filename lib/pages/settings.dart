import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/main.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<SettingsPage> {
  final settingBox = Hive.box('settings');
  late String selectedServer;
  final servers = {
    'Localhost': 'http://192.168.29.226:3000/api',
    'Vercel': 'https://reflect-server.vercel.app/api',
    'AWS': 'http://13.233.167.195:3000/api'
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final String server = settingBox.get('baseUrl', defaultValue: 'http://13.233.167.195:3000/api');
    selectedServer = server;
    setState(() {});
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
          Column(
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
            ],
          ),
          Padding(padding: EdgeInsets.all(20), child: Text("Current Version: 1.2.1" , style: themeData.textTheme.titleSmall))
        ],
      ),
    );
  }
}