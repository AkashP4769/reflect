
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reflect/services/backend_services.dart';

class EntryService extends BackendServices {
  Future<List<Map<String, dynamic>>?> getEntries(String chapterId, String date, bool? explicit) async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/entries/?chapterId=$chapterId&uid=${user!.uid}&date=$date&explicit=${explicit == true ? 'true' :'false'}')).timeout(const Duration(seconds: 5), onTimeout: () => http.Response('Error', 408));
      if(response.statusCode == 200){
        print("Entries fetched successfully");
        final decodedList = jsonDecode(response.body) as List;
        return decodedList.map((entry) => entry as Map<String, dynamic>).toList();
      }

      if(response.statusCode == 304) print("user already has latest entries");

      print("response status code: ${response.statusCode}");
      return null;

    } catch(e){
      print("Error fetching entries: $e");
      return null;
    }
  }

  Future<bool> createEntry(Map<String, dynamic> entry) async {
    try{
      print(entry.toString());
      final response = await http.post(Uri.parse('$baseUrl/entries/'), body: jsonEncode({"entrybody":entry, 'uid':user!.uid}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 201) return true;
      return false;
    } catch(e){
      print("Error creating entry: $e");
      return false;
    }
  }

  Future<bool> updateEntry(Map<String, dynamic> entry) async {
    try{
      final response = await http.post(Uri.parse('$baseUrl/entries/update/'), body: jsonEncode({"entry":entry, 'uid':user!.uid}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 200) return true;
      return false;
    } catch(e){
      print("Error updating entry: $e");
      return false;
    }
  }

  Future<bool> deleteEntry(String chapterId, String entryId) async {
    try{
      final response = await http.delete(Uri.parse('$baseUrl/entries/?chapterId=$chapterId&entryId=$entryId&uid=${user!.uid}'));
      if(response.statusCode == 200) return true;
      return false;
    } catch(e){
      print("Error deleting entry: $e");
      return false;
    }
  }
}