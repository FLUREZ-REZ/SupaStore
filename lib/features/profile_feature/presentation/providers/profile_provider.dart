import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';
import 'package:supastore/features/profile_feature/domain/usecases/create_profile_use_case.dart';
import 'package:supastore/features/profile_feature/domain/usecases/get_profile_use_case.dart';
import 'package:supastore/features/profile_feature/domain/usecases/update_profile_use_case.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required GetProfileUseCase getProfileUseCase,
    required CreateProfileUseCase createProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _createProfileUseCase = createProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase;

  // ============================================================
  // USE CASES
  // ============================================================

  final GetProfileUseCase _getProfileUseCase;

  final CreateProfileUseCase _createProfileUseCase;

  final UpdateProfileUseCase _updateProfileUseCase;

  // ============================================================
  // STATE
  // ============================================================

  ProfileEntity? _profile;

  ProfileEntity? get profile => _profile;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;

  String? _error;

  String? get error => _error;

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile({
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      // ----------------------------------------------------------
      // Get existing profile
      // ----------------------------------------------------------

      final result = await _getProfileUseCase(
        userId: userId,
      );

      // ----------------------------------------------------------
      // Profile exists
      // ----------------------------------------------------------

      if (result != null) {
        _profile = result;
      }

      // ----------------------------------------------------------
      // Profile does not exist
      // Create it automatically
      // ----------------------------------------------------------

      else {
        final user =
            Supabase.instance.client.auth.currentUser;

        final createdProfile =
        await _createProfileUseCase(
          userId: userId,
          phone: user?.phone,
          fullName: null,
          avatarUrl: null,
        );

        _profile = createdProfile;
      }

      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;

      _error = e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // CREATE PROFILE
  // ============================================================

  Future<bool> createProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _createProfileUseCase(
        userId: userId,
        phone: phone,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      _profile = result;

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _isUpdating = false;

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile({
    required String userId,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) async {
    _isUpdating = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _updateProfileUseCase(
        userId: userId,
        phone: phone,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      _profile = result;

      _isUpdating = false;

      notifyListeners();

      return true;
    } catch (e) {
      _isUpdating = false;

      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // REFRESH PROFILE
  // ============================================================

  Future<void> refreshProfile({
    required String userId,
  }) async {
    await loadProfile(
      userId: userId,
    );
  }

  // ============================================================
  // CLEAR PROFILE
  // ============================================================

  void clearProfile() {
    _profile = null;
    _error = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}