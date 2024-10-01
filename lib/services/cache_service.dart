import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/models/entry.dart';

import '../models/chapter.dart';

class CacheService{
  final Box chapterBox = Hive.box('chapters');
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<Chapter>? loadChaptersFromCache(){
    List<Chapter> chapters = [];
    final cachedData = chapterBox.get(userId);
    print("cachedData $cachedData");

    if(cachedData == null) return null;
    final cachedChapters = cachedData["chapters"] ?? [];
    if(cachedChapters.isNotEmpty) {
      for (var chapter in cachedChapters) {
        final Map<String, dynamic> chapterMap = Map<String, dynamic>.from(chapter as Map<dynamic, dynamic>);
        chapters.add(Chapter.fromMap(chapterMap));
      }
      chapters = chapters.reversed.toList();
      return chapters;
    }

    return null;
  }
}