import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }
}