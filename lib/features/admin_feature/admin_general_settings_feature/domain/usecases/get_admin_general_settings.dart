import '../entities/admin_general_settings_entity.dart';
import '../repositories/admin_general_settings_repository.dart';

class GetAdminGeneralSettings {
  GetAdminGeneralSettings({
    required AdminGeneralSettingsRepository repository,
  }) : _repository = repository;

  final AdminGeneralSettingsRepository _repository;

  Future<AdminGeneralSettingsEntity> call() {
    return _repository.getGeneralSettings();
  }
}