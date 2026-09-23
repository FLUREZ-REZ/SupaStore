import '../entities/admin_general_settings_entity.dart';
import '../repositories/admin_general_settings_repository.dart';

class UpdateAdminGeneralSettings {
  UpdateAdminGeneralSettings({
    required AdminGeneralSettingsRepository repository,
  }) : _repository = repository;

  final AdminGeneralSettingsRepository _repository;

  Future<AdminGeneralSettingsEntity> call({
    required AdminGeneralSettingsEntity settings,
  }) {
    return _repository.updateGeneralSettings(
      settings: settings,
    );
  }
}