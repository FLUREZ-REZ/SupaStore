import '../../domain/entities/payment_settings_entity.dart';

class PaymentSettingsModel extends PaymentSettingsEntity {
  const PaymentSettingsModel({
    required super.onlinePaymentEnabled,
    required super.zarinpalEnabled,
    required super.sepEnabled,
    required super.defaultGateway,
  });

  factory PaymentSettingsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentSettingsModel(
      onlinePaymentEnabled:
      json['online_payment_enabled'] as bool? ?? false,
      zarinpalEnabled:
      json['zarinpal_enabled'] as bool? ?? false,
      sepEnabled:
      json['sep_enabled'] as bool? ?? false,
      defaultGateway:
      json['default_gateway'] as String? ?? 'zarinpal',
    );
  }
}