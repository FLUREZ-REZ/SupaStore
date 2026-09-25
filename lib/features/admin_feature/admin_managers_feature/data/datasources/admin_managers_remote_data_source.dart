import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManagersRemoteDataSource {
  AdminManagersRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getManagers() async {
    final response = await _supabase
        .from('profiles')
        .select('''
          id,
          phone,
          full_name,
          avatar_url,
          is_admin,
          admin_role,
          is_active,
          created_at,
          updated_at
        ''')
        .eq('is_admin', true)
        .order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }

  Future<Map<String, dynamic>?> findProfileByPhone({
    required String phone,
  }) async {
    final response = await _supabase
        .from('profiles')
        .select('''
          id,
          phone,
          full_name,
          avatar_url,
          is_admin,
          admin_role,
          is_active,
          created_at,
          updated_at
        ''')
        .eq('phone', phone)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<Map<String, dynamic>> updateManager({
    required String userId,
    required String adminRole,
    required bool isActive,
  }) async {
    final response = await _supabase
        .from('profiles')
        .update({
      'is_admin': true,
      'admin_role': adminRole,
      'is_active': isActive,
    })
        .eq('id', userId)
        .select('''
          id,
          phone,
          full_name,
          avatar_url,
          is_admin,
          admin_role,
          is_active,
          created_at,
          updated_at
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<Map<String, dynamic>> removeManager({
    required String userId,
  }) async {
    final response = await _supabase
        .from('profiles')
        .update({
      'is_admin': false,
      'admin_role': 'none',
    })
        .eq('id', userId)
        .select('''
          id,
          phone,
          full_name,
          avatar_url,
          is_admin,
          admin_role,
          is_active,
          created_at,
          updated_at
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<Map<String, dynamic>> updateManagerStatus({
    required String userId,
    required bool isActive,
  }) async {
    final response = await _supabase
        .from('profiles')
        .update({
      'is_active': isActive,
    })
        .eq('id', userId)
        .select('''
          id,
          phone,
          full_name,
          avatar_url,
          is_admin,
          admin_role,
          is_active,
          created_at,
          updated_at
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }
}