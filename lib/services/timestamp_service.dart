
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class TimestampService{
  final User? user = FirebaseAuth.instance.currentUser;
  final timestampBox = Hive.box('timestamps');

  void updateChapterTimestamp(){
    timestampBox.put(user!.uid, DateTime.now().toIso8601String());
  }

  String getChapterTimestamp(){
    final chapterTime = timestampBox.get(user!.uid);
    if(chapterTime != null){
      return chapterTime;
    }
    return DateTime.now().subtract(const Duration(days: 1000)).toIso8601String();
  }

  void updateEntryTimestamp(String chapterId){
    timestampBox.put(chapterId, DateTime.now().toIso8601String());
  }

  String getEntryTimestamp(String chapterId){
    final entriesOfChapterTime = timestampBox.get(chapterId);
    if(entriesOfChapterTime != null){
      return entriesOfChapterTime;
    }
    return DateTime.now().subtract(const Duration(days: 1000)).toIso8601String();
  }
}