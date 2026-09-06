import 'package:supastore/features/admin_feature/Users/data/datasource/admin_user_remote_datasource.dart';
import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/Users/domain/repositories/admin_user_repository.dart';



class AdminUserRepositoryImpl
    implements AdminUserRepository {
  AdminUserRepositoryImpl({
    required AdminUserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminUserRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminUser>> getUsers({
    required int page,
    required int limit,
    String? search,
  }) {
    return _remoteDataSource.getUsers(
      page: page,
      limit: limit,
      search: search,
    );
  }
}