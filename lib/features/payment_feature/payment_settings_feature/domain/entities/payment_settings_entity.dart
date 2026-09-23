class PaymentSettingsEntity {
  const PaymentSettingsEntity({
    required this.onlinePaymentEnabled,
    required this.zarinpalEnabled,
    required this.sepEnabled,
    required this.defaultGateway,
  });

  final bool onlinePaymentEnabled;
  final bool zarinpalEnabled;
  final bool sepEnabled;
  final String defaultGateway;

  bool get hasAnyGateway =>
      zarinpalEnabled || sepEnabled;
}