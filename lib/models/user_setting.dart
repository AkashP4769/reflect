// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:reflect/models/device.dart';

class UserSetting {
  final String uid;
  final String name;
  final String email;
  final Device primaryDevice;
  final List<Device> devices;
  final String? salt;
  final String? keyValidator;
  String encryptionMode;

  UserSetting({
    required this.uid,
    required this.name,
    required this.email,
    required this.primaryDevice,
    required this.devices,
    required this.encryptionMode,
    this.salt,
    this.keyValidator,
  });

  

  UserSetting copyWith({
    String? uid,
    String? name,
    String? email,
    Device? primaryDevice,
    List<Device>? devices,
    String? encryptionMode,
    String? salt,
    String? keyValidator,
  }) {
    return UserSetting(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      primaryDevice: primaryDevice ?? this.primaryDevice,
      devices: devices ?? this.devices,
      encryptionMode: encryptionMode ?? this.encryptionMode,
      salt: salt ?? this.salt,
      keyValidator: keyValidator ?? this.keyValidator,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'primaryDevice': primaryDevice.toMap(),
      'devices': devices.map((x) => x.toMap()).toList(),
      'encryptionMode': encryptionMode,
      'salt': salt,
      'keyValidator': keyValidator,
    };
  }

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      primaryDevice: Device.fromMap(map['primaryDevice'] as Map<String,dynamic>),
      devices: List<Device>.from((map['devices'] as List).map((x) => Device.fromMap(x as Map<String,dynamic>))),
      encryptionMode: map['encryptionMode'] as String,
      salt: map['salt'] as String?,
      keyValidator: map['keyValidator'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSetting.fromJson(String source) => UserSetting.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserSetting(uid: $uid, name: $name, email: $email, primaryDevice: $primaryDevice, encryptionMode: $encryptionMode, salt: $salt, keyValidator: $keyValidator, devices: $devices)';
  }

  @override
  bool operator ==(covariant UserSetting other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.name == name &&
      other.email == email &&
      other.primaryDevice == primaryDevice &&
      listEquals(other.devices, devices) &&
      other.encryptionMode == encryptionMode &&
      other.salt == salt &&
      other.keyValidator == keyValidator;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      name.hashCode ^
      email.hashCode ^
      primaryDevice.hashCode ^
      devices.hashCode ^
      encryptionMode.hashCode ^
      salt.hashCode ^
      keyValidator.hashCode;
  }
}
