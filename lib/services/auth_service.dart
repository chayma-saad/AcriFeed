import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? _username;
  String? _fullName;
  String? _role;
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get username => _username;
  String? get fullName => _fullName;
  String? get role => _role;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      
      _token = response['token'];
      _username = response['username'];
      _fullName = response['fullName'];
      _role = response['role'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setString('fullName', _fullName ?? '');
      await prefs.setString('role', _role ?? 'staff');

      notifyListeners();
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed to fetch') || errorMsg.contains('Connection refused')) {
        debugPrint('Login error: Backend server is not running. Please start the API server.');
      } else {
        debugPrint('Login error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _fullName = null;
    _role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('fullName');
    await prefs.remove('role');

    notifyListeners();
  }

  Future<void> loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
    _fullName = prefs.getString('fullName');
    _role = prefs.getString('role');
    notifyListeners();
  }
}

