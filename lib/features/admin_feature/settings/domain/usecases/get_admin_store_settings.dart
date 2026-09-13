import '../entities/admin_store_settings_entity.dart';
import '../repositories/admin_store_settings_repository.dart';

class GetAdminStoreSettings {
  GetAdminStoreSettings({
    required AdminStoreSettingsRepository repository,
  }) : _repository = repository;

  final AdminStoreSettingsRepository _repository;

  Future<AdminStoreSettingsEntity> call() {
    return _repository.getSettings();
  }
}