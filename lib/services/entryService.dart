
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reflect/services/backend_services.dart';

class EntryService extends BackendServices {
  Future<List<Map<String, dynamic>>> getEntries(String chapterId) async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/entries/$chapterId'));
      if(response.statusCode == 200){
        final decodedList = jsonDecode(response.body) as List;
        return decodedList.map((entry) => entry as Map<String, dynamic>).toList();
      }
      return [];
    } catch(e){
      print("Error fetching entries: $e");
      return [];
    }
  }

  Future<bool> createEntry(Map<String, dynamic> entry) async {
    try{
      print(entry.toString());
      final response = await http.post(Uri.parse('$baseUrl/entries/'), body: jsonEncode({"entry":entry}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 201) return true;
      return false;
    } catch(e){
      print("Error creating entry: $e");
      return false;
    }
  }

  Future<bool> updateEntry(Map<String, dynamic> entry) async {
    try{
      final response = await http.post(Uri.parse('$baseUrl/entries/update/'), body: jsonEncode({"entry":entry}), headers: {'Content-Type': 'application/json'});
      if(response.statusCode == 200) return true;
      return false;
    } catch(e){
      print("Error updating entry: $e");
      return false;
    }
  }

  Future<bool> deleteEntry(String chapterId, String entryId) async {
    try{
      final response = await http.delete(Uri.parse('$baseUrl/entries/?chapterId=$chapterId&entryId=$entryId'));
      if(response.statusCode == 200) return true;
      return false;
    } catch(e){
      print("Error deleting entry: $e");
      return false;
    }
  }
}