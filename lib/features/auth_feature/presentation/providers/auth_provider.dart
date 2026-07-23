import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

  final TextEditingController phoneController =
  TextEditingController();

  bool isLoading = false;

  bool get isValidPhone {

    final phone =
    phoneController.text
        .replaceAll(' ', '');

    return phone.length == 10 &&
        phone.startsWith('9');

  }

  void phoneChanged(String value) {

    notifyListeners();

  }

  Future<void> sendOtp() async {

    if(!isValidPhone) return;

    isLoading = true;

    notifyListeners();

    await Future.delayed(
      const Duration(seconds: 2),
    );

    isLoading = false;
    notifyListeners();

  }

  @override
  void dispose() {

    phoneController.dispose();

    super.dispose();
  }
}