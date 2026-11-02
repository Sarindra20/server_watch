import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/metric.dart';
import '../models/server.dart';
import '../models/incident.dart';
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // La clé est donnée au lancement, elle n'est pas écrite dans le code
  static const String apiKey = String.fromEnvironment('API_KEY');

  static const Map<String, String> _headers = {'X-API-Key': apiKey};

  static Future<List<Server>> fetchServers() async {
    final response =
        await http.get(Uri.parse('$baseUrl/servers'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Server.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<Server> fetchServer(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/servers/$id'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    return Server.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<Metric>> fetchMetrics(int serverId,
      {int minutes = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servers/$serverId/metrics?minutes=$minutes'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Metric.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addServer(String name, String ip) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servers'),
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }

  static Future<void> deleteServer(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/servers/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }

    static Future<List<Incident>> fetchIncidents(int serverId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servers/$serverId/incidents'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur API : ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}