import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, dynamic>> login(String aadhaarHash) async {
    final response = await http.post(Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'}, body: jsonEncode({'aadhaar_hash': aadhaarHash}));
    final result = jsonDecode(response.body);
    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('user', jsonEncode(result['user']));
    }
    return result;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(), body: jsonEncode(data));
    final result = jsonDecode(response.body);
    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('user', jsonEncode(result['user']));
    }
    return result;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    return userStr != null ? jsonDecode(userStr) : {};
  }

  static Future<Map<String, dynamic>> getRecommendation(Map<String, dynamic> input) async {
    final response = await http.post(Uri.parse('$baseUrl/schemes/recommend'),
      headers: await _getHeaders(), body: jsonEncode(input));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> calculateLoan(Map<String, dynamic> params) async {
    final response = await http.post(Uri.parse('$baseUrl/calculate'),
      headers: await _getHeaders(), body: jsonEncode(params));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> findPartners(double lat, double lng, String schemeCode) async {
    final response = await http.get(Uri.parse('$baseUrl/partners/nearby?lat=$lat&lng=$lng&scheme=$schemeCode&limit=5'),
      headers: await _getHeaders());
    final result = jsonDecode(response.body);
    return result['partners'] ?? [];
  }

  static Future<Map<String, dynamic>> getApplicationStatus(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/applications/$id/status'),
      headers: await _getHeaders());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createApplication(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/applications'),
      headers: await _getHeaders(), body: jsonEncode(data));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitApplication(int id) async {
    final response = await http.post(Uri.parse('$baseUrl/applications/$id/submit'),
      headers: await _getHeaders());
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getApplications() async {
    final response = await http.get(Uri.parse('$baseUrl/applications'), headers: await _getHeaders());
    final result = jsonDecode(response.body);
    return result['applications'] ?? [];
  }

  static Future<List<dynamic>> getSchemes() async {
    final response = await http.get(Uri.parse('$baseUrl/schemes'), headers: await _getHeaders());
    final result = jsonDecode(response.body);
    return result['schemes'] ?? [];
  }
}
