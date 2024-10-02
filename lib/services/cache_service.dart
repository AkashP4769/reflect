import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/services/timestamp_service.dart';

import '../models/chapter.dart';

class CacheService{
  final Box chapterBox = Hive.box('chapters');
  final Box entryBox = Hive.box('entries');
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

  Future<void> addChaptersToCache(List<Map<String,dynamic>>? data) async {
    print("adding data to  cache");
    await chapterBox.put(userId, {"chapters": data});
    await TimestampService().updateChapterTimestamp();
  }

  Future<void> addEntryToCache(List<Map<String, dynamic>>? data, String chapterId) async {
    await entryBox.put(chapterId, data);
    await TimestampService().updateEntryTimestamp(chapterId);
  }

  List<Entry>? loadEntriesFromCache(String chapterId)  {
    final cachedData = entryBox.get(chapterId);
    if(cachedData != null){
      List<Map<String, dynamic>> entriesData;
      try {
        entriesData = (cachedData as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        print("Error parsing cache: $e");
        entriesData = [];
      }
      
      List<Entry> entriesList = entriesData.map((entry) => Entry.fromMap(entry)).toList();
      return entriesList;
    }
    return null;
  }
}