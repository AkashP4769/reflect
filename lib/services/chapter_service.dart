import 'dart:convert';

import 'package:reflect/models/chapter.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;
import 'package:reflect/services/cache_service.dart';
import 'package:reflect/services/timestamp_service.dart';
import 'package:reflect/services/user_service.dart';

class ChapterService extends BackendServices {
  Future<List<Map<String, dynamic>>?> getChapters(bool? explicit) async {
    try{
      final date = TimestampService().getChapterTimestamp();

      final response = await http.get(Uri.parse("$baseUrl/chapters/?uid=${user!.uid}&date=$date&explicit=${explicit == true ? 'true' :'false'}")).timeout(const Duration(seconds: 5), onTimeout: () => http.Response('Error', 408));
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

  Future<bool> updateChapter(String chapterId, Map<String, dynamic> chapter) async {
    try{
      print("sending chapter $chapter");
      final response = await http.post(Uri.parse('$baseUrl/chapters/update/'), body: jsonEncode({"chapter":chapter}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 200){
        print("Chapter updated successfully");
        return true;
      }
      print("Error updating chapter at server: ${response.body}");
      return true;
    } catch(e){
      print("Error updating chapter: $e");
      return false;
    }
  }

  Future<bool> importAll() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/chapters/import/?uid=${user!.uid}'));
      if(response.statusCode == 200){
        print("Importing chapters");
        print(jsonDecode(response.body)['chapters']);
        CacheService().importToCache(user!.uid, List<Map<String, dynamic>>.from(jsonDecode(response.body)['chapters']));
        print("Chapters imported successfully");
        return true;
      }
      print("Error importing chapters at server: ${response.body}");
      return false;
    } catch(e){
      print("Error importing chapters: $e");
      return false;
    }
  }

  Future<bool> exportAll() async {
    final encryptedChapter = await CacheService().exportFromCache(user!.uid, encrypted: true);
    print("encryptedChapter: ${jsonEncode(encryptedChapter)}");

    //final decrypted

    return true;

    /*try{
      print("Exporting chapters");
      //Error: This expression has type 'void' and can't be used.
      final response = await http.post(Uri.parse('$baseUrl/chapters/export/'), body: jsonEncode({"chapters":CacheService().exportFromCache(user!.uid), "uid": user!.uid}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 200){
        print("Exporting chapters");
        return true;
      }
      print("Error exporting chapters at server: ${response.body}");
      return false;
    } catch(e){
      print("Error exporting chapters: $e");
      return false;
    }*/
  }
}