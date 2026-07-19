import 'package:flutter/cupertino.dart';
import 'package:supastore/core/services/internet_service.dart';

class SplashProvider extends ChangeNotifier {
  final InternetService internetService;

  SplashProvider(this.internetService);

  bool isLoading = true;
  bool hasInternet = true;

  Future<void> checkConnection() async {
    isLoading = true;
    notifyListeners();

    hasInternet = await internetService.hasInternet();

    isLoading = false;
    notifyListeners();
  }
}