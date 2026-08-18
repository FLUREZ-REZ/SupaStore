import 'package:flutter/material.dart';

import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/cart_feature/domain/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required CartRepository repository,
  }) : _repository = repository;

  final CartRepository _repository;

  final List<CartItemEntity> _items = [];

  bool _isLoading = false;
  bool _isUpdating = false;

  String? _error;

  List<CartItemEntity> get items =>
      List.unmodifiable(_items);

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  String? get error => _error;

  int get totalItems {
    return _items.fold(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get subtotal {
    return _items.fold(
      0,
          (sum, item) {
        return sum +
            (item.product.price *
                item.quantity);
      },
    );
  }

  int get totalDiscount {
    return _items.fold(
      0,
          (sum, item) {
        final product = item.product;

        final discount =
            product.price -
                product.finalPrice;

        return sum +
            (discount * item.quantity);
      },
    );
  }

  int get totalPrice {
    return _items.fold(
      0,
          (sum, item) {
        return sum +
            (item.product.finalPrice *
                item.quantity);
      },
    );
  }

  Future<void> loadCart(
      String userId,
      ) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getCartItems(
        userId,
      );

      debugPrint('========== LOAD CART AFTER CHECKOUT ==========');
      debugPrint('Loaded cart items: ${result.length}');

      _items
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    _error = null;
    _isUpdating = true;

    notifyListeners();

    try {
      final existingIndex =
      _items.indexWhere(
            (item) =>
        item.productId == productId,
      );

      if (existingIndex != -1) {
        final existingItem =
        _items[existingIndex];

        final newQuantity =
            existingItem.quantity +
                quantity;

        final updatedItem =
        await _repository.updateQuantity(
          cartItemId: existingItem.id,
          quantity: newQuantity,
        );

        _items[existingIndex] =
            updatedItem;
      }

      else {
        final newItem =
        await _repository.addToCart(
          userId: userId,
          productId: productId,
          quantity: quantity,
        );

        _items.add(newItem);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isUpdating = false;

    notifyListeners();
  }
  Future<void> increaseQuantity(
      CartItemEntity item,
      ) async {
    final newQuantity =
        item.quantity + 1;

    await _updateItemQuantity(
      item,
      newQuantity,
    );
  }
  Future<void> decreaseQuantity(
      CartItemEntity item,
      ) async {
    if (item.quantity <= 1) {
      await removeFromCart(item.id);
      return;
    }

    final newQuantity =
        item.quantity - 1;

    await _updateItemQuantity(
      item,
      newQuantity,
    );
  }

  Future<void> _updateItemQuantity(
      CartItemEntity item,
      int quantity,
      ) async {
    if (quantity < 1) return;

    _error = null;
    _isUpdating = true;

    notifyListeners();

    try {
      final updatedItem =
      await _repository.updateQuantity(
        cartItemId: item.id,
        quantity: quantity,
      );

      final index =
      _items.indexWhere(
            (element) =>
        element.id == item.id,
      );

      if (index != -1) {
        _items[index] =
            updatedItem;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isUpdating = false;

    notifyListeners();
  }

  Future<void> removeFromCart(
      String cartItemId,
      ) async {
    _error = null;
    _isUpdating = true;

    notifyListeners();

    try {
      await _repository.removeFromCart(
        cartItemId,
      );

      _items.removeWhere(
            (item) =>
        item.id == cartItemId,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isUpdating = false;

    notifyListeners();
  }

  Future<void> clearCart(
      String userId,
      ) async {
    _error = null;
    _isUpdating = true;

    notifyListeners();

    try {
      await _repository.clearCart(
        userId,
      );

      _items.clear();
    } catch (e) {
      _error = e.toString();
    }

    _isUpdating = false;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }
}