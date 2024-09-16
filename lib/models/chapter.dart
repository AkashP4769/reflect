import 'package:reflect/models/entry.dart';

class Chapter{
  final String title;
  final String description;
  final String? imageUrl;
  final int entryCount;

  Chapter({required this.title, required this.description, this.imageUrl, required this.entryCount});
}

class ChapterAdvanced extends Chapter{
  final List<Entry> entries;

  ChapterAdvanced({required this.entries, required super.title, required super.description, required super.entryCount});
}