import 'package:flutter/material.dart';

import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
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


  AddressEntity? _selectedAddress;

  AddressEntity? get selectedAddress =>
      _selectedAddress;

  String? get addressId =>
      _selectedAddress?.id;

  String? get shippingAddress =>
      _selectedAddress?.address;

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
        _selectedAddress != null &&
        _selectedAddress!
            .id
            .isNotEmpty &&
        !_isLoading;
  }


  void initialize({
    required List<CartItemEntity> items,
    AddressEntity? selectedAddress,
  }) {
    _cartItems =
    List<CartItemEntity>.from(
      items,
    );

    _selectedAddress =
        selectedAddress;

    _paymentMethod = 'online';

    _shippingCost = 0;

    _error = null;

    _order = null;

    _isLoading = false;

    notifyListeners();
  }


  void setAddress(
      AddressEntity address,
      ) {
    _selectedAddress = address;

    _error = null;

    notifyListeners();
  }

  void clearAddress() {
    _selectedAddress = null;

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
      'لطفاً یک آدرس برای ارسال انتخاب کنید';

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

        // مهم
        addressId:
        _selectedAddress!.id,

        subtotal:
        subtotal,

        discount:
        totalDiscount,

        shippingCost:
        shippingCost,

        totalPrice:
        totalPrice,

        // Snapshot آدرس در زمان ثبت سفارش
        shippingAddress:
        _selectedAddress!.address,

        paymentMethod:
        _paymentMethod,

        items:
        orderItems,
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

  void reset() {
    _cartItems = [];

    _selectedAddress = null;

    _paymentMethod = 'online';

    _shippingCost = 0;

    _isLoading = false;

    _error = null;

    _order = null;

    notifyListeners();
  }
}