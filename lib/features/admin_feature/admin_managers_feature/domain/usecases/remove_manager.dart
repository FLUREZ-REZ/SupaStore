import '../entities/admin_manager_entity.dart';
import '../repositories/admin_managers_repository.dart';

class RemoveManager {
  RemoveManager({
    required AdminManagersRepository repository,
  }) : _repository = repository;

  final AdminManagersRepository _repository;

  Future<AdminManagerEntity> call({
    required String userId,
  }) {
    return _repository.removeManager(
      userId: userId,
    );
  }
}