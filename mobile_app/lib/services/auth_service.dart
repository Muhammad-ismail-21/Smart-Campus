// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  /// Login and store tokens + user metadata
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      // debug prints (remove later)
      // ignore: avoid_print
      print('AuthService.login: status=${response.statusCode}');
      // ignore: avoid_print
      print('AuthService.login: body=${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data);
        final user = data['user'];
        // store some user fields for quick access
        final prefs = await SharedPreferences.getInstance();
        if (user is Map<String, dynamic>) {
          if (user.containsKey('role')) await prefs.setString('role', user['role'].toString());
          if (user.containsKey('username')) await prefs.setString('username', user['username'].toString());
          if (user.containsKey('first_name')) await prefs.setString('first_name', user['first_name'].toString());
          if (user.containsKey('class_group_name')) await prefs.setString('class_group_name', user['class_group_name']?.toString() ?? '');
        }
        return {'success': true, 'user': user};
      } else {
        // show message from backend if present
        try {
          final body = jsonDecode(response.body);
          final msg = body['error'] ?? body['detail'] ?? 'Invalid credentials';
          return {'success': false, 'message': msg};
        } catch (_) {
          return {'success': false, 'message': 'Invalid credentials'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Is Django running?'};
    }
  }

  static Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.containsKey('access')) await prefs.setString('access_token', data['access']);
    if (data.containsKey('refresh')) await prefs.setString('refresh_token', data['refresh']);
  }

  /// Returns current access token (or empty string)
  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  /// Returns stored refresh token (or null)
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// Clear stored tokens + data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('role');
    await prefs.remove('username');
    await prefs.remove('first_name');
    await prefs.remove('class_group_name');
  }

  /// Try to refresh access token using refresh token.
  /// Returns true if refresh succeeded and access token saved.
  static Future<bool> tryRefreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    // Try common endpoints: /token/refresh/ (simplejwt) OR /login/refresh/ (custom)
    final candidates = [
      Uri.parse('$baseUrl/token/refresh/'),
      Uri.parse('$baseUrl/login/refresh/'),
    ];

    for (final uri in candidates) {
      try {
        final resp = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refresh}),
        );

        // 200 -> { access: "..." } or { access, refresh }
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final prefs = await SharedPreferences.getInstance();
          if (data.containsKey('access')) {
            await prefs.setString('access_token', data['access']);
            if (data.containsKey('refresh')) {
              await prefs.setString('refresh_token', data['refresh']);
            }
            // ignore: avoid_print
            print('AuthService.tryRefreshToken: refreshed via $uri');
            return true;
          }
        } else {
          // Non-200: try next candidate
          // ignore: avoid_print
          print('AuthService.tryRefreshToken: $uri returned ${resp.statusCode}');
        }
      } catch (e) {
        // network/parse error: continue to next
        // ignore: avoid_print
        print('AuthService.tryRefreshToken: error for $uri -> $e');
      }
    }

    // If reached here, refresh failed -> clear tokens
    await logout();
    return false;
  }
}
