import 'dart:convert';

import 'package:reflect/models/chapter.dart';
import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/timestamp_service.dart';

class ChapterService extends BackendServices {
  Future<List<Map<String, dynamic>>?> getChapters() async {
    try{
      //print("baseurl: $baseUrl");
      final date = TimestampService().getChapterTimestamp();
      print("date for getchapters(): $date");
      final response = await http.get(Uri.parse('$baseUrl/chapters/?uid=${user!.uid}&date=$date')).timeout(const Duration(seconds: 10));
      print(response.statusCode);
      if(response.statusCode == 304){
        print("User already has latest");
        return null;
      }
      if(response.statusCode == 200){
        final decodedList = jsonDecode(response.body) as List;
        await TimestampService().updateChapterTimestamp();
        return decodedList.map((chapter) => chapter as Map<String, dynamic>).toList();
      }

      print("status code: ${response.statusCode}");
      return null;
    } catch(e){
      print("Error fetching chapters here?: $e");
      return null;
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

  Future<bool> deleteChapter(String chapterId) async {
    try{
      final response = await http.delete(Uri.parse('$baseUrl/chapters/?uid=${user!.uid}&id=$chapterId'));
      if(response.statusCode == 200){
        print("Chapter deleted successfully");
        return true;
      }
      print("Error deleting chapter at server: ${response.body}");
      return false;
    } catch(e){
      print("Error deleting chapter: $e");
      return false;
    }
  }

  Future<Map<String,dynamic>> updateChapter(String chapterId, Map<String, dynamic> chapter) async {
    try{
      print("sending chapter $chapter");
      final response = await http.post(Uri.parse('$baseUrl/chapters/update/'), body: jsonEncode({"chapter":chapter}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 200){
        print("Chapter updated successfully");
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      print("Error updating chapter at server: ${response.body}");
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch(e){
      print("Error updating chapter: $e");
      return {"error":e};
    }
  }
}