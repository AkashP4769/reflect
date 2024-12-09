import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/setting/setting_container.dart';

class KeyComponent extends StatefulWidget {
  final ThemeData themeData;
  const KeyComponent({super.key, required this.themeData});

  @override
  State<KeyComponent> createState() => _KeyComponentState();
}

class _KeyComponentState extends State<KeyComponent> {
  late String privateKey; 
  late String publicKey;

  void getKeys(){}

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
            Text("Private key: $privateKey"),
            Text("Public key: $publicKey"),
          ],
        ),
      ),
    );
  }
}