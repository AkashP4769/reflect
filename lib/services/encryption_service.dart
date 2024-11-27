import 'dart:convert'; // For JSON serialization/deserialization
import 'dart:typed_data';
import 'package:conduit_password_hash/pbkdf2.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:unique_identifier/unique_identifier.dart';

// Encryption Function
class EncryptionService {
  static Future<String> getDeviceID() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial ?? 'Unknown';
    } on PlatformException {
      identifier = 'Unknown';
    }
    return identifier;
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
