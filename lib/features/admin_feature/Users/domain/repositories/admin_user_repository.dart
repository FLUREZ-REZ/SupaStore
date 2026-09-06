import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';

abstract class AdminUserRepository {
  Future<List<AdminUser>> getUsers({
    required int page,
    required int limit,
    String? search,
  });
}