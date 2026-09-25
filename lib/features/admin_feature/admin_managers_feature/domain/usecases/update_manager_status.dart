import '../entities/admin_manager_entity.dart';
import '../repositories/admin_managers_repository.dart';

class UpdateManagerStatus {
  UpdateManagerStatus({
    required AdminManagersRepository repository,
  }) : _repository = repository;

  final AdminManagersRepository _repository;

  Future<AdminManagerEntity> call({
    required String userId,
    required bool isActive,
  }) {
    return _repository.updateManagerStatus(
      userId: userId,
      isActive: isActive,
    );
  }
}