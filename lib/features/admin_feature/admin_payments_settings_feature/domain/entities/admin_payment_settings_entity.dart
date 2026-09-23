class AdminPaymentSettingsEntity {
  const AdminPaymentSettingsEntity({
    required this.id,
    required this.onlinePaymentEnabled,
    required this.zarinpalEnabled,
    required this.sepEnabled,
    required this.defaultGateway,
    required this.createdAt,
    required this.updatedAt,
    required this.singleton,
  });

  final String id;
  final bool onlinePaymentEnabled;
  final bool zarinpalEnabled;
  final bool sepEnabled;
  final String defaultGateway;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool singleton;
}