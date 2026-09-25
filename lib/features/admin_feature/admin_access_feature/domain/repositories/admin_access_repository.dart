import '../entities/admin_access_entity.dart';

abstract class AdminAccessRepository {
  Future<AdminAccessEntity?> getCurrentUserAccess();
}