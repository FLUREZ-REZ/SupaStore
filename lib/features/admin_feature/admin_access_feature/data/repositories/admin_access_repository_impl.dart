import '../../domain/entities/admin_access_entity.dart';
import '../../domain/repositories/admin_access_repository.dart';
import '../datasources/admin_access_remote_data_source.dart';

class AdminAccessRepositoryImpl
    implements AdminAccessRepository {
  AdminAccessRepositoryImpl({
    required AdminAccessRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminAccessRemoteDataSource _remoteDataSource;

  @override
  Future<AdminAccessEntity?> getCurrentUserAccess() async {
    final response =
    await _remoteDataSource.getCurrentUserAccess();

    if (response == null) {
      return null;
    }

    return AdminAccessEntity(
      userId: response['id'] as String,
      isAdmin: response['is_admin'] as bool? ?? false,
      adminRole:
      response['admin_role'] as String? ?? 'none',
      isActive:
      response['is_active'] as bool? ?? true,
    );
  }
}