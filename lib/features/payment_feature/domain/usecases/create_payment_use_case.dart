import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);

  Future<PaymentEntity> call({
    required String orderId,
  }) {
    return repository.createPayment(
      orderId: orderId,
    );
  }
}