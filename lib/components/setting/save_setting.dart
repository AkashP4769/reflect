import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/user_service.dart';

class EncryptionSetting extends StatefulWidget {
  final ThemeData themeData;
  final String encryptionMode;
  final void Function() refreshPage;
  const EncryptionSetting({super.key, required this.themeData, required this.encryptionMode, required this.refreshPage});


  @override
  State<EncryptionSetting> createState() => _EncryptionSettingState();
}

class _EncryptionSettingState extends State<EncryptionSetting> {
  final UserService userService = UserService();
  late String selectedSave;
  final servers = {
    'Local': 'local',
    'Cloud Encrypted': 'encrypted',
    'Cloud Unencrypted': 'unencrypted'
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSave = widget.encryptionMode;
  }

  void changeServer(String value) async {
    final result = await showDialog(
      context: context, 
      builder: (BuildContext context){
        print("Selected server2: $value");
        return AlertDialog(
          title: Text("Change server"),
          content: Text(value == 'local' ? "This will change savepoint to your device" : "This will enable realtime sync with cloud"),
          actions: [
            TextButton(onPressed: (){Navigator.pop(context, false);}, child: Text("Cancel")),
            TextButton(onPressed: () async {
              
              Navigator.pop(context, true);
            }, child: Text("Proceed")),
          ],
        );
      }
    );

    if(result == true) {
      selectedSave = value;
      await userService.updateEncryptionMode(value!);
      widget.refreshPage();
    }
  }

  void importAll() async {
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Row(
            children: [
              Text("Import All", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary),),
              SizedBox(width: 10,),
              Icon(Icons.download_rounded, color: widget.themeData.colorScheme.primary, size: 20),
            ],
          ),
          content: Text("This will replace your local entries with cloud. Are you sure you want to proceed?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(onPressed: () async {
              final status = await ChapterService().importAll();
              if(status) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imported successfully")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Import failed")));
              }
              Navigator.pop(context);
            }, child: Text("Proceed")),
          ],
        );
      }
    );
  }

  void exportAll() async {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text("Export All", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary),),
              SizedBox(width: 10,),
              Icon(Icons.upload_rounded, color: widget.themeData.colorScheme.primary, size: 20),
            ],
          ),
          content: Text("This will replace your local entries to the cloud. Are you sure you want to proceed?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(onPressed: () async {
              final status = await ChapterService().exportAll();
              if(status) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exported successfully")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export failed")));
              }
              Navigator.pop(context);
            }, child: Text("Proceed")),
          ],
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    print("Encryption mode: ${widget.encryptionMode}");
    final initialValue = widget.encryptionMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingContainer(
          themeData: widget.themeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Save Location", style: widget.themeData.textTheme.titleMedium),
              SizedBox(height: 10),
              Text("Local doesnt require internet connection.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
              SizedBox(height: 20),
              Theme(
                data: widget.themeData,
                child: DropdownMenu<String?>(
                  label: Text('Save Location', style: widget.themeData.textTheme.titleSmall),
                  initialSelection: selectedSave,
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(widget.themeData.colorScheme.surface),
                  ),
                  textStyle: widget.themeData.textTheme.bodyMedium,
          
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: servers['Local'],
                      label:  'Local',
                    ),
                    DropdownMenuEntry(
                      value: servers['Cloud Unencrypted'],
                      label:  'Cloud Unencrypted'
                    ),
                    DropdownMenuEntry(
                      enabled: false,
                      value: servers['Cloud Encrypted'],
                      label:  'Cloud Encrypted (coming soon)'
                    ),
                  ],
                  onSelected: (String? value) async {
                    changeServer(value!);
                  },
                ),
              ),
              SizedBox(height: 10),
              if(widget.encryptionMode == 'local') Text("It's recommended to import/export before changing save location to cloud.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: Colors.redAccent.withOpacity(0.8))),
            ],
          )
        ),
        
        SizedBox(height: 20),
        SettingContainer(
          themeData: widget.themeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Import/Export Data", style: widget.themeData.textTheme.titleMedium),
              SizedBox(height: 10),
              Text("Export will replace your local entries to the cloud. Import will copy your cloud entries to your local device.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: importAll, child: Text("Import All", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),))),
                  SizedBox(width: 20),
                  Expanded(child: ElevatedButton(onPressed: exportAll, child: Text("Export All", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),))),
                ],
              )
            ],
          ),
        ),
        
      ],
    );
  }
}