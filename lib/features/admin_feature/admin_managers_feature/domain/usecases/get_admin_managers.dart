import '../entities/admin_manager_entity.dart';
import '../repositories/admin_managers_repository.dart';

class GetAdminManagers {
  GetAdminManagers({
    required AdminManagersRepository repository,
  }) : _repository = repository;

  final AdminManagersRepository _repository;

  Future<List<AdminManagerEntity>> call() {
    return _repository.getManagers();
  }
}