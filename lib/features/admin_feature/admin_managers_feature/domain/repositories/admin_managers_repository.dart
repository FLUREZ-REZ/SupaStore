import '../entities/admin_manager_entity.dart';

abstract class AdminManagersRepository {
  Future<List<AdminManagerEntity>> getManagers();

  Future<AdminManagerEntity?> findProfileByPhone({
    required String phone,
  });

  Future<AdminManagerEntity> updateManager({
    required String userId,
    required String adminRole,
    required bool isActive,
  });

  Future<AdminManagerEntity> removeManager({
    required String userId,
  });

  Future<AdminManagerEntity> updateManagerStatus({
    required String userId,
    required bool isActive,
  });
}