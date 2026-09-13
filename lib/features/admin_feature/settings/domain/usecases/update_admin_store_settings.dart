import '../entities/admin_store_settings_entity.dart';
import '../repositories/admin_store_settings_repository.dart';

class UpdateAdminStoreSettings {
  UpdateAdminStoreSettings({
    required AdminStoreSettingsRepository repository,
  }) : _repository = repository;

  final AdminStoreSettingsRepository _repository;

  Future<AdminStoreSettingsEntity> call({
    required AdminStoreSettingsEntity settings,
  }) {
    return _repository.updateSettings(
      settings: settings,
    );
  }
}