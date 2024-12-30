import 'dart:convert';

import 'package:reflect/models/device.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/encryption_service.dart';

class UserService extends BackendServices {
  Future<Map<String, dynamic>> addUser(String uid, String name, String email) async {
    final encryptionService = EncryptionService();
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/'), body: jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'deviceId': await EncryptionService.getDeviceID()
      }), headers: {'Content-Type': 'application/json'});

      final body = jsonDecode(response.body);
      
      /*if(body['code'] == 0){
        //encryptionService.generateAndSaveSymmetricKey();
      }

      else if(body['code'] == 4){
        String symKey = await encryptionService.decryptSymKey(body['encryptedKey']);
        encryptionService.saveSymmetricKey(symKey);
      }*/

      if([0, 2, 3, 5].contains(body['code'])){
        final createSymKey = body['code'] == 0 ? true : false;
        final device = await encryptionService.createDeviceDetails(createSymKey);
        await http.post(Uri.parse('$baseUrl/users/updateDevice'), body: jsonEncode({'uid':uid, "device":device.toMap()}), headers: {'Content-Type': 'application/json'});
      }

      await getUserSetting();

      return body;
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

  Future<void> handleNewDevice(String deviceId, bool choice, Map<String, String> publicKey) async {
    try{
      String encryptedKey = await EncryptionService().encryptSymKey(publicKey);
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

  Future<String?> updateEncryptionMode(String encryptionMode) async {
    try{
      print("setting encryption mode to: $encryptionMode");
      final response = await http.post(Uri.parse('$baseUrl/users/encryptionMode'),
        body: jsonEncode({
          "uid": user!.uid,
          "encryptionMode": encryptionMode
        }), headers:  {'Content-Type': 'application/json'}
      );

      if(response.statusCode == 200){
        final userSetting = jsonDecode(settingBox.get('${user!.uid}#userSetting'));
        print("new encryption mode: ${jsonDecode(response.body)}");

        if(userSetting != null) userSetting['encryptionMode'] = encryptionMode;

        await settingBox.put('${user!.uid}#userSetting', jsonEncode(userSetting));
        return jsonDecode(response.body)['encryptionMode'];
      }
      return null;
    } catch(e) {
      print("error at updateEncryptionMode: $e");
      return null;
    }
  }

  Future<UserSetting> getUserSetting() async {
    try{
      UserSetting? oldSetting = UserSetting.fromMap(jsonDecode(settingBox.get('${user!.uid}#userSetting')));
      final response = await http.get(Uri.parse('$baseUrl/users/settings/${user!.uid}'),);
      print(jsonDecode(response.body));
      
      final UserSetting userSetting = UserSetting.fromMap(jsonDecode(response.body));
      if(oldSetting == null) userSetting.encryptionMode = 'unencrypted';

      await settingBox.put('${user!.uid}#userSetting', jsonEncode(userSetting.toMap()));
      return userSetting;
    } catch(e){
      print("Error at getUserSetting(): $e");
      return UserSetting(uid: '', name: '', email: '', primaryDevice: Device(deviceId: '', deviceName: '', deviceType: '', publicKey: {}, encryptedKey: ''), devices: [], encryptionMode: '');
    }
  }

  UserSetting getUserSettingFromCache() {
    final userSetting = settingBox.get('${user!.uid}#userSetting');
    if(userSetting == null) {
      final Device primaryDevice = Device(deviceId: '', deviceName: '', deviceType: '', publicKey: {}, encryptedKey: '');
      return UserSetting(uid: user!.uid, name: user!.displayName ?? 'Reflexy', email: "unkown", primaryDevice: primaryDevice, devices: [], encryptionMode: 'unencrypted');
    }
    return UserSetting.fromMap(jsonDecode(userSetting));
  }
  
}