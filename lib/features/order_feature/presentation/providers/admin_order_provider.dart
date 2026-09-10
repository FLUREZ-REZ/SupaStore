import 'package:flutter/foundation.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

class AdminOrderProvider extends ChangeNotifier {
  AdminOrderProvider({
    required OrderRepository repository,
  }) : _repository = repository;

  final OrderRepository _repository;

  List<OrderEntity> _orders = [];

  bool _isLoading = false;
  bool _isUpdating = false;

  String? _error;

  List<OrderEntity> get orders =>
      List.unmodifiable(_orders);

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  String? get error => _error;

  Future<void> loadOrders() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final result = await _repository.getAllOrders();

      _orders = result;
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> refreshOrders() async {
    try {
      final result = await _repository.getAllOrders();

      _orders = result;
      _error = null;
    } catch (e) {
      _error = _cleanError(e);
    }

    notifyListeners();
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final updatedOrder =
      await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      final index = _orders.indexWhere(
            (order) => order.id == orderId,
      );

      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      _isUpdating = false;

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}