import 'dart:convert';

import 'package:reflect/models/device.dart';
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

      if(jsonDecode(response.body)['code'] == 0){
        EncryptionService().generateAndSaveSymmetricKey();
      }

      if([0, 2, 3, 5].contains(jsonDecode(response.body)['code'])){
        final device = await EncryptionService().createDeviceDetails();
        print(device.toMap());
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

  Future<List<Device>> getUserDevice() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/users/devices/${user!.uid}'));
      final deviceData = jsonDecode(response.body)['devices'] as List;
      return deviceData.map((device) => Device.fromMap(device)).toList();
    } catch(e){
      print("Error at getUserDevice(): $e");
      return [];
    }
  }

  Future<void> handleNewDevice(String deviceId, bool choice) async {
    try{
      String encryptedKey = '123';
      final response = await http.post(Uri.parse('$baseUrl/users/devices/handleNew'),
        body: jsonEncode({
          "uid": user!.uid,
          "deviceId":deviceId,
          "choice": choice,
          "encryptedKey": encryptedKey
        }), headers:  {'Content-Type': 'application/json'}
      );

      print(response.body);
    } catch(e) {
      print("error at handleNewDevice: $e");
    }
  }



  //add two numbers
  
}