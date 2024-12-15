import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';

class EncryptionSetting extends StatefulWidget {
  final ThemeData themeData;
  const EncryptionSetting({super.key, required this.themeData});

  @override
  State<EncryptionSetting> createState() => _EncryptionSettingState();
}

class _EncryptionSettingState extends State<EncryptionSetting> {


  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      themeData: widget.themeData,
      child: Row(
        children: [
          Text("Encryption", style: widget.themeData.textTheme.titleMedium),
          //Switch(value: value, onChanged: onChanged)
        ],
      ),
    );
  }
}