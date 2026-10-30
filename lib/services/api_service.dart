import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server.dart';
import '../models/metric.dart';

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
    static Future<void> addServer(String name, String ip) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }

  static Future<void> deleteServer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/servers/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }

    static Future<Server> fetchServer(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/servers/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    return Server.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<Metric>> fetchMetrics(int serverId, {int minutes = 30}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/servers/$serverId/metrics?minutes=$minutes'));
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Metric.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}