import 'package:firebase_auth/firebase_auth.dart';
import 'package:reflect/models/entry.dart';


class Chapter{
  final String id;
  final String uid;
  final String title;
  final String description;
  final List<String>? imageUrl;
  final DateTime createdAt;
  int entryCount;

  Chapter({required this.title, required this.description, this.imageUrl, required this.entryCount, required this.uid, required this.id, required this.createdAt}); 

  factory Chapter.fromMap(Map<String, dynamic> data){
    return Chapter(
      id: data['_id'],
      uid: data['uid'],
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'].isEmpty ? [] : data['imageUrl'].map((imageUrl) => imageUrl as String).toList() as List<String>,
      entryCount: data['entryCount'],
      createdAt: DateTime.parse(data['createdAt'])
    );
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
        imageUrl: data['imageUrl'].map((imageUrl) => imageUrl as String).toList() as List<String>,
        entryCount: data['entryCount'],
        createdAt: DateTime.parse(data['createdAt']),
      ),
      entries: data['entries'] != null ? data['entries'].map((entry) => Entry.fromMap(entry)).toList() : []
    );
  }
}