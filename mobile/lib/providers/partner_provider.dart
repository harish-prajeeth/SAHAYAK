import 'package:flutter/material.dart';
import '../api/api_service.dart';

class PartnerProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _partners = [];
  List<dynamic> _nearbyPartners = [];

  bool get isLoading => _isLoading;
  List<dynamic> get partners => _partners;
  List<dynamic> get nearbyPartners => _nearbyPartners;

  Future<void> findNearbyPartners(double lat, double lng, String schemeCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      _nearbyPartners = await ApiService.findPartners(lat, lng, schemeCode);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNearby() {
    _nearbyPartners = [];
    notifyListeners();
  }
}
