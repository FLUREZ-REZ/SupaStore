import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAccessRemoteDataSource {
  AdminAccessRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>?> getCurrentUserAccess() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('profiles')
        .select('''
          id,
          is_admin,
          admin_role,
          is_active
        ''')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }
}