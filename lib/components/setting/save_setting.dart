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
    'local': 'Local',
    'unencrypted': 'Cloud',
    'encrypted': 'Cloud Encrypted',
  };

  late TextEditingController controller;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSave = widget.encryptionMode;
    controller = TextEditingController(text: widget.encryptionMode);
  }

  Future<void> _showConfirmationDialog(String newValue) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('Are you sure you want to select "${servers[newValue]}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await userService.updateEncryptionMode(newValue);
      widget.refreshPage();
      selectedSave = newValue;
      setState(() {});
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
              Text("• Save Location", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary)),
              SizedBox(height: 10),
              Text("Cloud syncs your entries realtime\nLocal doesnt require internet connection.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
              SizedBox(height: 10),
              Theme(
                data: widget.themeData,
                child: DropdownButtonFormField<String>(
                  value: selectedSave,
                  style: widget.themeData.textTheme.bodyMedium,
                  items: servers.entries.map((server) {
                    return DropdownMenuItem<String>(
                      value: server.key,
                      child: Text(server.value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _showConfirmationDialog(newValue);
                    }
                  },
                )
            
              ),
              SizedBox(height: 10),
              if(widget.encryptionMode == 'local') Text("It's recommended to import/export before changing save location to cloud.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: Colors.redAccent.withOpacity(0.8))),
              //Theme(data: widget.themeData, child: DropdownWithConfirmation())
            ],
          )
        ),
        
        SizedBox(height: 20),
        SettingContainer(
          themeData: widget.themeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Import/Export Data", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary)),
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

class DropdownWithConfirmation extends StatefulWidget {
  const DropdownWithConfirmation({super.key});

  @override
  State<DropdownWithConfirmation> createState() => _DropdownWithConfirmationState();
}

class _DropdownWithConfirmationState extends State<DropdownWithConfirmation> {
  String? currentValue = 'Option 1';
  final List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  Future<void> _showConfirmationDialog(String newValue) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('Are you sure you want to select "$newValue"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        currentValue = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentValue,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _showConfirmationDialog(newValue);
        }
      },
    );
  }
}