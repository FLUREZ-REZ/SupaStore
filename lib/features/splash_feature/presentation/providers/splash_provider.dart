import 'package:flutter/material.dart';
import 'package:supastore/core/services/internet_service.dart';
import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';

class SplashProvider extends ChangeNotifier {
  SplashProvider(
      this.internetService, {
        AuthRepository? authRepository,
      }) : _authRepository = authRepository ?? AuthRepository();

  final InternetService internetService;
  final AuthRepository _authRepository;

  bool isLoading = true;
  bool hasInternet = true;
  bool isLoggedIn = false;

  Future<void> initialize() async {
    isLoading = true;

    notifyListeners();

    hasInternet = await internetService.hasInternet();

    if (hasInternet) {
      isLoggedIn = _authRepository.isLoggedIn;
    }

    isLoading = false;

    notifyListeners();
  }

  Future<void> checkConnection() async {
    await initialize();
  }
}