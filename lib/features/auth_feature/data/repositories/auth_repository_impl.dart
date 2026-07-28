import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;



  Future<void> sendOtp({
    required String phone,
  }) async {
    await _client.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  bool get isLoggedIn =>
      _client.auth.currentSession != null;

}