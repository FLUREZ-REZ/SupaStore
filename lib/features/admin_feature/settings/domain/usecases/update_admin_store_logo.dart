import 'dart:typed_data';

import '../entities/admin_store_settings_entity.dart';
import '../repositories/admin_store_settings_repository.dart';

class UpdateAdminStoreLogo {
  UpdateAdminStoreLogo({
    required AdminStoreSettingsRepository repository,
  }) : _repository = repository;

  final AdminStoreSettingsRepository _repository;

  Future<AdminStoreSettingsEntity> call({
    required String settingsId,
    required String? oldLogoUrl,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) {
    return _repository.updateLogo(
      settingsId: settingsId,
      oldLogoUrl: oldLogoUrl,
      bytes: bytes,
      extension: extension,
      contentType: contentType,
    );
  }
}