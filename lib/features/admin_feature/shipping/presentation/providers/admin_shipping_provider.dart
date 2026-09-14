import 'package:flutter/foundation.dart';

import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/domain/usecases/create_admin_shipping_method.dart';
import 'package:supastore/features/admin_feature/shipping/domain/usecases/delete_admin_shipping_method.dart';
import 'package:supastore/features/admin_feature/shipping/domain/usecases/get_admin_shipping_methods.dart';
import 'package:supastore/features/admin_feature/shipping/domain/usecases/update_admin_shipping_method.dart';

class AdminShippingProvider extends ChangeNotifier {
  AdminShippingProvider({
    required GetAdminShippingMethods getShippingMethods,
    required CreateAdminShippingMethod createShippingMethod,
    required UpdateAdminShippingMethod updateShippingMethod,
    required DeleteAdminShippingMethod deleteShippingMethod,
  })  : _getShippingMethods = getShippingMethods,
        _createShippingMethod = createShippingMethod,
        _updateShippingMethod = updateShippingMethod,
        _deleteShippingMethod = deleteShippingMethod;

  final GetAdminShippingMethods _getShippingMethods;
  final CreateAdminShippingMethod _createShippingMethod;
  final UpdateAdminShippingMethod _updateShippingMethod;
  final DeleteAdminShippingMethod _deleteShippingMethod;

  List<AdminShippingMethodEntity> _shippingMethods = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  String? _error;

  List<AdminShippingMethodEntity> get shippingMethods =>
      List.unmodifiable(_shippingMethods);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get isDeleting => _isDeleting;

  bool get isBusy =>
      _isLoading || _isSaving || _isDeleting;

  String? get error => _error;

  bool get hasShippingMethods =>
      _shippingMethods.isNotEmpty;

  int get activeShippingMethods {
    return _shippingMethods
        .where((method) => method.isActive)
        .length;
  }

  int get inactiveShippingMethods {
    return _shippingMethods
        .where((method) => !method.isActive)
        .length;
  }

  Future<void> loadShippingMethods() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _shippingMethods =
      await _getShippingMethods();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createShippingMethod({
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _error = null;

    notifyListeners();

    try {
      final created =
      await _createShippingMethod(
        title: title,
        description: description,
        cost: cost,
        estimatedDays: estimatedDays,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      _shippingMethods = [
        ..._shippingMethods,
        created,
      ];

      _sortShippingMethods();

      _isSaving = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isSaving = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateShippingMethod({
    required String id,
    required String title,
    String? description,
    required int cost,
    String? estimatedDays,
    required bool isActive,
    required int sortOrder,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _error = null;

    notifyListeners();

    try {
      final updated =
      await _updateShippingMethod(
        id: id,
        title: title,
        description: description,
        cost: cost,
        estimatedDays: estimatedDays,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      final index = _shippingMethods.indexWhere(
            (method) => method.id == id,
      );

      if (index != -1) {
        final updatedList =
        List<AdminShippingMethodEntity>.from(
          _shippingMethods,
        );

        updatedList[index] = updated;

        _shippingMethods = updatedList;

        _sortShippingMethods();
      }

      _isSaving = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isSaving = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> toggleShippingMethod(
      AdminShippingMethodEntity method,
      ) async {
    return updateShippingMethod(
      id: method.id,
      title: method.title,
      description: method.description,
      cost: method.cost,
      estimatedDays: method.estimatedDays,
      isActive: !method.isActive,
      sortOrder: method.sortOrder,
    );
  }

  Future<bool> deleteShippingMethod({
    required String id,
  }) async {
    if (_isDeleting) {
      return false;
    }

    _isDeleting = true;
    _error = null;

    notifyListeners();

    try {
      await _deleteShippingMethod(
        id: id,
      );

      _shippingMethods = _shippingMethods
          .where(
            (method) => method.id != id,
      )
          .toList();

      _isDeleting = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isDeleting = false;

      notifyListeners();

      return false;
    }
  }

  Future<void> refresh() async {
    await loadShippingMethods();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _sortShippingMethods() {
    _shippingMethods.sort(
          (a, b) {
        final sortComparison =
        a.sortOrder.compareTo(b.sortOrder);

        if (sortComparison != 0) {
          return sortComparison;
        }

        return b.createdAt.compareTo(
          a.createdAt,
        );
      },
    );
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}