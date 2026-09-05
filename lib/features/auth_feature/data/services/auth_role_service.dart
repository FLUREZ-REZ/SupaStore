import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/features/profile_feature/domain/usecases/get_profile_use_case.dart';

class AuthRoleService {
  AuthRoleService({
    required GetProfileUseCase getProfileUseCase,
    SupabaseClient? client,
  })  : _getProfileUseCase = getProfileUseCase,
        _client = client ?? Supabase.instance.client;

  final GetProfileUseCase _getProfileUseCase;
  final SupabaseClient _client;

  Future<bool> isCurrentUserAdmin() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return false;
    }

    final profile = await _getProfileUseCase(
      userId: user.id,
    );

    return profile?.isAdmin == true;
  }
}