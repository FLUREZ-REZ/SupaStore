import 'package:flutter/foundation.dart';

import '../../domain/entities/payment_settings_entity.dart';
import '../../domain/usecases/get_payment_settings.dart';

class PaymentSettingsProvider extends ChangeNotifier {
  PaymentSettingsProvider({
    required GetPaymentSettings getPaymentSettings,
  }) : _getPaymentSettings = getPaymentSettings;

  final GetPaymentSettings _getPaymentSettings;

  PaymentSettingsEntity? _settings;

  bool _isLoading = false;
  String? _error;

  PaymentSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get onlinePaymentEnabled =>
      _settings?.onlinePaymentEnabled ?? false;

  bool get zarinpalEnabled =>
      _settings?.zarinpalEnabled ?? false;

  bool get sepEnabled =>
      _settings?.sepEnabled ?? false;

  String get defaultGateway =>
      _settings?.defaultGateway ?? 'zarinpal';

  Future<void> loadSettings() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _settings = await _getPaymentSettings();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('PGRST116')) {
      return 'تنظیمات پرداخت پیدا نشد.';
    }

    if (message.contains('42501')) {
      return 'دسترسی به تنظیمات پرداخت امکان‌پذیر نیست.';
    }

    return 'خطایی در دریافت تنظیمات پرداخت رخ داد.';
  }
}