import '../entities/admin_access_entity.dart';
import '../repositories/admin_access_repository.dart';

class GetCurrentUserAccess {
  GetCurrentUserAccess({
    required AdminAccessRepository repository,
  }) : _repository = repository;

  final AdminAccessRepository _repository;

  Future<AdminAccessEntity?> call() {
    return _repository.getCurrentUserAccess();
  }
}