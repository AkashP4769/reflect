
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

}