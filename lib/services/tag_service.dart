import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/models/tag.dart';

class TagService {
  final Box tagbox = Hive.box('tags');
  final User? user = FirebaseAuth.instance.currentUser;

  List<Tag> getAllTags(){
    final res = tagbox.get(user!.uid, defaultValue: []) as List;
    List<Tag> tagList = [];
    for (var tag in res) {
      tagList.add(Tag.fromMap(Map<String, dynamic>.from(tag)));

    }

    return tagList;
  }

  void updateTags(List<Tag> tags){
    List<Map<String, dynamic>> taglist = [];
    for (var tag in tags) {
      taglist.add(tag.toMap());
    }
    tagbox.put(user!.uid, taglist);
  }
}