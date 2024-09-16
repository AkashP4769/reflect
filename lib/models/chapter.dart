import 'package:reflect/models/entry.dart';

class Chapter{
  final String title;
  final String description;
  final String? imageUrl;
  final int entryCount;

  Chapter({required this.title, required this.description, this.imageUrl, required this.entryCount});
}

class ChapterAdvanced extends Chapter{
  final DateTime createdOn = DateTime.now();
  List<Entry>? entries;

  ChapterAdvanced({required Chapter chapter, List<Entry>? entries}) : super(title: chapter.title, description: chapter.description, imageUrl: chapter.imageUrl, entryCount: chapter.entryCount);

  void updateEntries(List<Entry> entries){
    this.entries = entries;
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
        title: data['title'],
        description: data['description'],
        imageUrl: data['imageUrl'],
        entryCount: data['entryCount']
      )
    );
  }
}