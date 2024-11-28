import 'dart:convert';

import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/encryption_service.dart';

class UserService extends BackendServices {
  Future<void> addUser(String uid, String name, String email) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/'), body: jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'deviceId': await EncryptionService.getDeviceID()
      }), headers: {'Content-Type': 'application/json'});

      print(response.body);
      //if response has status 'new user created' save the symmetric key

      //else if response has status 'user already exists in different device' fetch the symmetric key
    } catch (e) {
      print("Error at addUser(): $e");
    }
  }
}