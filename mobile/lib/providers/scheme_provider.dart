import 'package:flutter/material.dart';
import '../api/api_service.dart';

class SchemeProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _recommendation;
  List<dynamic> _schemes = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get recommendation => _recommendation;
  List<dynamic> get schemes => _schemes;

  Future<void> getRecommendation(Map<String, dynamic> input) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getRecommendation(input);
      if (result['success'] == true) {
        _recommendation = result['recommendation'];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchemes() async {
    _schemes = await ApiService.getSchemes();
    notifyListeners();
  }

  void clearRecommendation() {
    _recommendation = null;
    notifyListeners();
  }
}
