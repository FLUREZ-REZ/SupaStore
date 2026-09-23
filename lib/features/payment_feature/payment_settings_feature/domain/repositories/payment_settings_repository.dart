import '../entities/payment_settings_entity.dart';

abstract class PaymentSettingsRepository {
  Future<PaymentSettingsEntity> getPaymentSettings();
}