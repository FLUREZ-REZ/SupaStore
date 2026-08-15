import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';
import 'package:supastore/features/profile_feature/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase({
    required ProfileRepository repository,
  }) : _repository = repository;

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _repository.updateProfile(
      userId: userId,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}