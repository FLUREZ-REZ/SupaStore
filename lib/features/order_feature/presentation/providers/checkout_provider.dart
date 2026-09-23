import 'package:flutter/foundation.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/order_feature/domain/entities/checkout_result_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';
import 'package:supastore/features/payment_feature/domain/entities/payment_entity.dart';
import 'package:supastore/features/payment_feature/domain/repositories/payment_repository.dart';
import 'package:supastore/features/payment_feature/payment_settings_feature/domain/entities/payment_settings_entity.dart';
import 'package:supastore/features/payment_feature/payment_settings_feature/domain/usecases/get_payment_settings.dart';
import 'package:supastore/features/shipping_feature/domain/entities/shipping_method_entity.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({
    required OrderRepository repository,
    required PaymentRepository paymentRepository,
    required CartProvider cartProvider,
    required GetPaymentSettings getPaymentSettings,
  })  : _repository = repository,
        _paymentRepository = paymentRepository,
        _cartProvider = cartProvider,
        _getPaymentSettings = getPaymentSettings;

  final OrderRepository _repository;
  final PaymentRepository _paymentRepository;
  final CartProvider _cartProvider;
  final GetPaymentSettings _getPaymentSettings;

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
  // Payment Settings State
  // ============================================================

  PaymentSettingsEntity? _paymentSettings;

  bool _isPaymentSettingsLoading = false;

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

  PaymentSettingsEntity? get paymentSettings =>
      _paymentSettings;

  bool get isPaymentSettingsLoading =>
      _isPaymentSettingsLoading;

  bool get onlinePaymentEnabled =>
      _paymentSettings?.onlinePaymentEnabled ?? false;

  bool get zarinpalEnabled =>
      _paymentSettings?.zarinpalEnabled ?? false;

  bool get sepEnabled =>
      _paymentSettings?.sepEnabled ?? false;

  bool get hasAvailableGateway =>
      zarinpalEnabled || sepEnabled;

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
    final gatewayIsValid =
        (_selectedGateway == 'zarinpal' &&
            zarinpalEnabled) ||
            (_selectedGateway == 'sep' &&
                sepEnabled);

    return _cartItems.isNotEmpty &&
        _selectedAddress != null &&
        _selectedAddress!.id.isNotEmpty &&
        _selectedShippingMethod != null &&
        _selectedShippingMethod!.id.isNotEmpty &&
        _paymentMethod == 'online' &&
        onlinePaymentEnabled &&
        gatewayIsValid &&
        !_isLoading &&
        !_isPaymentSettingsLoading;
  }

  // ============================================================
  // Initialize
  // ============================================================

  void initialize({
    required List<CartItemEntity> items,
  }) {
    _cartItems =
    List<CartItemEntity>.from(items);

    _error = null;
    _checkoutResult = null;
    _payment = null;
    _isLoading = false;
    _isPaymentChecking = false;

    _loadPaymentSettings();

    notifyListeners();
  }

  // ============================================================
  // Load Payment Settings
  // ============================================================

  Future<void> _loadPaymentSettings() async {
    _isPaymentSettingsLoading = true;
    _error = null;

    notifyListeners();

    try {
      final settings =
      await _getPaymentSettings();

      _paymentSettings = settings;

      _applyPaymentSettings(settings);
    } catch (e) {
      _error = _cleanPaymentSettingsError(e);
    } finally {
      _isPaymentSettingsLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // Apply Payment Settings
  // ============================================================

  void _applyPaymentSettings(
      PaymentSettingsEntity settings,
      ) {
    // ----------------------------------------------------------
    // Online payment disabled
    // ----------------------------------------------------------

    if (!settings.onlinePaymentEnabled) {
      _paymentMethod = 'online';

      return;
    }

    // ----------------------------------------------------------
    // Current gateway is still enabled
    // ----------------------------------------------------------

    if (_selectedGateway == 'zarinpal' &&
        settings.zarinpalEnabled) {
      return;
    }

    if (_selectedGateway == 'sep' &&
        settings.sepEnabled) {
      return;
    }

    // ----------------------------------------------------------
    // Current gateway is disabled
    // Select default gateway if available
    // ----------------------------------------------------------

    final defaultGateway =
        settings.defaultGateway;

    if (defaultGateway == 'zarinpal' &&
        settings.zarinpalEnabled) {
      _selectedGateway = 'zarinpal';
      return;
    }

    if (defaultGateway == 'sep' &&
        settings.sepEnabled) {
      _selectedGateway = 'sep';
      return;
    }

    // ----------------------------------------------------------
    // Default gateway is unavailable
    // Select any available gateway
    // ----------------------------------------------------------

    if (settings.zarinpalEnabled) {
      _selectedGateway = 'zarinpal';
      return;
    }

    if (settings.sepEnabled) {
      _selectedGateway = 'sep';
      return;
    }
  }

  // ============================================================
  // Gateway
  // ============================================================

  void setGateway(String gateway) {
    debugPrint(
      'SELECTED GATEWAY REQUEST: $gateway',
    );

    if (gateway != 'zarinpal' &&
        gateway != 'sep') {
      _error =
      'درگاه پرداخت انتخاب‌شده پشتیبانی نمی‌شود.';

      notifyListeners();
      return;
    }

    // ----------------------------------------------------------
    // Check gateway availability
    // ----------------------------------------------------------

    if (gateway == 'zarinpal' &&
        !zarinpalEnabled) {
      _error =
      'درگاه زرین‌پال در حال حاضر فعال نیست.';

      notifyListeners();
      return;
    }

    if (gateway == 'sep' &&
        !sepEnabled) {
      _error =
      'درگاه سامان (SEP) در حال حاضر فعال نیست.';

      notifyListeners();
      return;
    }

    // ----------------------------------------------------------
    // Set gateway
    // ----------------------------------------------------------

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

    if (!onlinePaymentEnabled) {
      _error =
      'پرداخت آنلاین در حال حاضر فعال نیست.';

      notifyListeners();
      return;
    }

    if (!hasAvailableGateway) {
      _error =
      'درگاه پرداختی در حال حاضر فعال نیست.';

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

  String _cleanPaymentSettingsError(
      Object error,
      ) {
    final message = error.toString();

    if (message.contains('PGRST116')) {
      return 'تنظیمات پرداخت پیدا نشد.';
    }

    if (message.contains('42501')) {
      return 'دسترسی به تنظیمات پرداخت امکان‌پذیر نیست.';
    }

    return 'خطایی در دریافت تنظیمات پرداخت رخ داد.';
  }
}