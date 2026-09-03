import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
  });

  PaymentEntity _mapToEntity(Map<String, dynamic> data) {
    return PaymentEntity(
      id: data['id'] as String,
      orderId: data['order_id'] as String,
      userId: data['user_id'] as String,
      amount: (data['amount'] as num).toInt(),
      gateway: data['gateway'] as String,
      status: data['status'] as String,
      authority: data['authority'] as String?,
      refId: data['ref_id'] as String?,
      gatewayMessage: data['gateway_message'] as String?,
      createdAt: DateTime.parse(
        data['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        data['updated_at'] as String,
      ),
      paidAt: data['paid_at'] != null
          ? DateTime.parse(
        data['paid_at'] as String,
      )
          : null,
    );
  }

  @override
  Future<PaymentEntity> createPayment({
    required String orderId,
  }) async {
    throw UnimplementedError(
      'Payment creation must be handled by the secure backend.',
    );
  }

  @override
  Future<PaymentEntity?> getPayment({
    required String paymentId,
  }) async {
    final data = await remoteDataSource.getPayment(
      paymentId: paymentId,
    );

    if (data == null) {
      return null;
    }

    return _mapToEntity(data);
  }

  @override
  Future<PaymentEntity?> getPaymentByOrder({
    required String orderId,
  }) async {
    final data = await remoteDataSource.getPaymentByOrder(
      orderId: orderId,
    );

    if (data == null) {
      return null;
    }

    return _mapToEntity(data);
  }
}