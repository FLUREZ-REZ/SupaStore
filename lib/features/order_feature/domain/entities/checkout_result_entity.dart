class CheckoutResultEntity {
  const CheckoutResultEntity({
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.authority,
    required this.paymentUrl,
    required this.sandbox,
  });

  final String orderId;
  final String paymentId;
  final int amount;
  final String currency;
  final String authority;
  final String paymentUrl;
  final bool sandbox;
}