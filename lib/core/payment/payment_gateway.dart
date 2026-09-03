import 'payment_gateway_result.dart';

abstract class PaymentGateway {
  Future<PaymentGatewayResult> createPayment({
    required String paymentId,
    required int amount,
  });

  Future<PaymentGatewayResult> verifyPayment({
    required String paymentId,
    required String authority,
  });
}