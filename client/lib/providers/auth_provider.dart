import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  AuthProvider(SharedPreferences prefs)
      : _authService = AuthService(prefs) {
    _isAuthenticated = _authService.isAuthenticated;
    if (_isAuthenticated) {
      _loadUser();
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      _user = response['user'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      _user = response['user'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadUser() async {
    try {
      final response = await _authService.getCurrentUser();
      _user = response['user'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Otomatik giriş kontrolü
  Future<void> checkAuthStatus() async {
    try {
      if (_authService.isAuthenticated) {
        await _loadUser();
      }
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }
} 