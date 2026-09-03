enum PaymentGatewayStatus {
  success,
  failed,
  pending,
}

class PaymentGatewayResult {
  final PaymentGatewayStatus status;
  final String? paymentUrl;
  final String? authority;
  final String? refId;
  final String? message;

  const PaymentGatewayResult({
    required this.status,
    this.paymentUrl,
    this.authority,
    this.refId,
    this.message,
  });

  bool get isSuccess =>
      status == PaymentGatewayStatus.success;

  bool get isFailed =>
      status == PaymentGatewayStatus.failed;

  bool get isPending =>
      status == PaymentGatewayStatus.pending;
}