import '../entities/admin_store_settings_entity.dart';
import '../repositories/admin_store_settings_repository.dart';

class RemoveAdminStoreLogo {
  RemoveAdminStoreLogo({
    required AdminStoreSettingsRepository repository,
  }) : _repository = repository;

  final AdminStoreSettingsRepository _repository;

  Future<AdminStoreSettingsEntity> call({
    required String settingsId,
    required String? logoUrl,
  }) {
    return _repository.removeLogo(
      settingsId: settingsId,
      logoUrl: logoUrl,
    );
  }
}