import '../entities/payment_settings_entity.dart';
import '../repositories/payment_settings_repository.dart';

class GetPaymentSettings {
  GetPaymentSettings({
    required PaymentSettingsRepository repository,
  }) : _repository = repository;

  final PaymentSettingsRepository _repository;

  Future<PaymentSettingsEntity> call() {
    return _repository.getPaymentSettings();
  }
}