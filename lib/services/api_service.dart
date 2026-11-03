import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/incident.dart';
import '../models/metric.dart';
import '../models/server.dart';

class UnauthorizedException implements Exception {
  @override
  String toString() => 'Session expirée, reconnecte-toi';
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static String? _token;
  static final ValueNotifier<bool> authenticated = ValueNotifier(false);

  static Map<String, String> get _headers => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Map<String, String> get _jsonHeaders =>
      {..._headers, 'Content-Type': 'application/json'};

  static void logout() {
    _token = null;
    authenticated.value = false;
  }

  /// Renvoie false si l'identifiant ou le mot de passe est incorrect.
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 401) return false;
    if (response.statusCode != 200) {
      throw Exception('POST /auth/login -> code ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = data['token'] as String;
    authenticated.value = true;
    return true;
  }

  static void _check(http.Response response, int expected, String label) {
    if (response.statusCode == 401) {
      logout();
      throw UnauthorizedException();
    }
    if (response.statusCode != expected) {
      throw Exception('$label -> code ${response.statusCode}');
    }
  }

  static Future<dynamic> _getJson(String path) async {
    final response =
        await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    _check(response, 200, 'GET $path');
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
      headers: _jsonHeaders,
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    _check(response, 201, 'POST /servers');
  }

  static Future<void> updateServer(int id, String name, String ip) async {
    final response = await http.put(
      Uri.parse('$baseUrl/servers/$id'),
      headers: _jsonHeaders,
      body: jsonEncode({'name': name, 'ip': ip}),
    );
    _check(response, 200, 'PUT /servers/$id');
  }

  static Future<void> deleteServer(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/servers/$id'),
      headers: _headers,
    );
    _check(response, 204, 'DELETE /servers/$id');
  }
}