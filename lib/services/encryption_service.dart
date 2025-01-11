import 'dart:convert'; // For JSON serialization/deserialization
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:conduit_password_hash/pbkdf2.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
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

  Future<Device> createDeviceDetails(bool createSymKey) async {
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

    /*final rsaKeyPairs = generateSaveAndReturnRSAKeys();
    final encryptedSymKey;
    if(createSymKey){
      generateAndSaveSymmetricKey();
      encryptedSymKey = await encryptSymKey(rsaKeyPairs['publicKey']!);
    }
    else encryptedSymKey = '';

    Device device = Device(deviceId: await getDeviceID(), deviceName: deviceName, deviceType: deviceType, publicKey: rsaKeyPairs['publicKey']!, encryptedKey: encryptedSymKey);*/
    //final device = Device(deviceId: "44444", deviceName: "IPhone 14", deviceType: "Android", publicKey: 'adfsads', encryptedKey: '');

    Device device = Device(deviceId: await getDeviceID(), deviceName: deviceName, deviceType: deviceType, publicKey: {}, encryptedKey: '');
    return device;
  }

  List<int> generateSalt() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }

  Uint8List generateSymmetricKey(String password) {
    final uintSalt = generateSalt();
    final String salt = base64Encode(uintSalt);
    final pbkdf2 = PBKDF2();
    final key = pbkdf2.generateKey(password, salt, 10000, 32); // 256-bit key
    return Uint8List.fromList(key);
  }

  /*static Uint8List generateSymmetricKey() {
    final random = Random.secure();
    // Generate a list of 32 random bytes (256-bit key)
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return Uint8List.fromList(keyBytes);
  }*/

  void generateAndSaveSymmetricKey(String password){
    const secureStorage = FlutterSecureStorage();
    final key = generateSymmetricKey(password);
    final keyString = base64Encode(key);
    secureStorage.write(key: '${uid}#symmetricKey', value: keyString);
  }

  void saveSymmetricKey(String keyString){
    const secureStorage = FlutterSecureStorage();
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
    print("is this function ever getting called");
    secureStorage.write(key: '${uid}#privateKey', value: jsonEncode({'modulus': privateKey.modulus.toString(), 'exponent': privateKey.exponent.toString(), 'p':privateKey.p.toString(), 'q':privateKey.q.toString()}));
    secureStorage.write(key: '${uid}#publicKey', value: jsonEncode({'modulus': publicKey.modulus.toString(), 'exponent': publicKey.exponent.toString()}));
    return {'privateKey': {'modulus': privateKey.modulus.toString(), 'exponent': privateKey.exponent.toString(), 'p':privateKey.p.toString(), 'q':privateKey.q.toString()}, 'publicKey': {'modulus': publicKey.modulus.toString(), 'exponent': publicKey.exponent.toString()}};

  }

  Future<Map<String, Map<String, String>>> getRSAKeys() async {
    const secureStorage = FlutterSecureStorage();
    final privateKeyString = await secureStorage.read(key: '${uid}#privateKey');
    final publicKeyString = await secureStorage.read(key: '${uid}#publicKey');
    if( privateKeyString == null || publicKeyString == null){
      return {'privateKey': {'exponent':'null', 'modulus':'null'}, 'publicKey': {'exponent':'null', 'modulus':'null'}};
    }
    else {
      final privateKey = jsonDecode(privateKeyString) as Map<String, dynamic>;
      final publicKey = jsonDecode(publicKeyString) as Map<String, dynamic>;
      return {'privateKey': {'modulus': privateKey['modulus'], 'exponent': privateKey['exponent'], 'p':privateKey['p'], 'q':privateKey['q']}, 'publicKey': {'modulus': publicKey['modulus'], 'exponent': publicKey['exponent']}};
    }
  }


  //encrpt symmetric key using RSA
  Future<String> encryptSymKey(Map<String, String> publicKey ) async {
    if(publicKey['modulus'] == 'null' || publicKey['exponent'] == 'null') return 'null';

    final key = getSymmetricKey();
    final modulus = BigInt.parse(publicKey['modulus']!);
    final exponent = BigInt.parse(publicKey['exponent']!);
    final message = await key;

    final rsaEngine = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(RSAPublicKey(modulus, exponent)));
    return base64Encode(rsaEngine.process(message!));
  }

  //decrypt symmetric key using RSA
  Future<String> decryptSymKey(String strCiphertext) async {
    final rsaKeys = await getRSAKeys();

    final modulus = BigInt.parse(rsaKeys['privateKey']!['modulus']!);
    final privateExponent = BigInt.parse(rsaKeys['privateKey']!['exponent']!);
    final p = BigInt.parse(rsaKeys['privateKey']!['p']!);
    final q = BigInt.parse(rsaKeys['privateKey']!['q']!);
    final ciphertext = Uint8List.fromList(base64Decode(strCiphertext));

    final rsaEngine = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(RSAPrivateKey(modulus, privateExponent, p, q)));
    return base64Encode(rsaEngine.process(ciphertext));
  }

  String encryptNestedData(Map<String, dynamic> nestedMap, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Convert the nested map to a JSON string
    final jsonString = jsonEncode(nestedMap);
    // Encrypt the JSON string
    final encryptedData = encrypter.encrypt(jsonString, iv: iv);

    // Combine the IV and ciphertext (Base64 encoded)
    final combined = base64.encode(iv.bytes + encryptedData.bytes);
    return combined; // Return the combined IV and ciphertext
  }

  String encryptData(String data, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Encrypt the data
    final encryptedData = encrypter.encrypt(data, iv: iv);

    // Combine the IV and ciphertext (Base64 encoded)
    final combined = base64.encode(iv.bytes + encryptedData.bytes);
    return combined; // Return the combined IV and ciphertext
  }

  // Decryption Function
  Map<String, dynamic> decryptNestedData(String encryptedData, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);

    final combined = base64.decode(encryptedData);
    final iv = encrypt.IV(combined.sublist(0, 16));
    final ciphertext = combined.sublist(16);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Decrypt the encrypted string
    final decryptedData = encrypter.decrypt64(base64Encode(ciphertext), iv: iv);

    // Convert the decrypted string back into a nested map
    final nestedMap = jsonDecode(decryptedData) as Map<String, dynamic>;
    return nestedMap; // Display the nested map to the user
  }

  String decryptData(String encryptedData, Uint8List keyBytes) {
    final key = encrypt.Key(keyBytes);
    // Decode the combined data
    final combined = base64.decode(encryptedData);

    // Extract the IV and ciphertext
    final iv = encrypt.IV(combined.sublist(0, 16));
    final ciphertext = combined.sublist(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Decrypt the ciphertext
    final decryptedData = encrypter.decrypt(
      encrypt.Encrypted(ciphertext),
      iv: iv,
    );

    return decryptedData; // Return the decrypted string
  }

}
