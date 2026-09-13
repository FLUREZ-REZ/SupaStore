import 'dart:typed_data';

import 'package:supastore/features/admin_feature/settings/data/datasources/admin_store_settings_remote_data_source.dart';
import 'package:supastore/features/admin_feature/settings/data/models/admin_store_settings_model.dart';
import 'package:supastore/features/admin_feature/settings/domain/entities/admin_store_settings_entity.dart';
import 'package:supastore/features/admin_feature/settings/domain/repositories/admin_store_settings_repository.dart';


class AdminStoreSettingsRepositoryImpl
    implements AdminStoreSettingsRepository {
  AdminStoreSettingsRepositoryImpl({
    required AdminStoreSettingsRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  final AdminStoreSettingsRemoteDataSource _dataSource;

  @override
  Future<AdminStoreSettingsEntity> getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<AdminStoreSettingsEntity> updateSettings({
    required AdminStoreSettingsEntity settings,
  }) {
    return _dataSource.updateSettings(
      settings: AdminStoreSettingsModel(
        id: settings.id,
        storeName: settings.storeName,
        logoUrl: settings.logoUrl,
        tagline: settings.tagline,
        description: settings.description,
        phone: settings.phone,
        email: settings.email,
        address: settings.address,
        postalCode: settings.postalCode,
        instagram: settings.instagram,
        telegram: settings.telegram,
        website: settings.website,
        legalName: settings.legalName,
        nationalId: settings.nationalId,
        createdAt: settings.createdAt,
        updatedAt: settings.updatedAt,
      ),
    );
  }

  @override
  Future<AdminStoreSettingsEntity> updateLogo({
    required String settingsId,
    required String? oldLogoUrl,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) {
    return _dataSource.updateLogo(
      settingsId: settingsId,
      oldLogoUrl: oldLogoUrl,
      bytes: bytes,
      extension: extension,
      contentType: contentType,
    );
  }

  @override
  Future<AdminStoreSettingsEntity> removeLogo({
    required String settingsId,
    required String? logoUrl,
  }) {
    return _dataSource.removeLogo(
      settingsId: settingsId,
      logoUrl: logoUrl,
    );
  }
}