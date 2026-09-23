import '../entities/admin_payment_settings_entity.dart';
import '../repositories/admin_payment_settings_repository.dart';

class GetAdminPaymentSettings {
  GetAdminPaymentSettings({
    required AdminPaymentSettingsRepository repository,
  }) : _repository = repository;

  final AdminPaymentSettingsRepository _repository;

  Future<AdminPaymentSettingsEntity> call() {
    return _repository.getPaymentSettings();
  }
}