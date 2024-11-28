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
      if([0, 2, 3].contains(jsonDecode(response.body)['message']['code'])){
        // transmit full device info
        final device = await EncryptionService.createDeviceDetails();
        final response = await http.post(Uri.parse('$baseUrl/users/updateDevice'), body: jsonEncode({'uid':uid, "device":device.toMap()}), headers: {'Content-Type': 'application/json'});
        print(response.body);
      }
    } catch (e) {
      print("Error at addUser(): $e");
    }
  }
}