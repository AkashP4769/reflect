import 'dart:convert';

import 'package:reflect/models/chapter.dart';
import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;

class ChapterService extends BackendServices {
  Future<List<Map<String, dynamic>>> getChapters() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/chapters/${user!.uid}'));
      if(response.statusCode == 200){
        print(response.body);
        final decodedList = jsonDecode(response.body) as List;
        return decodedList.map((chapter) => chapter as Map<String, dynamic>).toList();
      }
      return [];
    } catch(e){
      print("Error fetching chapters: $e");
      return [];
    }
  }

  Future<bool> createChapter(Map<String, dynamic> chapter) async {
    try{
      chapter['uid'] = user!.uid;
      print(jsonEncode(chapter));
      final response = await http.post(Uri.parse('$baseUrl/chapters/'), body: jsonEncode({"chapter":chapter}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 201){
        print("Chapter created successfully");
        return true;
      }
      print("Error creating chapter at server: ${response.body}");
      return false;
    } catch(e){
      print("Error creating chapter: $e");
      return false;
    }
  }
}