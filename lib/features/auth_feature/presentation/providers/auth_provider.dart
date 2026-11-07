
import 'package:flutter/material.dart';

import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  final TextEditingController phoneController = TextEditingController();

  final AuthRepository _authRepository;

  bool isLoading = false;

  bool get isValidPhone {
    final phone = phoneController.text.replaceAll(' ', '');

    return phone.length == 10 && phone.startsWith('9');
  }

  // تغییر شماره تلفن
  void phoneChanged(String value) {
    notifyListeners();
  }

  // انتخاب حساب دمو
  void selectDemoAccount(String phone) {
    phoneController.value = TextEditingValue(
      text: phone,
      selection: TextSelection.collapsed(
        offset: phone.length,
      ),
    );

    notifyListeners();

    debugPrint('DEMO ACCOUNT SELECTED: $phone');
    debugPrint('PHONE VALID: $isValidPhone');
  }

  Future<bool> sendOtp() async {
    if (isLoading || !isValidPhone) return false;

    isLoading = true;
    notifyListeners();

    try {
      final phone = '+98${phoneController.text.replaceAll(' ', '')}';

      debugPrint('SENDING OTP TO: $phone');

      await _authRepository.sendOtp(
        phone: phone,
      );

      debugPrint('OTP SENT SUCCESSFULLY');

      return true;
    } catch (e, stackTrace) {
      debugPrint('SEND OTP ERROR: $e');
      debugPrint('$stackTrace');

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
