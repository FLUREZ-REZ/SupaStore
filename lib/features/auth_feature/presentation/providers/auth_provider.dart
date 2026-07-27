import 'package:flutter/material.dart';
import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';


class AuthProvider extends ChangeNotifier {

  final TextEditingController phoneController =
  TextEditingController();

  final AuthRepository _authRepository =
  AuthRepository();

  bool isLoading = false;

  bool get isValidPhone {

    final phone =
    phoneController.text.replaceAll(' ', '');

    return phone.length == 10 &&
        phone.startsWith('9');
  }

  void phoneChanged(String value) {
    notifyListeners();
  }

  Future<void> sendOtp() async {

    if (!isValidPhone) return;

    isLoading = true;
    notifyListeners();

    try {

      final phone =
          '+98${phoneController.text.replaceAll(' ', '')}';

      await _authRepository.sendOtp(phone);

      debugPrint("OTP Sent Successfully");

    } catch (e) {

      debugPrint(e.toString());

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