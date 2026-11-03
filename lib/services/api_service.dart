import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/incident.dart';
import '../models/metric.dart';
import '../models/server.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // La clé est donnée au lancement, elle n'est pas écrite dans le code
  static const String apiKey = String.fromEnvironment('API_KEY');

  static const Map<String, String> _headers = {'X-API-Key': apiKey};

  static Future<dynamic> _getJson(String path) async {
    final response =
        await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('GET $path -> code ${response.statusCode}');
    }
    if (response.body.isEmpty) {
      throw Exception('GET $path -> réponse vide');
    }
    return jsonDecode(response.body);
  }

  static Future<List<Server>> fetchServers() async {
    final data = await _getJson('/servers') as List<dynamic>;
    return data
        .map((json) => Server.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<Server> fetchServer(int id) async {
    final data = await _getJson('/servers/$id');
    return Server.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<Metric>> fetchMetrics(int serverId,
      {int minutes = 30}) async {
    final data =
        await _getJson('/servers/$serverId/metrics?minutes=$minutes')
            as List<dynamic>;
    return data
        .map((json) => Metric.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Incident>> fetchIncidents(int serverId) async {
    final data =
        await _getJson('/servers/$serverId/incidents') as List<dynamic>;
    return data
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addServer(String name, String ip) async {
    final response = await http.post(
      Uri.parse('$baseUrl/servers'),
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    if (response.statusCode != 201) {
      throw Exception('POST /servers -> code ${response.statusCode}');
    }
  }

  static Future<void> deleteServer(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/servers/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('DELETE /servers/$id -> code ${response.statusCode}');
    }
  }

    static Future<void> updateServer(int id, String name, String ip) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servers/$id'),
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    if (response.statusCode != 200) {
      throw Exception('PUT /servers/$id -> code ${response.statusCode}');
    }
  }
}