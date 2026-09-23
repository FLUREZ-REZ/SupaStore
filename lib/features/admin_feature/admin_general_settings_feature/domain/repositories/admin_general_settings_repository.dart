import '../entities/admin_general_settings_entity.dart';

abstract class AdminGeneralSettingsRepository {
  Future<AdminGeneralSettingsEntity>
  getGeneralSettings();

  Future<AdminGeneralSettingsEntity>
  updateGeneralSettings({
    required AdminGeneralSettingsEntity settings,
  });
}