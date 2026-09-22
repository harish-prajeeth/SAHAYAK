import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _lastError;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void loadUser() async {
    final userData = await ApiService.getUser();
    if (userData.isNotEmpty) {
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  Future<void> login(String aadhaarHash) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await ApiService.login(aadhaarHash);
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
      } else {
        _lastError = (result['error'] as String?) ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      _lastError = 'Cannot reach the server. Check that the API is running.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _lastError = null;
    notifyListeners();
  }
}
