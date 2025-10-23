import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BackendServices {
  String baseUrl = 'http://3.109.5.25:3000/api' /*"https://reflect-backend-production-646a.up.railway.app/api"*/  /*'http://13.233.167.195:3000/api'*/  /*'http://192.168.29.226:3000/api'*/ /*'http://192.168.18.239:3000/api'*/ /*"http://192.168.18.105:3000/api"*/;
  User? user = FirebaseAuth.instance.currentUser;
  final settingBox = Hive.box('settings');

  BackendServices(){
    final String? url = settingBox.get('baseUrl', defaultValue: 'http://3.109.5.25:3000/api');
    if(url != null) baseUrl = url;
  }
}