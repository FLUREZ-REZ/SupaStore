import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/Users/domain/repositories/admin_user_repository.dart';

class GetAdminUsers {
  GetAdminUsers({
    required AdminUserRepository repository,
  }) : _repository = repository;

  final AdminUserRepository _repository;

  Future<List<AdminUser>> call({
    required int page,
    required int limit,
    String? search,
  }) {
    return _repository.getUsers(
      page: page,
      limit: limit,
      search: search,
    );
  }
}