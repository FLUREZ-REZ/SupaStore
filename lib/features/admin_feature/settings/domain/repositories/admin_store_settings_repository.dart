import 'dart:typed_data';

import '../entities/admin_store_settings_entity.dart';

abstract class AdminStoreSettingsRepository {
  Future<AdminStoreSettingsEntity> getSettings();

  Future<AdminStoreSettingsEntity> updateSettings({
    required AdminStoreSettingsEntity settings,
  });

  Future<AdminStoreSettingsEntity> updateLogo({
    required String settingsId,
    required String? oldLogoUrl,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  });

  Future<AdminStoreSettingsEntity> removeLogo({
    required String settingsId,
    required String? logoUrl,
  });
}