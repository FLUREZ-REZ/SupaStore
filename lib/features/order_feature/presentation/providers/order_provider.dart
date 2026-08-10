import 'package:flutter/material.dart';

import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    required OrderRepository repository,
  }) : _repository = repository;

  final OrderRepository _repository;

  // ============================================================
  // Orders
  // ============================================================

  List<OrderEntity> _orders = [];

  List<OrderEntity> get orders =>
      List.unmodifiable(_orders);

  // ============================================================
  // Loading
  // ============================================================

  bool _isLoading = false;

  bool get isLoading =>
      _isLoading;

  // ============================================================
  // Error
  // ============================================================

  String? _error;

  String? get error =>
      _error;

  // ============================================================
  // Load Orders
  // ============================================================

  Future<void> loadOrders(
      String userId,
      ) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getUserOrders(
        userId,
      );

      _orders = result;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // Refresh
  // ============================================================

  Future<void> refreshOrders(
      String userId,
      ) async {
    try {
      final result =
      await _repository.getUserOrders(
        userId,
      );

      _orders = result;

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  // ============================================================
  // Clear Error
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}