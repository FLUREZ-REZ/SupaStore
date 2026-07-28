import 'dart:async';

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

  final TextEditingController otpController =
  TextEditingController();

  static const int _initialSeconds = 60;

  Timer? _timer;

  int _secondsRemaining = _initialSeconds;

  bool _isLoading = false;

  OtpStatus _status = OtpStatus.initial;

  String? _phoneNumber;

  bool get isLoading => _isLoading;

  int get secondsRemaining => _secondsRemaining;

  bool get canResend => _secondsRemaining == 0;

  bool get isOtpComplete =>
      otpController.text.length == 6;

  OtpStatus get status => _status;

  String get formattedTime {
    final minutes =
    (_secondsRemaining ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds =
    (_secondsRemaining % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void setPhone(String phone) {
    _phoneNumber = phone;
  }

  void onOtpChanged(String value) {
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();

    _secondsRemaining = _initialSeconds;

    notifyListeners();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_secondsRemaining == 0) {
          timer.cancel();
          return;
        }

        _secondsRemaining--;

        notifyListeners();
      },
    );
  }

  Future<void> verifyCode() async {
    if (!isOtpComplete) return;

    if (_phoneNumber == null) return;

    _isLoading = true;

    _status = OtpStatus.loading;

    notifyListeners();

    try {
      final response =
      await _authRepository.verifyOtp(
        phone: _phoneNumber!,
        otp: otpController.text.trim(),
      );

      if (response.session != null) {
        _status = OtpStatus.success;
      } else {
        _status = OtpStatus.invalidOtp;
      }
    } on AuthException {
      _status = OtpStatus.invalidOtp;
    } on TimeoutException {
      _status = OtpStatus.networkError;
    } catch (_) {
      _status = OtpStatus.networkError;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    if (_phoneNumber == null) return;

    _isLoading = true;

    notifyListeners();

    try {
      await _authRepository.sendOtp(
        phone: _phoneNumber!,
      );

      startTimer();
    } catch (_) {} finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clearStatus() {
    _status = OtpStatus.initial;
  }

  @override
  void dispose() {
    _timer?.cancel();

    otpController.dispose();

    super.dispose();
  }
}