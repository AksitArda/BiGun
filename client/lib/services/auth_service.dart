import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Web için localhost
  static const String baseUrl = 'http://localhost:5000/api';
  // Android Emulator için 10.0.2.2 kullanın
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  static const String _tokenKey = 'jwt_token';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Token yönetimi
  String? get token => _prefs.getString(_tokenKey);
  bool get isAuthenticated => token != null;

  Future<void> _saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> _removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // HTTP Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        final token = response.headers['authorization']?.split('Bearer ')?.last ??
                     data['token'];
        if (token != null) {
          await _saveToken(token);
        }
        return data;
      } else {
        throw data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final token = response.headers['authorization']?.split('Bearer ')?.last ??
                     data['token'];
        if (token != null) {
          await _saveToken(token);
        }
        return data;
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        await _removeToken();
      } else {
        throw 'Logout failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      if (!isAuthenticated) throw 'Not authenticated';

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Failed to get user data';
      }
    } catch (e) {
      throw e.toString();
    }
  }
} 