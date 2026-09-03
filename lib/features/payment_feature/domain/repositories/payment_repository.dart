import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<PaymentEntity> createPayment({
    required String orderId,
  });

  Future<PaymentEntity?> getPayment({
    required String paymentId,
  });

  Future<PaymentEntity?> getPaymentByOrder({
    required String orderId,
  });
}