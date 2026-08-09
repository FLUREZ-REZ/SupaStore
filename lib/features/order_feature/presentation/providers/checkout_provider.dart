import 'package:flutter/material.dart';

import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({
    required OrderRepository repository,
    required CartProvider cartProvider,
  })  : _repository = repository,
        _cartProvider = cartProvider;

  final OrderRepository _repository;
  final CartProvider _cartProvider;

  List<CartItemEntity> _cartItems = [];

  List<CartItemEntity> get cartItems =>
      List.unmodifiable(_cartItems);

  String? _shippingAddress;

  String? get shippingAddress =>
      _shippingAddress;

  String _paymentMethod = 'online';

  String get paymentMethod =>
      _paymentMethod;

  int _shippingCost = 0;

  int get shippingCost =>
      _shippingCost;

  bool _isLoading = false;

  bool get isLoading =>
      _isLoading;

  String? _error;

  String? get error =>
      _error;

  OrderEntity? _order;

  OrderEntity? get order =>
      _order;

  int get totalItems {
    return _cartItems.fold(
      0,
          (sum, item) =>
      sum + item.quantity,
    );
  }

  int get subtotal {
    return _cartItems.fold(
      0,
          (sum, item) =>
      sum +
          (item.product.price *
              item.quantity),
    );
  }

  int get totalDiscount {
    return _cartItems.fold(
      0,
          (sum, item) {
        final product =
            item.product;

        if (product.discountPrice ==
            null) {
          return sum;
        }

        final discount =
            product.price -
                product.discountPrice!;

        return sum +
            (discount *
                item.quantity);
      },
    );
  }

  int get totalPrice {
    return subtotal -
        totalDiscount +
        shippingCost;
  }

  bool get canSubmit {
    return _cartItems.isNotEmpty &&
        _shippingAddress != null &&
        _shippingAddress!
            .trim()
            .isNotEmpty &&
        !_isLoading;
  }

  void initialize({
    required List<CartItemEntity> items,
  }) {
    _cartItems =
    List<CartItemEntity>.from(
      items,
    );

    _shippingAddress = null;

    _paymentMethod = 'online';

    _shippingCost = 0;

    _error = null;

    _order = null;

    _isLoading = false;

    notifyListeners();
  }

  void setShippingAddress(
      String address,
      ) {
    _shippingAddress =
        address.trim();

    notifyListeners();
  }

  void setPaymentMethod(
      String method,
      ) {
    _paymentMethod = method;

    notifyListeners();
  }

  void setShippingCost(
      int cost,
      ) {
    if (cost < 0) {
      return;
    }

    _shippingCost = cost;

    notifyListeners();
  }

  Future<bool> placeOrder({
    required String userId,
  }) async {
    if (!canSubmit) {
      _error =
      'لطفاً اطلاعات سفارش را کامل کنید';

      notifyListeners();

      return false;
    }

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {

      final orderItems =
      _cartItems.map(
            (item) {
          final product =
              item.product;

          final unitPrice =
              product.finalPrice;

          return OrderItemEntity(
            id: '',
            orderId: '',
            productId:
            product.id,
            productTitle:
            product.title,
            productThumbnail:
            product.thumbnail,
            quantity:
            item.quantity,
            unitPrice:
            unitPrice,
            discountPrice:
            product.discountPrice,
            totalPrice:
            unitPrice *
                item.quantity,
            createdAt:
            DateTime.now(),
          );
        },
      ).toList();

      final createdOrder =
      await _repository.checkout(
        userId: userId,
        subtotal: subtotal,
        discount:
        totalDiscount,
        shippingCost:
        shippingCost,
        totalPrice:
        totalPrice,
        shippingAddress:
        _shippingAddress!,
        paymentMethod:
        _paymentMethod,
        items: orderItems,
      );

      _order = createdOrder;

      await _cartProvider.clearCart(
        userId,
      );

      _cartItems.clear();

      _isLoading = false;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _isLoading = false;

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }
}