import 'package:supastore/features/profile_feature/data/datasources/profile_remote_data_source.dart';
import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';
import 'package:supastore/features/profile_feature/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity?> getProfile({
    required String userId,
  }) async {
    return await _remoteDataSource.getProfile(
      userId: userId,
    );
  }

  @override
  Future<ProfileEntity> createProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _remoteDataSource.createProfile(
      userId: userId,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _remoteDataSource.updateProfile(
      userId: userId,
      phone: phone,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}