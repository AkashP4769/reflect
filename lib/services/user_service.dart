import 'dart:convert';

import 'package:reflect/services/backend_services.dart';
import 'package:http/http.dart' as http;

class UserService extends BackendServices {
  Future<void> addUser(String uid, String name, String email) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/'), body: jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print("Error at addUser(): $e");
    }
  }
}