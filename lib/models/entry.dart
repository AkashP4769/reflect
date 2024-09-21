import 'package:flutter_quill/flutter_quill.dart' as quill;

class Entry{
  final String? id;
  final String? title;
  final List<Map<String,dynamic>>? content;
  final DateTime date = DateTime.now();
  final List<String>? tags;

  Entry({this.title, this.content, DateTime? date, this.id, this.tags});

  factory Entry.fromQuill(String title, quill.Document document, DateTime date, List<String> tags) {
    return Entry(
      title: title,
      content: document.toDelta().toJson(), // Store Delta as a Map
    );
  }

  // Convert the content Map back into a Quill Document
  quill.Document getContentAsQuill() {
    if(content == null) return quill.Document();
    if(content!.isEmpty) return quill.Document();
    return quill.Document.fromJson(content ?? []);
  }

  // Convert Entry object to a JSON object for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,  // Store the Delta as a Map
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }

  // Create an Entry object from a JSON object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      title: json['title'],
      content: json['content'],  // Rebuild the Delta from JSON
      date: DateTime.parse(json['date']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  factory Entry.fromMap(Map<String, dynamic> data) {
    return Entry(
      title: data['title'],
      content: data['content'],
      date: DateTime.parse(data['date']),
      tags: (data['tags'] == null || (data['tags'] as List).isEmpty)? [] : (data['tags'] as List).map((imageUrl) => imageUrl as String).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }
}