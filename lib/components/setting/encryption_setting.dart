import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';
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

  }

  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      themeData: widget.themeData,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Save Location", style: widget.themeData.textTheme.titleMedium),
          /*Switch(
            value: (widget.encryptionMode == 'unencrypted') ? false : true,
            activeColor: widget.themeData.colorScheme.primary,
            inactiveThumbColor: widget.themeData.colorScheme.secondary, 
            onChanged: (bool value) async {
              await userService.updateEncryptionMode(value ? 'encrypted' : 'unencrypted');
              widget.refreshPage();
            }
          )*/
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
          )
        ],
      ),
    );
  }
}