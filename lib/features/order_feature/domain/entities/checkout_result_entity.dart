class CheckoutResultEntity {
  const CheckoutResultEntity({
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.gatewayReference,
    required this.paymentUrl,
    required this.sandbox,
  });

  final String orderId;
  final String paymentId;
  final int amount;
  final String currency;

  /// Payment gateway identifier.
  ///
  /// Examples:
  /// zarinpal
  /// sep
  final String gateway;

  /// Gateway-specific reference.
  ///
  /// ZarinPal:
  /// authority
  ///
  /// SEP:
  /// token
  final String gatewayReference;

  final String paymentUrl;
  final bool sandbox;
}