import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';

class SignOut {
  SignOut({
    required AuthRepository repository,
  }) : _repository = repository;

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}