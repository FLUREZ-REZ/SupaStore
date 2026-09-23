import '../entities/admin_payment_settings_entity.dart';
import '../repositories/admin_payment_settings_repository.dart';

class UpdateAdminPaymentSettings {
  UpdateAdminPaymentSettings({
    required AdminPaymentSettingsRepository repository,
  }) : _repository = repository;

  final AdminPaymentSettingsRepository _repository;

  Future<AdminPaymentSettingsEntity> call({
    required String id,
    required bool onlinePaymentEnabled,
    required bool zarinpalEnabled,
    required bool sepEnabled,
    required String defaultGateway,
  }) {
    return _repository.updatePaymentSettings(
      id: id,
      onlinePaymentEnabled: onlinePaymentEnabled,
      zarinpalEnabled: zarinpalEnabled,
      sepEnabled: sepEnabled,
      defaultGateway: defaultGateway,
    );
  }
}