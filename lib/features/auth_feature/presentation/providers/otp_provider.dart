import 'dart:async';

import 'package:flutter/material.dart';

enum OtpStatus {
  initial,
  loading,
  success,
  invalidOtp,
  networkError,
}

class OtpProvider extends ChangeNotifier {
  final TextEditingController otpController = TextEditingController();

  static const int _initialSeconds = 60;

  Timer? _timer;

  int _secondsRemaining = _initialSeconds;

  bool _isLoading = false;

  OtpStatus _status = OtpStatus.initial;



  bool get isLoading => _isLoading;

  int get secondsRemaining => _secondsRemaining;

  bool get canResend => _secondsRemaining == 0;

  bool get isOtpComplete => otpController.text.length == 6;

  OtpStatus get status => _status;

  String get formattedTime {
    final minutes =
    (_secondsRemaining ~/ 60).toString().padLeft(2, '0');

    final seconds =
    (_secondsRemaining % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
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

    _isLoading = true;
    _status = OtpStatus.loading;

    notifyListeners();

    try {

      await Future.delayed(
        const Duration(seconds: 2),
      );

      _status = OtpStatus.success;
    } on TimeoutException {
      _status = OtpStatus.networkError;
    } catch (_) {
      _status = OtpStatus.invalidOtp;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    _isLoading = true;

    notifyListeners();

    try {

      await Future.delayed(
        const Duration(seconds: 2),
      );

      startTimer();
    } finally {
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