import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/application.dart';

class ApplicationProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Application> _applications = [];
  Map<String, dynamic>? _applicationStatus;
  List<DisbursementStage> _disbursementStages = [];

  bool get isLoading => _isLoading;
  List<Application> get applications => _applications;
  Map<String, dynamic>? get applicationStatus => _applicationStatus;
  List<DisbursementStage> get disbursementStages => _disbursementStages;

  Future<void> loadApplications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final apps = await ApiService.getApplications();
      _applications = apps.map((a) => Application.fromJson(a)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getApplicationStatus(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getApplicationStatus(id);
      if (result['success'] == true) {
        _applicationStatus = result;
        final stages = result['disbursementChain'] ?? result['statusHistory'] ?? [];
        _disbursementStages = stages.map<DisbursementStage>((s) => DisbursementStage.fromJson(s)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.createApplication(data);
      await loadApplications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitApplication(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.submitApplication(id);
      await getApplicationStatus(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStatus() {
    _applicationStatus = null;
    _disbursementStages = [];
    notifyListeners();
  }
}
