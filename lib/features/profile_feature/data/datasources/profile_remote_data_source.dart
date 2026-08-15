import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/profile_feature/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ============================================================
  // GET PROFILE
  // ============================================================

  Future<ProfileModel?> getProfile({
    required String userId,
  }) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileModel.fromMap(
      response,
    );
  }

  // ============================================================
  // CREATE PROFILE
  // ============================================================

  Future<ProfileModel> createProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _client
        .from('profiles')
        .insert({
      'id': userId,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    })
        .select()
        .single();

    return ProfileModel.fromMap(
      response,
    );
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<ProfileModel> updateProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _client
        .from('profiles')
        .update({
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at':
      DateTime.now().toIso8601String(),
    })
        .eq('id', userId)
        .select()
        .maybeSingle();

    // اگر پروفایل وجود نداشته باشد
    if (response == null) {
      return await createProfile(
        userId: userId,
        phone: phone,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
    }

    return ProfileModel.fromMap(
      response,
    );
  }
}