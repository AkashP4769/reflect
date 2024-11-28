class Device{
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String publicKey;
  final String encryptedKey;

  Device({required this.deviceId, required this.deviceName, required this.deviceType, required this.publicKey, required this.encryptedKey});

  Map<String, dynamic> toMap(){
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'publicKey': publicKey,
      'encryptedKey': encryptedKey
    };
  }
}