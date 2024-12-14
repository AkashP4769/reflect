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
  Map<String, Map<String, String>> rsaKeys = {'privateKey': {'exponent':'null', 'modulus':'null'}, 'publicKey': {'exponent':'null', 'modulus':'null'}};
  String? symmetricKey;
  final encryptionService = EncryptionService();

  void getKeys() async {
    //encryptionService.generateAndSaveSymmetricKey();
    final sk = await encryptionService.getSymmetricKey();
    //get string from Uint8List
    if(sk != null) symmetricKey = base64Encode(sk);
    else symmetricKey = "null";

    rsaKeys = await encryptionService.getRSAKeys();
    //rsaKeys = encryptionService.generateSaveAndReturnRSAKeys();
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
            Text("Private key: \nexponent ${rsaKeys['privateKey']!['exponent']}\nmodulus ${rsaKeys['privateKey']!['modulus']}"),
            Text("Public key: \nexponent ${rsaKeys['publicKey']!['exponent']}\nmodulus ${rsaKeys['publicKey']!['modulus']}"),
          ],
        ),
      ),
    );
  }
}