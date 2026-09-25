import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_manager_entity.dart';
import '../../domain/usecases/find_profile_by_phone.dart';
import '../../domain/usecases/get_admin_managers.dart';
import '../../domain/usecases/remove_manager.dart';
import '../../domain/usecases/update_manager.dart';
import '../../domain/usecases/update_manager_status.dart';

class AdminManagersProvider extends ChangeNotifier {
  AdminManagersProvider({
    required GetAdminManagers getAdminManagers,
    required FindProfileByPhone findProfileByPhone,
    required UpdateManager updateManager,
    required RemoveManager removeManager,
    required UpdateManagerStatus updateManagerStatus,
  })  : _getAdminManagers = getAdminManagers,
        _findProfileByPhone = findProfileByPhone,
        _updateManager = updateManager,
        _removeManager = removeManager,
        _updateManagerStatus = updateManagerStatus;

  final GetAdminManagers _getAdminManagers;
  final FindProfileByPhone _findProfileByPhone;
  final UpdateManager _updateManager;
  final RemoveManager _removeManager;
  final UpdateManagerStatus _updateManagerStatus;

  List<AdminManagerEntity> _managers = [];

  List<AdminManagerEntity> get managers =>
      List.unmodifiable(_managers);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadManagers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _managers = await _getAdminManagers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AdminManagerEntity?> findProfileByPhone({
    required String phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _findProfileByPhone(
        phone: phone,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateManager({
    required String userId,
    required String adminRole,
    required bool isActive,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedManager = await _updateManager(
        userId: userId,
        adminRole: adminRole,
        isActive: isActive,
      );

      final index = _managers.indexWhere(
            (manager) => manager.id == userId,
      );

      if (index != -1) {
        _managers[index] = updatedManager;
      } else {
        _managers.insert(0, updatedManager);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeManager({
    required String userId,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _removeManager(
        userId: userId,
      );

      _managers.removeWhere(
            (manager) => manager.id == userId,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateManagerStatus({
    required String userId,
    required bool isActive,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedManager =
      await _updateManagerStatus(
        userId: userId,
        isActive: isActive,
      );

      final index = _managers.indexWhere(
            (manager) => manager.id == userId,
      );

      if (index != -1) {
        _managers[index] = updatedManager;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}