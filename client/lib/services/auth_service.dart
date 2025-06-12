import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Web için localhost
  static const String baseUrl = 'http://localhost:5000/api';
  // Android Emulator için 10.0.2.2 kullanın
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        // Store the token
        await _prefs.setString('jwt_token', response.headers['set-cookie'] ?? '');
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // Store the token
        await _prefs.setString('jwt_token', response.headers['set-cookie'] ?? '');
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
      final token = _prefs.getString('jwt_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': token,
        },
      );

      if (response.statusCode == 200) {
        await _prefs.remove('jwt_token');
      } else {
        throw 'Logout failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = _prefs.getString('jwt_token');
      if (token == null) throw 'Not authenticated';

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': token,
        },
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

  bool get isAuthenticated => _prefs.containsKey('jwt_token');
} 