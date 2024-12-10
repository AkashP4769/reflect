import 'dart:convert'; // For JSON serialization/deserialization
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:reflect/models/device.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:device_info_plus/device_info_plus.dart';


// Encryption Function
class EncryptionService {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  static Future<String> getDeviceID() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial ?? 'Unknown';
    } on PlatformException {
      identifier = 'Unknown';
    }
    return identifier;
    return '44444';
  }

  static Future<Device> createDeviceDetails() async {
    String deviceName = '';
    String deviceType = '';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      // Check if the platform is Android
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.manufacturer + ' ' + androidInfo.brand;
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


    Device device = Device(deviceId: await getDeviceID(), deviceName: deviceName, deviceType: deviceType, publicKey: 'q23421', encryptedKey: '124123');
    //final device = Device(deviceId: "44444", deviceName: "IPhone 14", deviceType: "Android", publicKey: 'adfsads', encryptedKey: '');
    return device;
  }

  static Uint8List generateSymmetricKey() {
    final random = Random.secure();
    // Generate a list of 32 random bytes (256-bit key)
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return Uint8List.fromList(keyBytes);
  }

  void generateAndSaveSymmetricKey(){
    const secureStorage = FlutterSecureStorage();
    final key = generateSymmetricKey();
    final keyString = base64Encode(key);
    secureStorage.write(key: '${uid}#symmetricKey', value: keyString);
  }

  Future<Uint8List?> getSymmetricKey() async {
    const secureStorage = FlutterSecureStorage();
    final keyString = await secureStorage.read(key: '${uid}#symmetricKey');
    return keyString != null ? Uint8List.fromList(base64Decode(keyString)) : null;
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair() {
    final keyGen = RSAKeyGenerator();
    final secureRandom = FortunaRandom();

    // Seed the random generator
    final seed = Uint8List.fromList(List<int>.generate(32, (_) => Random.secure().nextInt(256)));
    secureRandom.seed(KeyParameter(seed));

    // Configure the key generator
    keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(
        BigInt.parse('65537'), // Public exponent (default is 65537)
        2048,                  // Key size in bits
        64,                    // Certainty factor for prime generation
      ),
      secureRandom,
    ));

    // Generate the key pair
    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair(publicKey, privateKey);
  }

  Map<String, Map<String, String>> generateSaveAndReturnRSAKeys(){
    const secureStorage = FlutterSecureStorage();
    final keyPair = generateRSAKeyPair();
    final publicKey = keyPair.publicKey;
    final privateKey = keyPair.privateKey;
    secureStorage.write(key: '${uid}#privateKey', value: {'modulus': privateKey.modulus.toString(), 'exponent': privateKey.exponent.toString()}.toString());
    secureStorage.write(key: '${uid}#publicKey', value: {'modulus': publicKey.modulus.toString(), 'exponent': publicKey.exponent.toString()}.toString());
    return {'privateKey': {'modulus': privateKey.modulus.toString(), 'exponent': privateKey.exponent.toString()}, 'publicKey': {'modulus': publicKey.modulus.toString(), 'exponent': publicKey.exponent.toString()}};
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

  /*Uint8List deriveKey(String password, String salt) {
    final pbkdf2 = new PBKDF2();
    final key = pbkdf2.generateKey(password, salt, 10000, 32); // 256-bit key
    return Uint8List.fromList(key);
  }*/
}
