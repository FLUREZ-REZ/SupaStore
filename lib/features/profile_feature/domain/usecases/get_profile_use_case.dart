import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';
import 'package:supastore/features/profile_feature/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase({
    required ProfileRepository repository,
  }) : _repository = repository;

  final ProfileRepository _repository;

  Future<ProfileEntity?> call({
    required String userId,
  }) async {
    return await _repository.getProfile(
      userId: userId,
    );
  }
}