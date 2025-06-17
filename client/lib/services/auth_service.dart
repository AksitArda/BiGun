import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

class AuthService {
  // Web için localhost
  static const String baseUrl = 'http://localhost:5000/api';
  // Android Emulator için 10.0.2.2 kullanın
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  static const String _tokenKey = 'jwt_token';
  final SharedPreferences _prefs;
  final ApiService _api;

  AuthService(this._prefs) : _api = ApiService() {
    _api.initialize(_prefs);
  }

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
      final response = await _api.post('auth/register', body: {
        'username': username,
        'email': email,
        'password': password,
      });

      final token = response['token'];
      if (token != null) {
        await _saveToken(token);
      }
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('auth/login', body: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      if (token != null) {
        await _saveToken(token);
      }
      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('auth/logout');
      await _removeToken();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      if (!isAuthenticated) throw 'Not authenticated';
      return await _api.get('auth/me');
    } catch (e) {
      throw e.toString();
    }
  }
} 