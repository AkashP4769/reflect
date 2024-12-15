// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:reflect/models/device.dart';

class UserSetting {
  final String uid;
  final String name;
  final String email;
  final String chapterIds;
  final String primaryDevice;
  final List<Device> devices;
  final String encryptionMode;

  UserSetting({
    required this.uid,
    required this.name,
    required this.email,
    required this.chapterIds,
    required this.primaryDevice,
    required this.devices,
    required this.encryptionMode,
  });

  

  UserSetting copyWith({
    String? uid,
    String? name,
    String? email,
    String? chapterIds,
    String? primaryDevice,
    List<Device>? devices,
    String? encryptionMode,
  }) {
    return UserSetting(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      chapterIds: chapterIds ?? this.chapterIds,
      primaryDevice: primaryDevice ?? this.primaryDevice,
      devices: devices ?? this.devices,
      encryptionMode: encryptionMode ?? this.encryptionMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'chapterIds': chapterIds,
      'primaryDevice': primaryDevice,
      'devices': devices.map((x) => x.toMap()).toList(),
      'encryptionMode': encryptionMode,
    };
  }

  factory UserSetting.fromMap(Map<String, dynamic> map) {
    return UserSetting(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      chapterIds: map['chapterIds'] as String,
      primaryDevice: map['primaryDevice'] as String,
      devices: List<Device>.from((map['devices'] as List<int>).map<Device>((x) => Device.fromMap(x as Map<String,dynamic>),),),
      encryptionMode: map['encryptionMode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSetting.fromJson(String source) => UserSetting.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserSetting(uid: $uid, name: $name, email: $email, chapterIds: $chapterIds, primaryDevice: $primaryDevice, devices: $devices, encryptionMode: $encryptionMode)';
  }

  @override
  bool operator ==(covariant UserSetting other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.name == name &&
      other.email == email &&
      other.chapterIds == chapterIds &&
      other.primaryDevice == primaryDevice &&
      listEquals(other.devices, devices) &&
      other.encryptionMode == encryptionMode;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      name.hashCode ^
      email.hashCode ^
      chapterIds.hashCode ^
      primaryDevice.hashCode ^
      devices.hashCode ^
      encryptionMode.hashCode;
  }
}
