import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';
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
    await ChapterService().importAll();
  }

  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      themeData: widget.themeData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Save Location", style: widget.themeData.textTheme.titleMedium),
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
                  value: servers['Cloud Encrypted'],
                  label:  'Cloud Encrypted'
                ),
                DropdownMenuEntry(
                  value: servers['Cloud Unencrypted'],
                  label:  'Cloud Unencrypted'
                ),
              ],
              onSelected: (String? value) async {
                await userService.updateEncryptionMode(value!);
                widget.refreshPage();
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: importAll, child: Text("Import All", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),))),
            ],
          )
        ],
      ),
    );
  }
}