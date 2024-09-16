import 'package:flutter_quill/flutter_quill.dart' as quill;

class Entry{
  final String title;
  final List<Map<String,dynamic>> content;
  final DateTime date = DateTime.now();

  Entry({required this.title, required this.content, DateTime? date});

  factory Entry.fromQuill(String title, quill.Document document) {
    return Entry(
      title: title,
      content: document.toDelta().toJson(), // Store Delta as a Map
    );
  }

  // Convert the content Map back into a Quill Document
  quill.Document getContentAsQuill() {
    return quill.Document.fromJson(content);
  }

  // Convert Entry object to a JSON object for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,  // Store the Delta as a Map
    };
  }

  // Create an Entry object from a JSON object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      title: json['title'],
      content: json['content'],  // Rebuild the Delta from JSON
    );
  }

  factory Entry.fromMap(Map<String, dynamic> data) {
    return Entry(
      title: data['title'],
      content: data['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }
}