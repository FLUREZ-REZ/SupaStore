import 'package:flutter/foundation.dart';
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

  // ============================================================
  // State
  // ============================================================

  List<CartItemEntity> _cartItems = [];

  AddressEntity? _selectedAddress;

  ShippingMethodEntity? _selectedShippingMethod;

  String _paymentMethod = 'online';

  String _selectedGateway = 'zarinpal';

  int _shippingCost = 0;

  bool _isLoading = false;

  String? _error;

  CheckoutResultEntity? _checkoutResult;

  PaymentEntity? _payment;

  bool _isPaymentChecking = false;

  // ============================================================
  // Getters
  // ============================================================

  List<CartItemEntity> get cartItems => _cartItems;

  AddressEntity? get selectedAddress => _selectedAddress;

  ShippingMethodEntity? get selectedShippingMethod =>
      _selectedShippingMethod;

  String get paymentMethod => _paymentMethod;

  String get selectedGateway => _selectedGateway;

  int get shippingCost => _shippingCost;

  bool get isLoading => _isLoading;

  String? get error => _error;

  CheckoutResultEntity? get checkoutResult => _checkoutResult;

  PaymentEntity? get payment => _payment;

  bool get isPaymentChecking => _isPaymentChecking;

  // ============================================================
  // Price Getters
  // ============================================================

  int get subtotal {
    int result = 0;

    for (final item in _cartItems) {
      result += item.product.price * item.quantity;
    }

    return result;
  }

  int get totalDiscount {
    int result = 0;

    for (final item in _cartItems) {
      final product = item.product;

      final difference =
          product.price - product.finalPrice;

      if (difference > 0) {
        result += difference * item.quantity;
      }
    }

    return result;
  }

  int get totalPrice {
    return subtotal - totalDiscount + _shippingCost;
  }

  // ============================================================
  // Can Submit
  // ============================================================

  bool get canSubmit {
    return _cartItems.isNotEmpty &&
        _selectedAddress != null &&
        _selectedAddress!.id.isNotEmpty &&
        _selectedShippingMethod != null &&
        _selectedShippingMethod!.id.isNotEmpty &&
        _paymentMethod == 'online' &&
        (_selectedGateway == 'zarinpal' ||
            _selectedGateway == 'sep') &&
        !_isLoading;
  }

  // ============================================================
  // Initialize
  // ============================================================

  void initialize({
    required List<CartItemEntity> items,
  }) {
    _cartItems = List<CartItemEntity>.from(items);

    _error = null;
    _checkoutResult = null;
    _payment = null;
    _isLoading = false;
    _isPaymentChecking = false;

    notifyListeners();
  }

  // ============================================================
  // Gateway
  // ============================================================

  void setGateway(String gateway) {
    debugPrint('SELECTED GATEWAY: $gateway');

    if (gateway != 'zarinpal' &&
        gateway != 'sep') {
      _error =
      'درگاه پرداخت انتخاب‌شده پشتیبانی نمی‌شود.';
      notifyListeners();
      return;
    }

    _selectedGateway = gateway;
    _error = null;

    debugPrint(
      'CURRENT SELECTED GATEWAY: $_selectedGateway',
    );

    notifyListeners();
  }

  // ============================================================
  // Payment Method
  // ============================================================

  void setPaymentMethod(String method) {
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

  // ============================================================
  // Cart Items
  // ============================================================

  void setCartItems(
      List<CartItemEntity> items,
      ) {
    _cartItems =
    List<CartItemEntity>.from(items);

    notifyListeners();
  }

  // ============================================================
  // Address
  // ============================================================

  void setSelectedAddress(
      AddressEntity? address,
      ) {
    _selectedAddress = address;
    _error = null;

    notifyListeners();
  }

  // ============================================================
  // Shipping Method
  // ============================================================

  void setSelectedShippingMethod(
      ShippingMethodEntity? shippingMethod,
      ) {
    _selectedShippingMethod =
        shippingMethod;

    if (shippingMethod != null) {
      _shippingCost = shippingMethod.cost;
    } else {
      _shippingCost = 0;
    }

    _error = null;

    notifyListeners();
  }

  // ============================================================
  // Shipping Cost
  // ============================================================

  void setShippingCost(int cost) {
    _shippingCost = cost;

    notifyListeners();
  }

  // ============================================================
  // SECURE CHECKOUT
  // ============================================================

  Future<CheckoutResultEntity?> createCheckout() async {
    if (!canSubmit) {
      _error =
      'لطفاً آدرس، روش ارسال و درگاه پرداخت را انتخاب کنید.';

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
        gateway: _selectedGateway,
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

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  Future<PaymentEntity?> checkPaymentStatus({
    required String orderId,
  }) async {
    if (orderId.trim().isEmpty) {
      _error = 'شناسه سفارش نامعتبر است.';

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

  // ============================================================
  // CONFIRM PAYMENT
  // ============================================================

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

  // ============================================================
  // REFRESH PAYMENT
  // ============================================================

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

  // ============================================================
  // CLEAR
  // ============================================================

  void clearCheckoutResult() {
    _checkoutResult = null;
    _payment = null;
    _error = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}