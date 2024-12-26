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

  Chapter? loadOneChapterFromCache(String chapterId){
    final cachedData = chapterBox.get(userId);
    if(cachedData == null) return null;

    final List cachedChapters = cachedData["chapters"] ?? [];
    for(var chapter in cachedChapters){
      if(chapter['_id'] == chapterId){
        return Chapter.fromMap(Map<String, dynamic>.from(chapter as Map));
      }
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
    await entryBox.delete(chapterId);
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

  Future<bool> addOneEntryToCache(Map<String, dynamic> entry, String chapterId) async {
    final cachedData = entryBox.get(chapterId);
    entry['_id'] = mongo.ObjectId().oid;


    if(cachedData == null) await entryBox.put(chapterId, [entry]);
    else{
      final List cachedEntries = cachedData as List;
      cachedEntries.add(entry);
      await entryBox.put(chapterId, cachedEntries);
    }
    
    final tagService = TagService();
    final entryTags = tagService.parseTagFromEntryData([entry]);
    final currentTags = tagService.getAllTags();
    final tags = [...currentTags, ...entryTags].toSet().toList();
    tagService.updateTags(tags);

    //update entrycount 
    print("updating entry count function");
    updateChapterEntryCount(chapterId, 0, 1);

    return true;
  }

  Future<bool> deleteOneEntryFromCache(String entryId, String chapterId) async {
    final cachedData = entryBox.get(chapterId);
    if(cachedData == null) return false;

    final List cachedEntries = cachedData as List;
    final updatedEntries = cachedEntries.where((entry) => entry['_id'] != entryId).toList();
    await entryBox.put(chapterId, updatedEntries);

    //update entrycount
    updateChapterEntryCount(chapterId, 0, -1);

    return true;
  }

  Future<bool> updateOneEntryInCache(String entryId, Map<String, dynamic> entry, String chapterId) async {
    final cachedData = entryBox.get(chapterId);
    if(cachedData == null) return false;

    final List cachedEntries = cachedData as List;
    int index = 0;
    for (var i = 0; i < cachedEntries.length; i++) {
      if(cachedEntries[i]['_id'] == entryId){
        index = i;
        break;
      }
    }
    cachedEntries[index] = entry;
    await entryBox.put(chapterId, cachedEntries);
    return true;
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


  Future<void> updateChapterEntryCount(String chapterId, int count, int incrementBy) async {
    final cachedData = chapterBox.get(userId);
    if(cachedData == null) return;

    final List cachedChapters = cachedData["chapters"] ?? [];
    int index = 0;
    for (var i = 0; i < cachedChapters.length; i++) {
      if(cachedChapters[i]['_id'] == chapterId){
        index = i;
        break;
      }
    }
    int entryCount = cachedChapters[index]['entryCount'];
    entryCount += incrementBy;
    cachedChapters[index]['entryCount'] = entryCount;

    print("updating entry count to $entryCount");

    await chapterBox.put(userId, {"chapters": cachedChapters});
  }
  
}