// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final access = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': access.isNotEmpty ? 'Bearer $access' : '',
    };
  }

  /// Generic GET with automatic token refresh attempt on 401
  static Future<http.Response> _getWithAuth(String endpoint) async {
    final uri = Uri.parse('${AuthService.baseUrl}$endpoint');
    final headers = await _authHeaders();
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 401) {
      final refreshed = await AuthService.tryRefreshToken();
      if (refreshed) {
        final headers2 = await _authHeaders();
        return await http.get(uri, headers: headers2);
      }
    }
    return resp;
  }

  static Future<List<dynamic>> getAnnouncements() async {
    final resp = await _getWithAuth('/announcements/');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load announcements: ${resp.statusCode} ${resp.body}');
    }
  }

  static Future<List<dynamic>> getTimetable() async {
    final resp = await _getWithAuth('/timetable/');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load timetable: ${resp.statusCode} ${resp.body}');
    }
  }
}
