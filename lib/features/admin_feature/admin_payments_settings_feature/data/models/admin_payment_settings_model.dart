import '../../domain/entities/admin_payment_settings_entity.dart';

class AdminPaymentSettingsModel extends AdminPaymentSettingsEntity {
  const AdminPaymentSettingsModel({
    required super.id,
    required super.onlinePaymentEnabled,
    required super.zarinpalEnabled,
    required super.sepEnabled,
    required super.defaultGateway,
    required super.createdAt,
    required super.updatedAt,
    required super.singleton,
  });

  factory AdminPaymentSettingsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminPaymentSettingsModel(
      id: json['id'] as String,
      onlinePaymentEnabled:
      json['online_payment_enabled'] as bool? ?? true,
      zarinpalEnabled:
      json['zarinpal_enabled'] as bool? ?? true,
      sepEnabled:
      json['sep_enabled'] as bool? ?? true,
      defaultGateway:
      json['default_gateway'] as String? ?? 'zarinpal',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      singleton: json['singleton'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'online_payment_enabled': onlinePaymentEnabled,
      'zarinpal_enabled': zarinpalEnabled,
      'sep_enabled': sepEnabled,
      'default_gateway': defaultGateway,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'singleton': singleton,
    };
  }
}