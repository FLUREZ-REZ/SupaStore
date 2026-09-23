import 'package:supastore/features/payment_feature/payment_settings_feature/data/datasource/payment_settings_remote_data_source.dart';
import 'package:supastore/features/payment_feature/payment_settings_feature/data/models/payment_settings_model.dart';
import 'package:supastore/features/payment_feature/payment_settings_feature/domain/entities/payment_settings_entity.dart';
import 'package:supastore/features/payment_feature/payment_settings_feature/domain/repositories/payment_settings_repository.dart';

class PaymentSettingsRepositoryImpl
    implements PaymentSettingsRepository {
  PaymentSettingsRepositoryImpl({
    required PaymentSettingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PaymentSettingsRemoteDataSource _remoteDataSource;

  @override
  Future<PaymentSettingsEntity> getPaymentSettings() async {
    final response =
    await _remoteDataSource.getPaymentSettings();

    return PaymentSettingsModel.fromJson(response);
  }
}