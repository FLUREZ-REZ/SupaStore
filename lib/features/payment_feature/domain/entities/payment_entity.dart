class PaymentEntity {
  final String id;
  final String orderId;
  final String userId;
  final int amount;
  final String gateway;
  final String status;
  final String? authority;
  final String? refId;
  final String? gatewayMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;

  const PaymentEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.gateway,
    required this.status,
    this.authority,
    this.refId,
    this.gatewayMessage,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
  });

  bool get isPending => status == 'pending';

  bool get isPaid => status == 'paid';

  bool get isFailed => status == 'failed';

  bool get isCanceled => status == 'canceled';
}