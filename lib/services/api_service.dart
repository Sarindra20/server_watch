import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Server>> fetchServers() async {
    final response = await http.get(Uri.parse('$baseUrl/servers'));
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Server.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}