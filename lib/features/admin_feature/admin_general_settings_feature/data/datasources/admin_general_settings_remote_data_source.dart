import 'package:supabase_flutter/supabase_flutter.dart';

class AdminGeneralSettingsRemoteDataSource {
  AdminGeneralSettingsRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>>
  getGeneralSettings() async {
    final response = await _supabase
        .from('general_settings')
        .select()
        .eq('singleton', true)
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>>
  updateGeneralSettings({
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabase
        .from('general_settings')
        .update(data)
        .eq('singleton', true)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }
}