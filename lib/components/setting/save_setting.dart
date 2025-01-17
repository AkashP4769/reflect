import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/components/signup/signup_passfield.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/chapter_service.dart';
import 'package:reflect/services/encryption_service.dart';
import 'package:reflect/services/user_service.dart';

class EncryptionSetting extends StatefulWidget {
  final ThemeData themeData;
  final String encryptionMode;
  final void Function(bool explicit) refreshPage;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSave = widget.encryptionMode;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showConfirmationDialog(String newValue, ThemeData themeData) async {
    final symKey = await EncryptionService().getSymmetricKey();
    if(newValue == 'encrypted' && symKey == null) {
      final bool everEncrypted = await userService.everEncrypted();
      if(everEncrypted) {
        await _showValidatePasswordDialog(themeData, userService.getUserSettingFromCache());
        return;
      }
      else {
        //create new password
        final String? _password = await getPasswordDialog();
        if(_password != null){
          await userService.generateKeyAndUploadSalt(_password);
        }
        return;
      }
    }

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
      widget.refreshPage(true);
      selectedSave = newValue;
      setState(() {});
    }
  }

  Future<void> _showValidatePasswordDialog(ThemeData themeData, UserSetting userSetting) async {
    
    await showDialog<bool>(
      context: context, 
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            final TextEditingController passwordController = TextEditingController();
            bool isValid = false;
            String errorMsg = '';

            void validate(){
              final password = passwordController.text;
              if(password.isEmpty){
                errorMsg = 'Password cannot be empty';
                setState(() {});
                return;
              }
              
              try{
                if(EncryptionService().validateSymmetricKey(password, userSetting.salt ?? '', userSetting.keyValidator ?? '')){
                  isValid = true;
                  errorMsg = '';
                  setState(() {});
                }
                else{
                  errorMsg = 'Invalid password';
                  setState(() {});
                }
              } catch(e){
                errorMsg = 'Invalid password';
                setState(() {});
              }
            }
            return AlertDialog(
              //title: Text("Enter your password", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(isValid ? "Password Validated" :'Enter your password', style: themeData.textTheme.titleLarge!.copyWith(color: themeData.colorScheme.primary), textAlign: TextAlign.center,),
                    const SizedBox(height: 20,),
                    if(!isValid) const Text('This password refers to the one you created while you enabled encryption', textAlign: TextAlign.center,),
                    if(!isValid) const SizedBox(height: 20,),
                    if(!isValid) SignUpPassField(text: "Password", controller: passwordController, themeData: themeData,),
                    
                    if(errorMsg != '') Row(
                      children: [
                        const Icon(Icons.error, color: Colors.redAccent, size: 16,),
                        const SizedBox(width: 5,),
                        Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: "Poppins", fontWeight: FontWeight.w400),)
                      ],
                    ),
                    const SizedBox(height: 20,),
                    if(!isValid) Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(themeData.colorScheme.tertiary),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }, 
                            child: Text('Go back', style: themeData.textTheme.bodyMedium,),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: validate, 
                            child: Text('Validate', style: themeData.textTheme.bodyMedium,),
                          ),
                        ),
                      ],
                    ),

                    if(isValid) Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 28,),
                        const SizedBox(width: 5,),
                        Expanded(child: Text("Your password is validated. You can now re-login", style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.left,)),
                      ],
                    ),
                    if(isValid) const SizedBox(height: 20,),
                    if(isValid) ElevatedButton(
                      onPressed: () {
                        AuthService.signOut();
                      },
                      child: Text('Re-login', style: themeData.textTheme.bodyMedium,),
                    ),
                  ],
                ),
              ),
              /*actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Proceed")),
              ],*/
            );
          }
        );
      }
    );
  }

  Future<String?> getPasswordDialog() async {
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    String errorText = '';

    bool validatePassword() {
      if(_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
        errorText = "Password cannot be empty";
        return false;
      }

      if(_passwordController.text != _confirmPasswordController.text) {
        errorText = "Passwords do not match";
        return false;
      }

      if(_passwordController.text.length < 6) {
        errorText = "Password must be at least 8 characters";
        return false;
      }

      return true;
    }

    final res = await showDialog<bool>(
      context: context, 
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (context, setState){
            void onSubmit(){
              if(validatePassword()){
                print("Password: ${_passwordController.text}");
                Navigator.pop(context, true);
              }
              else {
                print("Error: $errorText" + "setstate page");
                setState(() {});
              }
            }
            
            return AlertDialog(
            title: Text("Create a password to encrypted your data", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("This password has to be used next time if you were to login in new device", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
                    const SizedBox(height: 15),
                    SignUpPassField(text: "Password", controller: _passwordController, themeData: widget.themeData),
                    const SizedBox(height: 10),
                    SignUpPassField(text: "Confirm Password", controller: _confirmPasswordController, themeData: widget.themeData),
                    const SizedBox(height: 10),
                    if(errorText.isNotEmpty) Row(
                      children: [
                        Icon(Icons.error, color: Colors.redAccent.withOpacity(0.8), size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(errorText, style: widget.themeData.textTheme.bodyMedium!.copyWith(color: Colors.redAccent.withOpacity(0.8)))),
                      ],
                    ),
                    if(errorText.isNotEmpty) const SizedBox(height: 10),
                    if(errorText.isNotEmpty) Divider(color: widget.themeData.colorScheme.onPrimary),
                    if(errorText.isNotEmpty) const SizedBox(height: 10),
                    Text("Warning: If you forget this password, you won't be able to recover your entries.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: Colors.redAccent.withOpacity(0.8))),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => onSubmit(), child: const Text("Proceed")),
            ],
            );
          }
        );
      } 
    );
    
    if(res ?? false){
      return _passwordController.text;
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
              const SizedBox(width: 10,),
              Icon(Icons.download_rounded, color: widget.themeData.colorScheme.primary, size: 20),
            ],
          ),
          content: const Text("This will replace your local entries with cloud. Are you sure you want to proceed?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: () async {
              final status = await ChapterService().importAll();
              if(status) {
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Imported successfully")));
              } else {
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Import failed")));
              }
              Navigator.pop(context);
            }, child: const Text("Proceed")),
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
              const SizedBox(width: 10,),
              Icon(Icons.upload_rounded, color: widget.themeData.colorScheme.primary, size: 20),
            ],
          ),
          content: const Text("This will replace your local entries to the cloud. Are you sure you want to proceed?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: () async {
              final status = await ChapterService().exportAll();
              if(status) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exported successfully")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Export failed")));
              }
              Navigator.pop(context);
            }, child: const Text("Proceed")),
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
              const SizedBox(height: 10),
              Text("Cloud syncs your entries realtime\nLocal doesnt require internet connection.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
              const SizedBox(height: 10),
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      print("New value: $newValue");
                      _showConfirmationDialog(newValue, widget.themeData);
                    }
                  },
                )
            
              ),
              const SizedBox(height: 10),
              if(widget.encryptionMode == 'local') Text("It's recommended to import/export before changing save location to cloud.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: Colors.redAccent.withOpacity(0.8))),
              //Theme(data: widget.themeData, child: DropdownWithConfirmation())
            ],
          )
        ),
        
        const SizedBox(height: 20),
        SettingContainer(
          themeData: widget.themeData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Import/Export Data", style: widget.themeData.textTheme.titleMedium!.copyWith(color: widget.themeData.colorScheme.primary)),
              const SizedBox(height: 10),
              Text("Export will replace your local entries to the cloud. Import will copy your cloud entries to your local device.", style: widget.themeData.textTheme.bodyMedium!.copyWith(color: widget.themeData.colorScheme.onPrimary.withOpacity(0.8))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: importAll, child: Text("Import All", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),))),
                  const SizedBox(width: 20),
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