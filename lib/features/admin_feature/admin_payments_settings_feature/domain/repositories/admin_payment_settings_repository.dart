import '../entities/admin_payment_settings_entity.dart';

abstract class AdminPaymentSettingsRepository {
  Future<AdminPaymentSettingsEntity> getPaymentSettings();

  Future<AdminPaymentSettingsEntity> updatePaymentSettings({
    required String id,
    required bool onlinePaymentEnabled,
    required bool zarinpalEnabled,
    required bool sepEnabled,
    required String defaultGateway,
  });
}