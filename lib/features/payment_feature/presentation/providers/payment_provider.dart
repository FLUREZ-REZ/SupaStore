import 'package:flutter/foundation.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/get_payment_by_order_use_case.dart';
import '../../domain/usecases/get_payment_use_case.dart';

class PaymentProvider extends ChangeNotifier {
  final GetPaymentUseCase getPaymentUseCase;
  final GetPaymentByOrderUseCase getPaymentByOrderUseCase;

  PaymentProvider({
    required this.getPaymentUseCase,
    required this.getPaymentByOrderUseCase,
  });

  PaymentEntity? _payment;

  bool _isLoading = false;

  String? _error;

  PaymentEntity? get payment => _payment;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> getPayment({
    required String paymentId,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _payment = await getPaymentUseCase(
        paymentId: paymentId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPaymentByOrder({
    required String orderId,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _payment = await getPaymentByOrderUseCase(
        orderId: orderId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _payment = null;
    _error = null;
    notifyListeners();
  }
}