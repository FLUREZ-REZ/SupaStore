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

  Future<bool> sendOtp() async {

    if (!isValidPhone) return false;

    isLoading = true;

    notifyListeners();

    try {

      final phone =
          '+98${phoneController.text.replaceAll(' ', '')}';

      await _authRepository.sendOtp(
        phone: phone,
      );

      return true;

    } catch (e) {

      debugPrint(e.toString());

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