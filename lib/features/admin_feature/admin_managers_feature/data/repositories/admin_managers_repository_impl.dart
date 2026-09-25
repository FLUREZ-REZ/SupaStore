import '../../domain/entities/admin_manager_entity.dart';
import '../../domain/repositories/admin_managers_repository.dart';
import '../datasources/admin_managers_remote_data_source.dart';
import '../models/admin_manager_model.dart';

class AdminManagersRepositoryImpl
    implements AdminManagersRepository {
  AdminManagersRepositoryImpl({
    required AdminManagersRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminManagersRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminManagerEntity>> getManagers() async {
    final response =
    await _remoteDataSource.getManagers();

    return response
        .map(
      AdminManagerModel.fromJson,
    )
        .toList();
  }

  @override
  Future<AdminManagerEntity?> findProfileByPhone({
    required String phone,
  }) async {
    final response =
    await _remoteDataSource.findProfileByPhone(
      phone: phone,
    );

    if (response == null) {
      return null;
    }

    return AdminManagerModel.fromJson(
      response,
    );
  }

  @override
  Future<AdminManagerEntity> updateManager({
    required String userId,
    required String adminRole,
    required bool isActive,
  }) async {
    final response =
    await _remoteDataSource.updateManager(
      userId: userId,
      adminRole: adminRole,
      isActive: isActive,
    );

    return AdminManagerModel.fromJson(
      response,
    );
  }

  @override
  Future<AdminManagerEntity> removeManager({
    required String userId,
  }) async {
    final response =
    await _remoteDataSource.removeManager(
      userId: userId,
    );

    return AdminManagerModel.fromJson(
      response,
    );
  }

  @override
  Future<AdminManagerEntity> updateManagerStatus({
    required String userId,
    required bool isActive,
  }) async {
    final response =
    await _remoteDataSource.updateManagerStatus(
      userId: userId,
      isActive: isActive,
    );

    return AdminManagerModel.fromJson(
      response,
    );
  }
}