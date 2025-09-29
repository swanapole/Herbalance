import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiClient {
  final String baseUrl;
  const ApiClient({this.baseUrl = AppConfig.baseUrl});

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> createOrUpdateUser({
    required String email,
    String region = 'KE',
    String language = 'en',
    Map<String, dynamic>? consents,
  }) async {
    final resp = await http.post(
      _uri('/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'region': region,
        'language': language,
        'consents': consents ?? {},
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create user: ${resp.statusCode} ${resp.body}');
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    final resp = await http.get(_uri('/api/users/$id'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get user: ${resp.statusCode}');
  }

  Future<void> deleteUser(String id) async {
    final resp = await http.delete(_uri('/api/users/$id'));
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete user: ${resp.statusCode}');
    }
  }

  Future<Map<String, dynamic>> exportUser(String id) async {
    final resp = await http.get(_uri('/api/users/$id/export'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to export user: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> createAssessment({
    required String userId,
    required String type,
    required Map<String, dynamic> answers,
    double? riskScore,
    String? explanation,
  }) async {
    final resp = await http.post(
      _uri('/api/assessments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'type': type,
        'answers': answers,
        if (riskScore != null) 'riskScore': riskScore,
        if (explanation != null) 'explanation': explanation,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create assessment: ${resp.statusCode} ${resp.body}');
  }

  Future<List<Map<String, dynamic>>> listAssessments(String userId) async {
    final resp = await http.get(_uri('/api/assessments/user/$userId'));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to list assessments: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> createAlert({
    required String userId,
    required String type,
    required DateTime scheduleAt,
  }) async {
    final resp = await http.post(
      _uri('/api/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'type': type,
        'scheduleAt': scheduleAt.toIso8601String(),
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create alert: ${resp.statusCode} ${resp.body}');
  }

  Future<List<Map<String, dynamic>>> listAlerts(String userId) async {
    final resp = await http.get(_uri('/api/alerts/user/$userId'));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to list alerts: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getResourcesKE() async {
    final resp = await http.get(_uri('/api/resources'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load resources: ${resp.statusCode}');
  }
}
