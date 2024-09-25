
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class TimestampService{
  final User? user = FirebaseAuth.instance.currentUser;
  final timestampBox = Hive.box('timestamps');

  void updateChapterTimestamp(){
    timestampBox.put(user!.uid, {'chapters': DateTime.now().toIso8601String()});
  }

  void updateEntryTimestamp(String entryId){
    timestampBox.put(user!.uid, {'entries': {entryId: DateTime.now().toIso8601String()}});
  }

  String getChapterTimestamp(){
    final userTimeStamps =  timestampBox.get(user!.uid);
    if(userTimeStamps != null){
      return userTimeStamps['chapters'];
    }
    return DateTime.now().subtract(const Duration(days: 1000)).toIso8601String();
  }

  String getEntryTimestamp(String entryId){
    final userTimeStamps =  timestampBox.get(user!.uid);
    if(userTimeStamps != null){
      return userTimeStamps['entries'][entryId];
    }
    return DateTime.now().subtract(const Duration(days: 1000)).toIso8601String();
  }


}