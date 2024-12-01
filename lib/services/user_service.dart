import 'dart:convert';

import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/encryption_service.dart';

class UserService extends BackendServices {
  Future<Map<String, dynamic>> addUser(String uid, String name, String email) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/'), body: jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'deviceId': await EncryptionService.getDeviceID()
      }), headers: {'Content-Type': 'application/json'});

      print(response.body);
      if([0, 2, 3, 5].contains(jsonDecode(response.body)['code'])){
        final device = await EncryptionService.createDeviceDetails();
        final response = await http.post(Uri.parse('$baseUrl/users/updateDevice'), body: jsonEncode({'uid':uid, "device":device.toMap()}), headers: {'Content-Type': 'application/json'});
        print(response.body);
        //return jsonDecode(response.body);
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print("Error at addUser(): $e");
      return {'code': -1, 'message': 'Error: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getUserDevice() async {
    try{
      List<Map<String, dynamic>> devices = [];
      final response = await http.get(Uri.parse('$baseUrl/users/devices/${user!.uid}'));
      final deviceData = jsonDecode(response.body)['devices'] as List;
      return List<Map<String, dynamic>>.from(deviceData.map((device) => Map<String, dynamic>.from(device)).toList());
    } catch(e){
      print("Error at getUserDevice(): $e");
      return [{}];
    }
  }
}