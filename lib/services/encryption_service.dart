import 'dart:convert'; // For JSON serialization/deserialization
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:conduit_password_hash/pbkdf2.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:reflect/models/device.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:device_info_plus/device_info_plus.dart';


// Encryption Function
class EncryptionService {
  static Future<String> getDeviceID() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial ?? 'Unknown';
    } on PlatformException {
      identifier = 'Unknown';
    }
    //return identifier;
    return '12345';
  }

  static Future<Device> createDeviceDetails() async {
    String deviceName = '';
    String deviceType = '';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      // Check if the platform is Android
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model ?? 'Unknown Android Device';
        deviceType = 'Android';
      } 
      // Check if the platform is iOS
      else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name ?? 'Unknown iOS Device';
        deviceType = 'iOS';
      } 
      // Handle other platforms (if needed)
      else {
        deviceName = 'Unknown Device';
        deviceType = 'Unknown Platform';
      }
    } catch (e) {
      print('Error fetching device details: $e');
    }


    //Device device = Device(deviceId: await getDeviceID(), deviceName: deviceName, deviceType: deviceType, publicKey: 'q23421', encryptedKey: '124123');
    final device = Device(deviceId: "12345", deviceName: "new device", deviceType: deviceType, publicKey: 'q23421', encryptedKey: '');
    return device;
  }

  Uint8List generateSymmetricKey() {
    final random = Random.secure();
    // Generate a list of 32 random bytes (256-bit key)
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return Uint8List.fromList(keyBytes);
  }

  Uint8List deriveKey(String password, String salt) {
    final pbkdf2 = new PBKDF2();
    final key = pbkdf2.generateKey(password, salt, 10000, 32); // 256-bit key
    return Uint8List.fromList(key);
  }

  void encryptData(Map<String, dynamic> nestedMap, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Convert the nested map to a JSON string
    final jsonString = jsonEncode(nestedMap);

    // Encrypt the JSON string
    final encryptedData = encrypter.encrypt(jsonString, iv: iv);
    print(encryptedData.base64); // Store this encrypted data in the backend
  }

  // Decryption Function
  void decryptData(String encryptedData, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Decrypt the encrypted string
    final decryptedData = encrypter.decrypt64(encryptedData, iv: iv);

    // Convert the decrypted string back into a nested map
    final nestedMap = jsonDecode(decryptedData) as Map<String, dynamic>;
    print(nestedMap); // Display the nested map to the user
  }
}
