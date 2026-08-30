import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  User? get user => _user;
  bool get isLoading => _isLoading;

  void loadUser() async {
    final userData = await ApiService.getUser();
    if (userData.isNotEmpty) {
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  Future<void> login(String aadhaarHash) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.login(aadhaarHash);
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    notifyListeners();
  }
}
