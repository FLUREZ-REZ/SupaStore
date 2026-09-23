import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSettingsRemoteDataSource {
  PaymentSettingsRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<Map<String, dynamic>> getPaymentSettings() async {
    final response = await _supabase
        .from('payment_settings')
        .select('''
          online_payment_enabled,
          zarinpal_enabled,
          sep_enabled,
          default_gateway
        ''')
        .eq('singleton', true)
        .single();

    return Map<String, dynamic>.from(response);
  }
}