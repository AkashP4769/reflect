// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:reflect/models/entry.dart';

class Chapter {
  final String id;
  final String uid;
  final String title;
  final String description;
  final List<String>? imageUrl;
  final DateTime createdAt;
  int entryCount;

  Chapter({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.entryCount,
  });

  /*factory Chapter.fromMap(Map<String, dynamic> data){
    return Chapter(
      id: data['_id'],
      uid: data['uid'],
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'].isEmpty || data['imageUrl'] == null ? [] : data['imageUrl'].map((imageUrl) => imageUrl as String).toList(),
      entryCount: data['entryCount'],
      createdAt: DateTime.parse(data['createdAt'])
    );
  }*/

  Chapter copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    List<String>? imageUrl,
    DateTime? createdAt,
    int? entryCount,
  }) {
    return Chapter(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': createdAt.toLocal().toIso8601String(),
      'entryCount': entryCount,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['_id'] as String,
      uid: map['uid'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: (map['imageUrl'] == null || (map['imageUrl'] as List).isEmpty)? [] : (map['imageUrl'] as List).map((imageUrl) => imageUrl as String).toList(),
      createdAt: DateTime.parse(map['date'] ?? map['createdAt']),
      entryCount: map['entryCount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chapter.fromJson(String source) => Chapter.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chapter(_id: $id, uid: $uid, title: $title, description: $description, imageUrl: $imageUrl, createdAt: $createdAt, entryCount: $entryCount)';
  }

  @override
  bool operator ==(covariant Chapter other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.uid == uid &&
      other.title == title &&
      other.description == description &&
      listEquals(other.imageUrl, imageUrl) &&
      other.createdAt == createdAt &&
      other.entryCount == entryCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      uid.hashCode ^
      title.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      createdAt.hashCode ^
      entryCount.hashCode;
  }
}

class ChapterAdvanced extends Chapter{
  List<Entry>? entries;

  ChapterAdvanced({required Chapter chapter, List<Entry>? entries}) : super(id: chapter.id, uid: chapter.uid, title: chapter.title, description: chapter.description, imageUrl: chapter.imageUrl, entryCount: chapter.entryCount, createdAt: chapter.createdAt){
    entries = entries;
  }

  void updateEntries(List<Entry> entries){
    entries = entries;
    entryCount = entries.length;
  }

  void updateEntriesFromMap(List<Map<String, dynamic>> data){
    entries = data.map((entry) => Entry.fromMap(entry)).toList();
  }

  factory ChapterAdvanced.fromChapter(Chapter chapter){
    return ChapterAdvanced(chapter: chapter);
  }

  factory ChapterAdvanced.fromMap(Map<String, dynamic> data){
    return ChapterAdvanced(
      chapter: Chapter(
        id: data['_id'],
        uid: data['uid'],
        title: data['title'],
        description: data['description'],
        imageUrl: (data['imageUrl'] == null || (data['imageUrl'] as List).isEmpty)? [] : (data['imageUrl'] as List).map((imageUrl) => imageUrl as String).toList(),
        entryCount: data['entryCount'],
        createdAt: DateTime.parse(data['date']),
      ),
      entries: (data['entries'] as List<dynamic>?)?.map((entry) => Entry.fromMap(entry as Map<String, dynamic>)).toList() ?? []
    );
  }

}