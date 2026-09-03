import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentUseCase {
  final PaymentRepository repository;

  GetPaymentUseCase(this.repository);

  Future<PaymentEntity?> call({
    required String paymentId,
  }) {
    return repository.getPayment(
      paymentId: paymentId,
    );
  }
}