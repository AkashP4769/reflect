import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:reflect/models/entry.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/tag_service.dart';
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

  Future<bool> addOneChapterToCache(Map<String, dynamic> chapter) async {
    chapter['_id'] = mongo.ObjectId().oid;
    chapter['uid'] = userId;

    final cachedData = chapterBox.get(userId);
    if(cachedData == null){
      await chapterBox.put(userId, {"chapters": [chapter]});
      return true;
    }

    final List cachedChapters = cachedData["chapters"] ?? [];

    cachedChapters.add(chapter);
    await chapterBox.put(userId, {"chapters": cachedChapters});
    return true;
  }

  Future<bool> deleteChapterFromCache(String chapterId) async {
    final cachedData = chapterBox.get(userId);
    if(cachedData == null) return false;

    final List cachedChapters = cachedData["chapters"] ?? [];
    final updatedChapters = cachedChapters.where((chapter) => chapter['_id'] != chapterId).toList();
    await chapterBox.put(userId, {"chapters": updatedChapters});
    return true;
  }

  Future<bool> updateChapterInCache(String chapterId, Map<String, dynamic> chapter) async {
    final cachedData = chapterBox.get(userId);
    if(cachedData == null) return false;

    final List cachedChapters = cachedData["chapters"] ?? [];
    int index = 0;
    for (var i = 0; i < cachedChapters.length; i++) {
      if(cachedChapters[i]['_id'] == chapterId){
        index = i;
        break;
      }
    }
    cachedChapters[index] = chapter;
    await chapterBox.put(userId, {"chapters": cachedChapters});
    return true;
  }

  Future<void> addEntryToCache(List<Map<String, dynamic>>? data, String chapterId) async {
    await entryBox.put(chapterId, data);
    final tagService = TagService();
    final entryTags = tagService.parseTagFromEntryData(data!);
    final currentTags = tagService.getAllTags();

    final tags = [...currentTags, ...entryTags].toSet().toList();
    tagService.updateTags(tags);
    
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