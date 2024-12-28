import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/models/chapter.dart';

class ConversionService {
  final LazyBox sortBox = Hive.lazyBox('sorts');
  final User? user = FirebaseAuth.instance.currentUser;

  void saveChapterSort(String sortMethod, bool isAscending){
    sortBox.put(user!.uid + "#chapter", {'sortMethod': sortMethod, 'isAscending': isAscending});
  }

  Future<Map<String, dynamic>?> getChapterSort() async {
    final sortSetting = await sortBox.get(user!.uid + "#chapter");
    if(sortSetting != null) return Map<String, dynamic>.from(sortSetting);
    return {'sortMethod': 'alpha', 'isAscending': true};
  }

  List<Chapter> sortChapters(List<Chapter> chapters, String sortMethod, bool isAscending){
    switch(sortMethod){
      case 'alpha':
        chapters.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'time':
        chapters.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'count':
        chapters.sort((a, b) => a.entryCount.compareTo(b.entryCount));
        break;
    }
    if(!isAscending) chapters = chapters.reversed.toList();
    saveChapterSort(sortMethod, isAscending);
    return chapters;
  }

  void saveEntrySort(String sortMethod, bool isAscending, bool isGroupedEntries){
    sortBox.put(user!.uid + "#entry", {'sortMethod': sortMethod, 'isAscending': isAscending, 'isGroupedEntries': isGroupedEntries});
  }

  Future<Map<String, dynamic>?> getEntrySort() async {
    final sortSetting = await sortBox.get(user!.uid + "#entry");
    if(sortSetting != null) return Map<String, dynamic>.from(sortSetting);
    return null;
  }
}