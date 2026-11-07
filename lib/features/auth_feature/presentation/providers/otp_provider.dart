
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/auth_feature/data/repositories/auth_repository_impl.dart';

enum OtpStatus {
  initial,
  loading,
  success,
  invalidOtp,
  networkError,
}

class OtpProvider extends ChangeNotifier {
  OtpProvider({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final TextEditingController otpController = TextEditingController();

  static const int _initialSeconds = 60;

  Timer? _timer;

  int _secondsRemaining = _initialSeconds;

  bool _isLoading = false;

  OtpStatus _status = OtpStatus.initial;

  String? _phoneNumber;

  bool get isLoading => _isLoading;

  int get secondsRemaining => _secondsRemaining;

  bool get canResend => _secondsRemaining == 0;

  OtpStatus get status => _status;

  bool get isOtpComplete => _normalizeDigits(
    otpController.text,
  ).length == 6;

  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_secondsRemaining % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // تبدیل اعداد فارسی و عربی به انگلیسی
  String _normalizeDigits(String value) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    for (int i = 0; i < 10; i++) {
      value = value.replaceAll(persian[i], '$i');
      value = value.replaceAll(arabic[i], '$i');
    }

    return value;
  }

  // یکسان‌سازی شماره تلفن برای Supabase
  String _normalizePhone(String phone) {
    String value = _normalizeDigits(phone).trim();

    value = value.replaceAll(RegExp(r'[\s\-()]'), '');

    if (value.startsWith('0098')) {
      value = '+${value.substring(2)}';
    } else if (value.startsWith('98')) {
      value = '+$value';
    } else if (value.startsWith('0')) {
      value = '+98${value.substring(1)}';
    } else if (value.startsWith('9')) {
      value = '+98$value';
    }

    return value;
  }

  void setPhone(String phone) {
    _phoneNumber = _normalizePhone(phone);

    debugPrint('OTP PHONE: $_phoneNumber');
  }

  void onOtpChanged(String value) {
    if (_status != OtpStatus.initial) {
      _status = OtpStatus.initial;
    }

    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();

    _secondsRemaining = _initialSeconds;

    notifyListeners();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_secondsRemaining <= 0) {
          timer.cancel();
          return;
        }

        _secondsRemaining--;

        notifyListeners();
      },
    );
  }

  Future<void> verifyCode() async {
    if (_isLoading) return;

    if (!isOtpComplete) {
      _status = OtpStatus.invalidOtp;
      notifyListeners();
      return;
    }

    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      debugPrint('OTP ERROR: Phone number is null');

      _status = OtpStatus.networkError;
      notifyListeners();
      return;
    }

    final phone = _normalizePhone(_phoneNumber!);

    final otp = _normalizeDigits(
      otpController.text,
    ).trim();

    _isLoading = true;
    _status = OtpStatus.loading;

    notifyListeners();

    try {
      debugPrint('========== OTP VERIFY ==========');
      debugPrint('Phone: $phone');
      debugPrint('OTP length: ${otp.length}');
      debugPrint('OTP: $otp');

      final response = await _authRepository.verifyOtp(
        phone: phone,
        otp: otp,
      );

      debugPrint('OTP RESPONSE SESSION: ${response.session != null}');
      debugPrint('OTP RESPONSE USER: ${response.user?.id}');

      if (response.session != null) {
        _status = OtpStatus.success;

        debugPrint('OTP VERIFY SUCCESS');
      } else {
        _status = OtpStatus.invalidOtp;

        debugPrint('OTP VERIFY FAILED: Session is null');
      }
    } on AuthException catch (e, stackTrace) {
      debugPrint('========== SUPABASE AUTH ERROR ==========');
      debugPrint('Message: ${e.message}');
      debugPrint('Status code: ${e.statusCode}');
      debugPrint('Error: $e');
      debugPrint('$stackTrace');

      _status = OtpStatus.invalidOtp;
    } on TimeoutException catch (e) {
      debugPrint('OTP TIMEOUT: $e');

      _status = OtpStatus.networkError;
    } catch (e, stackTrace) {
      debugPrint('========== OTP UNKNOWN ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('$stackTrace');

      _status = OtpStatus.networkError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendCode() async {
    if (_isLoading || !canResend) return;

    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      debugPrint('RESEND ERROR: Phone number is null');

      _status = OtpStatus.networkError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _status = OtpStatus.loading;

    notifyListeners();

    try {
      final phone = _normalizePhone(_phoneNumber!);

      debugPrint('========== OTP RESEND ==========');
      debugPrint('Phone: $phone');

      await _authRepository.sendOtp(
        phone: phone,
      );

      debugPrint('OTP RESEND SUCCESS');

      otpController.clear();

      _status = OtpStatus.initial;

      startTimer();
    } on AuthException catch (e, stackTrace) {
      debugPrint('========== RESEND AUTH ERROR ==========');
      debugPrint('Message: ${e.message}');
      debugPrint('Status code: ${e.statusCode}');
      debugPrint('$stackTrace');

      _status = OtpStatus.networkError;
    } catch (e, stackTrace) {
      debugPrint('========== RESEND ERROR ==========');
      debugPrint('$e');
      debugPrint('$stackTrace');

      _status = OtpStatus.networkError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStatus() {
    _status = OtpStatus.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();

    super.dispose();
  }

  void setDemoOtp() {
    otpController.value = const TextEditingValue(
      text: '123456',
      selection: TextSelection.collapsed(offset: 6),
    );

    _status = OtpStatus.initial;

    notifyListeners();
  }

}
