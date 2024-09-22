import 'package:firebase_auth/firebase_auth.dart';

class BackendServices {
  final String baseUrl =  'http://192.168.29.226:3000/api';  //'http://192.168.18.105:3000/api';
  final User? user = FirebaseAuth.instance.currentUser;
}