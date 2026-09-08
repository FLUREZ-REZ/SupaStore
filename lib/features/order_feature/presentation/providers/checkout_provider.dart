import 'package:flutter/material.dart';

import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/order_feature/domain/entities/checkout_result_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

import 'package:supastore/features/payment_feature/domain/entities/payment_entity.dart';
import 'package:supastore/features/payment_feature/domain/repositories/payment_repository.dart';

import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({
    required OrderRepository repository,
    required PaymentRepository paymentRepository,
    required CartProvider cartProvider,
  })  : _repository = repository,
        _paymentRepository = paymentRepository,
        _cartProvider = cartProvider;

  final OrderRepository _repository;
  final PaymentRepository _paymentRepository;
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

  ShippingMethodEntity? _selectedShippingMethod;

  ShippingMethodEntity? get selectedShippingMethod =>
      _selectedShippingMethod;

  String? get shippingMethodId =>
      _selectedShippingMethod?.id;

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

  CheckoutResultEntity? _checkoutResult;

  CheckoutResultEntity? get checkoutResult =>
      _checkoutResult;

  PaymentEntity? _payment;

  PaymentEntity? get payment =>
      _payment;

  bool _isPaymentChecking = false;

  bool get isPaymentChecking =>
      _isPaymentChecking;

  int get totalItems {
    return _cartItems.fold(
      0,
          (sum, item) {
        return sum + item.quantity;
      },
    );
  }

  int get subtotal {
    return _cartItems.fold(
      0,
          (sum, item) {
        return sum +
            (item.product.price * item.quantity);
      },
    );
  }

  int get totalDiscount {
    return _cartItems.fold(
      0,
          (sum, item) {
        final product = item.product;

        if (product.discountPrice == null) {
          return sum;
        }

        final discount =
            product.price -
                product.discountPrice!;

        return sum +
            (discount * item.quantity);
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
        _selectedAddress!.id.isNotEmpty &&
        _selectedShippingMethod != null &&
        _selectedShippingMethod!.id.isNotEmpty &&
        _paymentMethod == 'online' &&
        !_isLoading;
  }

  void initialize({
    required List<CartItemEntity> items,
    AddressEntity? selectedAddress,
  }) {
    _cartItems =
    List<CartItemEntity>.from(items);

    _selectedAddress =
        selectedAddress;

    _selectedShippingMethod = null;

    _paymentMethod = 'online';

    _shippingCost = 0;

    _error = null;

    _checkoutResult = null;

    _payment = null;

    _isLoading = false;

    _isPaymentChecking = false;

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

    _error = null;

    notifyListeners();
  }

  void setShippingMethod(
      ShippingMethodEntity method,
      ) {
    _selectedShippingMethod = method;

    _shippingCost = method.cost;

    _error = null;

    notifyListeners();
  }

  void clearShippingMethod() {
    _selectedShippingMethod = null;

    _shippingCost = 0;

    _error = null;

    notifyListeners();
  }

  void setPaymentMethod(
      String method,
      ) {
    if (method != 'online') {
      _error =
      'روش پرداخت انتخاب‌شده پشتیبانی نمی‌شود.';

      notifyListeners();

      return;
    }

    _paymentMethod = method;

    _error = null;

    notifyListeners();
  }

  Future<CheckoutResultEntity?> createCheckout() async {
    if (!canSubmit) {
      _error =
      'لطفاً آدرس و روش ارسال را انتخاب کنید.';

      notifyListeners();

      return null;
    }

    _isLoading = true;

    _error = null;

    _checkoutResult = null;

    notifyListeners();

    try {
      final result =
      await _repository.createCheckout(
        addressId: _selectedAddress!.id,
        shippingMethodId:
        _selectedShippingMethod!.id,
        paymentMethod: _paymentMethod,
      );

      _checkoutResult = result;

      _isLoading = false;

      notifyListeners();

      return result;
    } catch (e) {
      _error = _cleanError(e);

      _isLoading = false;

      notifyListeners();

      return null;
    }
  }

  Future<PaymentEntity?> checkPaymentStatus({
    required String orderId,
  }) async {
    if (orderId.trim().isEmpty) {
      _error =
      'شناسه سفارش نامعتبر است.';

      notifyListeners();

      return null;
    }

    if (_isPaymentChecking) {
      return _payment;
    }

    _isPaymentChecking = true;

    _error = null;

    notifyListeners();

    try {
      final payment =
      await _paymentRepository.getPaymentByOrder(
        orderId: orderId,
      );

      _payment = payment;

      _isPaymentChecking = false;

      notifyListeners();

      return payment;
    } catch (e) {
      _error = _cleanError(e);

      _isPaymentChecking = false;

      notifyListeners();

      return null;
    }
  }

  Future<bool> confirmPayment({
    required String orderId,
    required String userId,
  }) async {
    final payment =
    await checkPaymentStatus(
      orderId: orderId,
    );

    if (payment == null) {
      return false;
    }

    if (!payment.isPaid) {
      return false;
    }

    try {
      await _cartProvider.clearCart(
        userId,
      );

      _cartItems.clear();

      notifyListeners();

      return true;
    } catch (e) {
      _error =
      'پرداخت با موفقیت انجام شد، اما پاک‌سازی سبد خرید انجام نشد.';

      notifyListeners();

      return true;
    }
  }

  Future<PaymentEntity?> refreshPaymentStatus() async {
    final orderId =
        _checkoutResult?.orderId;

    if (orderId == null ||
        orderId.isEmpty) {
      return null;
    }

    return checkPaymentStatus(
      orderId: orderId,
    );
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  void reset() {
    _cartItems = [];

    _selectedAddress = null;

    _selectedShippingMethod = null;

    _paymentMethod = 'online';

    _shippingCost = 0;

    _isLoading = false;

    _isPaymentChecking = false;

    _error = null;

    _checkoutResult = null;

    _payment = null;

    notifyListeners();
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

  @override
  void dispose() {
    debugPrint(
      '!!!!!!!!!! CHECKOUT PROVIDER DISPOSE !!!!!!!!!!',
    );

    super.dispose();
  }
}