import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BackendServices {
  String baseUrl =  'http://192.168.29.226:3000/api';  //'http://192.168.18.105:3000/api';
  User? user = FirebaseAuth.instance.currentUser;

  BackendServices(){
    final settingBox = Hive.box('settings');
    final String? url = settingBox.get('baseUrl');
    if(url != null) baseUrl = url;
  }
}