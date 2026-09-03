import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentByOrderUseCase {
  final PaymentRepository repository;

  GetPaymentByOrderUseCase(this.repository);

  Future<PaymentEntity?> call({
    required String orderId,
  }) {
    return repository.getPaymentByOrder(
      orderId: orderId,
    );
  }
}