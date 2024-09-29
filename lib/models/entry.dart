import 'package:flutter_quill/flutter_quill.dart' as quill;

class Entry{
  final String? id;
  final String? chapterId;
  final String? title;
  final List<Map<String,dynamic>>? content;
  final DateTime date;
  final List<String>? tags;

  Entry({this.title, this.content, this.id, this.tags, this.chapterId, DateTime? date}) : date = date ?? DateTime.now();

  factory Entry.fromQuill(String title, quill.Document document, DateTime date, List<String>? tags, String chapterId, String? id) {
    return Entry(
      id: id,
      chapterId: chapterId,
      title: title,
      content: document.toDelta().toJson(), // Store Delta as a Map
      date: date,
      tags: tags,
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
      '_id': id,
      'chapterId': chapterId,
      'title': title,
      'content': content,  // Store the Delta as a Map
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }

  // Create an Entry object from a JSON object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['_id'],
      chapterId: json['chapterId'],
      title: json['title'],
      content: json['content'] != null ? List<Map<String, dynamic>>.from(json['content']) : null,
      date: DateTime.parse(json['date']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  factory Entry.fromMap(Map<String, dynamic> data) {
    return Entry(
      id: data['_id'],
      chapterId: data['chapterId'],
      title: data['title'],
      //content: data['content'] != null ? List<Map<String, dynamic>>.from(data['content']) : null,
      content: data['content'] != null
        ? List<Map<String, dynamic>>.from((data['content'] as List).map(
            (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ))
        : null,
      date: DateTime.parse(data['date']).toLocal(),
      tags: (data['tags'] == null || (data['tags'] as List).isEmpty)? [] : (data['tags'] as List).map((imageUrl) => imageUrl as String).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'chapterId': chapterId,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }
}