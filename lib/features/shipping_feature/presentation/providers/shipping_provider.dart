import 'package:flutter/material.dart';
import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';
import 'package:supastore/features/shipping_feature/domain/repositories/shipping_repository.dart';

class ShippingProvider extends ChangeNotifier {
  ShippingProvider({
    required ShippingRepository repository,
  }) : _repository = repository;

  final ShippingRepository _repository;

  // ============================================================
  // STATE
  // ============================================================

  List<ShippingMethodEntity> _shippingMethods = [];

  ShippingMethodEntity? _selectedShippingMethod;

  bool _isLoading = false;

  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  List<ShippingMethodEntity> get shippingMethods =>
      List.unmodifiable(_shippingMethods);

  ShippingMethodEntity? get selectedShippingMethod =>
      _selectedShippingMethod;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasShippingMethods =>
      _shippingMethods.isNotEmpty;

  bool get hasSelectedShippingMethod =>
      _selectedShippingMethod != null;

  int get shippingCost =>
      _selectedShippingMethod?.cost ?? 0;

  // ============================================================
  // LOAD SHIPPING METHODS
  // ============================================================

  Future<void> loadShippingMethods() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getShippingMethods();

      _shippingMethods = result;

      // اگر هنوز روشی انتخاب نشده،
      // اولین روش فعال را به صورت پیش‌فرض انتخاب می‌کنیم.
      if (_selectedShippingMethod == null &&
          _shippingMethods.isNotEmpty) {
        _selectedShippingMethod =
            _shippingMethods.first;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // SELECT SHIPPING METHOD
  // ============================================================

  void selectShippingMethod(
      ShippingMethodEntity method,
      ) {
    _selectedShippingMethod = method;

    _error = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED METHOD
  // ============================================================

  void clearSelection() {
    _selectedShippingMethod = null;

    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    _selectedShippingMethod = null;

    await loadShippingMethods();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _shippingMethods = [];

    _selectedShippingMethod = null;

    _isLoading = false;

    _error = null;

    notifyListeners();
  }
}