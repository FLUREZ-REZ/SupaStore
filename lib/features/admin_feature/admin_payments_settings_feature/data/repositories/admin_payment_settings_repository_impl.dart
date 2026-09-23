import '../../domain/entities/admin_payment_settings_entity.dart';
import '../../domain/repositories/admin_payment_settings_repository.dart';
import '../datasources/admin_payment_settings_remote_data_source.dart';
import '../models/admin_payment_settings_model.dart';

class AdminPaymentSettingsRepositoryImpl
    implements AdminPaymentSettingsRepository {
  AdminPaymentSettingsRepositoryImpl({
    required AdminPaymentSettingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminPaymentSettingsRemoteDataSource _remoteDataSource;

  @override
  Future<AdminPaymentSettingsEntity> getPaymentSettings() async {
    final response =
    await _remoteDataSource.getPaymentSettings();

    return AdminPaymentSettingsModel.fromJson(response);
  }

  @override
  Future<AdminPaymentSettingsEntity> updatePaymentSettings({
    required String id,
    required bool onlinePaymentEnabled,
    required bool zarinpalEnabled,
    required bool sepEnabled,
    required String defaultGateway,
  }) async {
    final response =
    await _remoteDataSource.updatePaymentSettings(
      id: id,
      onlinePaymentEnabled: onlinePaymentEnabled,
      zarinpalEnabled: zarinpalEnabled,
      sepEnabled: sepEnabled,
      defaultGateway: defaultGateway,
    );

    return AdminPaymentSettingsModel.fromJson(response);
  }
}