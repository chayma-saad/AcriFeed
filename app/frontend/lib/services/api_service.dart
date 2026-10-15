import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  // For mobile/emulator, use: 'http://10.0.2.2:5000/api' (Android) or 'http://localhost:5000/api' (iOS)

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // Auth
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await post('/auth/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Login failed: ${response.body}');
  }

  // Predictions
  Future<Map<String, dynamic>> getLatestPrediction() async {
    final response = await get('/predictions/latest');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get prediction: ${response.body}');
  }

  Future<Map<String, dynamic>> createPrediction(Map<String, dynamic> data) async {
    final response = await post('/predictions', data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create prediction: ${response.body}');
  }

  Future<List<dynamic>> getPredictions({DateTime? startDate, DateTime? endDate}) async {
    String url = '/predictions?';
    if (startDate != null) url += 'startDate=${startDate.toIso8601String()}&';
    if (endDate != null) url += 'endDate=${endDate.toIso8601String()}&';
    
    final response = await get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get predictions: ${response.body}');
  }

  // Environmental Data
  Future<Map<String, dynamic>> getLatestEnvironmentalData() async {
    final response = await get('/environmental/latest');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get environmental data: ${response.body}');
  }

  Future<List<dynamic>> getEnvironmentalData({DateTime? startDate, DateTime? endDate}) async {
    String url = '/environmental?';
    if (startDate != null) url += 'startDate=${startDate.toIso8601String()}&';
    if (endDate != null) url += 'endDate=${endDate.toIso8601String()}&';
    
    final response = await get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get environmental data: ${response.body}');
  }

  // History
  Future<List<dynamic>> getHistory({DateTime? startDate, DateTime? endDate}) async {
    String url = '/history?';
    if (startDate != null) url += 'startDate=${startDate.toIso8601String()}&';
    if (endDate != null) url += 'endDate=${endDate.toIso8601String()}&';
    
    final response = await get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get history: ${response.body}');
  }

  // Chatbot
  Future<String> askChatbot(String question, {String? context}) async {
    final response = await post('/chatbot/ask', {
      'question': question,
      'context': context,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? '';
    }
    throw Exception('Failed to get chatbot response: ${response.body}');
  }

  // Notifications
  Future<List<dynamic>> getNotifications({bool unreadOnly = false}) async {
    final response = await get('/notifications?unreadOnly=$unreadOnly');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get notifications: ${response.body}');
  }

  Future<void> markNotificationAsRead(int id) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }
}

