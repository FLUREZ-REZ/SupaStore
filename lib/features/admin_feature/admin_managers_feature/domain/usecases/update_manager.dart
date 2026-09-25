import '../entities/admin_manager_entity.dart';
import '../repositories/admin_managers_repository.dart';

class UpdateManager {
  UpdateManager({
    required AdminManagersRepository repository,
  }) : _repository = repository;

  final AdminManagersRepository _repository;

  Future<AdminManagerEntity> call({
    required String userId,
    required String adminRole,
    required bool isActive,
  }) {
    return _repository.updateManager(
      userId: userId,
      adminRole: adminRole,
      isActive: isActive,
    );
  }
}