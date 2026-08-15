import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile({
    required String userId,
  });

  Future<ProfileEntity> createProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  });

  Future<ProfileEntity> updateProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  });
}