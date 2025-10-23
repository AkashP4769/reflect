import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/models/tag.dart';

class Subsection{
  final DateTime date;
  final List<Map<String,dynamic>>? content;

  Subsection({this.content, DateTime? date}) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'content': content,
    };
  }

  factory Subsection.fromMap(Map<String, dynamic> data) {
    return Subsection(
      content: data['content'] != null
        ? List<Map<String, dynamic>>.from((data['content'] as List).map(
            (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ))
        : null,
      date: DateTime.parse(data['date']),
    );
  }

  factory Subsection.fromQuill(quill.Document document, DateTime date) {
    return Subsection(
      content: document.toDelta().toJson(),
      date: date,
    );
  }
  
  quill.Document getContentAsQuill() {
    if(content == null) return quill.Document();
    if(content!.isEmpty) return quill.Document();
    return quill.Document.fromJson(content ?? []);
  }
  
  @override
  String toString(){
    return 'Subsection{date: $date, content: $content}';
  }
  
}


class Entry{
  final String? id;
  final String? chapterId;
  final String? title;
  final List<Map<String,dynamic>>? content;
  final List<Subsection>? subsections;
  final DateTime date;
  final List<Map<String, dynamic>>? tags;
  final bool? encrypted;
  final bool? favourite;
  List<String>? imageUrl;

  Entry({this.title, this.content, this.subsections, this.id, this.tags, this.encrypted, this.chapterId, this.favourite, this.imageUrl, DateTime? date}) : date = date ?? DateTime.now();

  factory Entry.fromQuill(String title, quill.Document document, DateTime date, List<Map<String, dynamic>>? tags, String chapterId, String? id, bool encrypted, bool favourite, List<String>? imageUrl) {
    return Entry(
      id: id,
      chapterId: chapterId,
      title: title,
      content: document.toDelta().toJson(), // Store Delta as a Map
      date: date,
      tags: tags,
      encrypted: false,
      favourite: favourite,
      imageUrl: imageUrl,
    );
  }

  factory Entry.fromSubsections(String title, List<Subsection> subsections, DateTime date, List<Map<String, dynamic>>? tags, String chapterId, String? id, bool encrypted, bool favourite, List<String>? imageUrl) {
    return Entry(
      id: id,
      chapterId: chapterId,
      title: title,
      subsections: subsections,
      date: date,
      tags: tags,
      encrypted: false,
      favourite: favourite,
      imageUrl: imageUrl,
    );
  }

  // Convert the content Map back into a Quill Document
  /*quill.Document getContentAsQuill() {
    if(content == null) return quill.Document();
    if(content!.isEmpty) return quill.Document();
    return quill.Document.fromJson(content ?? []);
  }*/

  quill.Document getCombinedContentAsQuill() {
    if(subsections == null || subsections!.isEmpty) return quill.Document();
    // Combine all subsection contents into one document
    final combinedDelta = subsections!
        .map((sub) => sub.content ?? [])
        .expand((content) => content)
        .toList();

    if(combinedDelta.isEmpty) return quill.Document();

    return quill.Document.fromJson(combinedDelta);
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
      'encrypted': encrypted,
      'favourite': favourite,
      'imageUrl': imageUrl,
    };
  }

  // Create an Entry object from a JSON object
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['_id'],
      chapterId: json['chapterId'],
      title: json['title'],
      content: json['content'] != null ? List<Map<String, dynamic>>.from(json['content']) : null,
      date: DateTime.parse(json['date']).toLocal(),
      tags: json['tags'] != null ? List<Map<String, dynamic>>.from(json['tags']) : null,
      encrypted: json['encrypted'],
      favourite: json['favourite'],
      imageUrl: json['imageUrl'] != null ? List<String>.from(json['imageUrl']) : null,
    );
  }

  factory Entry.fromMap(Map<String, dynamic> data) {
    return Entry(
      id: data['_id'],
      chapterId: data['chapterId'],
      title: data['title'],
      content: data['content'] != null
        ? List<Map<String, dynamic>>.from((data['content'] as List).map(
            (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ))
        : null,
      subsections: data['subsections'] != null
        ? List<Subsection>.from((data['subsections'] as List).map(
            (item) => Subsection.fromMap(Map<String, dynamic>.from(item as Map<dynamic, dynamic>)),
          ))
        : data['content'] != null
        ? [
            Subsection(
              content: data['content'] != null
                ? List<Map<String, dynamic>>.from((data['content'] as List).map(
                    (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
                  ))
                : null,
              date: DateTime.parse(data['date']),
            )
          ]
        : null,

      date: DateTime.parse(data['date']),
      tags: data['tags'] != null
        ? List<Map<String, dynamic>>.from((data['tags'] as List).map(
            (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          ))
        : null,
      encrypted: data['encrypted'],
      favourite: data['favourite'],
      imageUrl: data['imageUrl'] != null ? List<String>.from(data['imageUrl']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    print("im a passing title" + title.toString());

    return {
      '_id': id,
      'chapterId': chapterId,
      'title': title,
      'content': content,
      'subsections': subsections != null ? subsections!.map((sub) => sub.toMap()).toList() : null,
      //'useSubsections': useSubsections,
      'date': date.toLocal().toIso8601String(),
      'tags': tags,
      'encrypted': encrypted,
      'favourite': favourite,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString(){
    return 'Entry{id: $id, chapterId: $chapterId, title: $title, date: $date, tags: $tags,  encrypted: $encrypted , favourite: $favourite, imageUrl: $imageUrl}';
  }
}