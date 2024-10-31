import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/models/tag.dart';

class TagService {
  final Box tagbox = Hive.box('tags');
  final User? user = FirebaseAuth.instance.currentUser;

  List<Tag> getAllTags(){
    return tagbox.get(user!.uid, defaultValue: <Tag>[]);
  }

  void updateTags(List<Tag> tags){
    tagbox.put(user!.uid, tags);
  }
}