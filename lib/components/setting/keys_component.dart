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
  //Map<String, Map<String, String>> rsaKeys = {'privateKey': {'exponent':'null', 'modulus':'null'}, 'publicKey': {'exponent':'null', 'modulus':'null'}};
  Uint8List? symmetricKey = Uint8List(0);
  String data = "my name is awesome";
  Map<String, dynamic> nestedData = {
    'name': 'My cool name',
    'age': 20,
    'address': {
      'street': '1234',
      'city': 'lagos',
      'state': 'lagos'
    }
  };
  String nestedEnc = 'null';

  bool toggleEncryption = true;
  bool toggleNestedEnc = true;
  final encryptionService = EncryptionService();


  void getKeys() async {
    //final keyPair = encryptionService.generateSymmetricKey("abcd");
    symmetricKey = (await encryptionService.getSymmetricKey()); //keyPair['key']!;
    setState(() {});
  }

  void encryptData() async {
    if(symmetricKey == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Generate symmetric key first")));
      return;
    }
    data = await encryptionService.encryptData(data, symmetricKey!);
    toggleEncryption = !toggleEncryption;
    setState(() {});
  }

  void decryptData() async {
    if(symmetricKey == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Generate symmetric key first")));
      return;
    }
    data = await encryptionService.decryptData(data, symmetricKey!);
    toggleEncryption = !toggleEncryption;
    setState(() {});
  }

  void encryptNestedData() {
    if(symmetricKey == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Generate symmetric key first")));
      return;
    }
    nestedEnc = encryptionService.encryptNestedData(nestedData, symmetricKey!);
    nestedData = {};
    toggleNestedEnc = !toggleNestedEnc;
    setState(() {});
  }

  void decryptNestedData() {
    if(symmetricKey == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Generate symmetric key first")));
      return;
    }
    nestedData = encryptionService.decryptNestedData(nestedEnc, symmetricKey!);
    nestedEnc = 'null';
    toggleNestedEnc = !toggleNestedEnc;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      themeData: widget.themeData,
      child: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: getKeys, child: Text("Generate Symmetric Key", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),)),
            //ElevatedButton(onPressed: (){toggleEncryption == false ? encryptSymKey() : decryptSymKey();}, child: Text("Encrypt/Decrypt", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),)),
            SizedBox(height: 20),
            Text("Symmetric key: ${base64Encode(symmetricKey ?? [])}"),
            //Text("Private key: \nexponent ${rsaKeys['privateKey']!['exponent']}\nmodulus ${rsaKeys['privateKey']!['modulus']}"),
            //Text("Public key: \nexponent ${rsaKeys['publicKey']!['exponent']}\nmodulus ${rsaKeys['publicKey']!['modulus']}"),

            SizedBox(height: 20),
            ElevatedButton(onPressed: toggleEncryption == true ? encryptData : decryptData, child: Text("Encrypt/Decrypt Data", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),)),
            Text(data),

            SizedBox(height: 20),
            ElevatedButton(onPressed: toggleNestedEnc == true ? encryptNestedData : decryptNestedData, child: Text("Encrypt/Decrypt Nested Data", style: TextStyle(color: widget.themeData.colorScheme.onPrimary),)),
            Text(jsonEncode(nestedData)),
            Text(nestedEnc),

          ],
        ),
      ),
    );
  }
}