import '../entities/admin_manager_entity.dart';
import '../repositories/admin_managers_repository.dart';

class FindProfileByPhone {
  FindProfileByPhone({
    required AdminManagersRepository repository,
  }) : _repository = repository;

  final AdminManagersRepository _repository;

  Future<AdminManagerEntity?> call({
    required String phone,
  }) {
    return _repository.findProfileByPhone(
      phone: phone,
    );
  }
}