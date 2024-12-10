import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';
import 'package:reflect/services/encryption_service.dart';

class KeyComponent extends StatefulWidget {
  final ThemeData themeData;
  const KeyComponent({super.key, required this.themeData});

  @override
  State<KeyComponent> createState() => _KeyComponentState();
}

class _KeyComponentState extends State<KeyComponent> {
  late String privateKey; 
  late String publicKey;
  String? symmetricKey;
  final encryptionService = EncryptionService();

  void getKeys() async {
    privateKey = "123";
    publicKey = "456";
    //encryptionService.generateAndSaveSymmetricKey();
    final sk = await encryptionService.getSymmetricKey();
    //get string from Uint8List
    if(sk != null) symmetricKey = base64Encode(sk);
    else symmetricKey = "null";

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKeys();
  }

  
  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      themeData: widget.themeData,
      child: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: getKeys, child: Text("get keys")),
            Text("Symmetric key: $symmetricKey"),
            Text("Private key: $privateKey"),
            Text("Public key: ${publicKey}"),
          ],
        ),
      ),
    );
  }
}