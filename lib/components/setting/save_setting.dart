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

  void importAll() async {
    final status = await ChapterService().importAll();
    if(status) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imported successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Import failed")));
    }
  }

  void exportAll() async {
    final status = await ChapterService().exportAll();
    if(status) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exported successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  initialSelection: widget.encryptionMode,
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
                    //show dialog box to confirm
                    

                    await userService.updateEncryptionMode(value!);
                    widget.refreshPage();
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
              Text("Import will save your local entries to the cloud. Export will save your cloud entries to your local device.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
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