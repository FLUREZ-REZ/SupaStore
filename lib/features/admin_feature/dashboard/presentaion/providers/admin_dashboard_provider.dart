import 'package:flutter/foundation.dart';

import 'package:supastore/features/admin_feature/dashboard/domain/entities/admin_dashboard_entity.dart';
import 'package:supastore/features/admin_feature/dashboard/domain/repositories/admin_dashboard_repository.dart';

class AdminDashboardProvider extends ChangeNotifier {
  AdminDashboardProvider({
    required AdminDashboardRepository repository,
  }) : _repository = repository;

  final AdminDashboardRepository _repository;

  AdminDashboardEntity? _dashboard;

  bool _isLoading = false;

  String? _error;

  AdminDashboardEntity? get dashboard =>
      _dashboard;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  bool get hasData =>
      _dashboard != null;

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _repository.getDashboardData();
    } catch (e, stackTrace) {
      debugPrint(
        '================ DASHBOARD ERROR ================',
      );

      debugPrint(e.toString());

      debugPrint(
        stackTrace.toString(),
      );

      debugPrint(
        '==================================================',
      );

      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    _error = null;

    notifyListeners();

    try {
      _dashboard =
      await _repository.getDashboardData();
    } catch (e) {
      _error =
          e.toString();

      notifyListeners();
    }
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }
}