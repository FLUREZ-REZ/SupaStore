import '../../domain/entities/admin_general_settings_entity.dart';
import '../../domain/repositories/admin_general_settings_repository.dart';
import '../datasources/admin_general_settings_remote_data_source.dart';
import '../models/admin_general_settings_model.dart';

class AdminGeneralSettingsRepositoryImpl
    implements AdminGeneralSettingsRepository {
  AdminGeneralSettingsRepositoryImpl({
    required AdminGeneralSettingsRemoteDataSource
    remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminGeneralSettingsRemoteDataSource
  _remoteDataSource;

  @override
  Future<AdminGeneralSettingsEntity>
  getGeneralSettings() async {
    final data =
    await _remoteDataSource.getGeneralSettings();

    return AdminGeneralSettingsModel.fromJson(data);
  }

  @override
  Future<AdminGeneralSettingsEntity>
  updateGeneralSettings({
    required AdminGeneralSettingsEntity settings,
  }) async {
    final model =
    AdminGeneralSettingsModel(
      id: settings.id,
      appName: settings.appName,
      maintenanceMode: settings.maintenanceMode,
      registrationEnabled:
      settings.registrationEnabled,
      shoppingEnabled:
      settings.shoppingEnabled,
      showUnavailableProducts:
      settings.showUnavailableProducts,
      reviewsEnabled:
      settings.reviewsEnabled,
      verifiedPurchaseReviewsOnly:
      settings.verifiedPurchaseReviewsOnly,
      minimumOrderAmount:
      settings.minimumOrderAmount,
      maxCartQuantity:
      settings.maxCartQuantity,
      maintenanceMessage:
      settings.maintenanceMessage,
      createdAt: settings.createdAt,
      updatedAt: settings.updatedAt,
      singleton: settings.singleton,
    );

    final data =
    await _remoteDataSource.updateGeneralSettings(
      data: model.toJson(),
    );

    return AdminGeneralSettingsModel.fromJson(data);
  }
}