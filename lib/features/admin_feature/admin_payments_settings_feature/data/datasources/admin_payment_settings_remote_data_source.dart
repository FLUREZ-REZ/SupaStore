import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPaymentSettingsRemoteDataSource {
  AdminPaymentSettingsRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>> getPaymentSettings() async {
    final response = await _supabase
        .from('payment_settings')
        .select('''
          id,
          online_payment_enabled,
          zarinpal_enabled,
          sep_enabled,
          default_gateway,
          created_at,
          updated_at,
          singleton
        ''')
        .eq('singleton', true)
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updatePaymentSettings({
    required String id,
    required bool onlinePaymentEnabled,
    required bool zarinpalEnabled,
    required bool sepEnabled,
    required String defaultGateway,
  }) async {
    final response = await _supabase
        .from('payment_settings')
        .update({
      'online_payment_enabled': onlinePaymentEnabled,
      'zarinpal_enabled': zarinpalEnabled,
      'sep_enabled': sepEnabled,
      'default_gateway': defaultGateway,
    })
        .eq('id', id)
        .select('''
          id,
          online_payment_enabled,
          zarinpal_enabled,
          sep_enabled,
          default_gateway,
          created_at,
          updated_at,
          singleton
        ''')
        .single();

    return Map<String, dynamic>.from(response);
  }
}