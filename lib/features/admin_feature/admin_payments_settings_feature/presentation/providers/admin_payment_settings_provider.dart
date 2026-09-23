import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_payment_settings_entity.dart';
import '../../domain/usecases/get_admin_payment_settings.dart';
import '../../domain/usecases/update_admin_payment_settings.dart';

class AdminPaymentSettingsProvider extends ChangeNotifier {
  AdminPaymentSettingsProvider({
    required GetAdminPaymentSettings getPaymentSettings,
    required UpdateAdminPaymentSettings updatePaymentSettings,
  })  : _getPaymentSettings = getPaymentSettings,
        _updatePaymentSettings = updatePaymentSettings;

  final GetAdminPaymentSettings _getPaymentSettings;
  final UpdateAdminPaymentSettings _updatePaymentSettings;

  AdminPaymentSettingsEntity? _settings;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  AdminPaymentSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get error => _error;

  Future<void> loadSettings() async {
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

  Future<bool> saveSettings({
    required bool onlinePaymentEnabled,
    required bool zarinpalEnabled,
    required bool sepEnabled,
    required String defaultGateway,
  }) async {
    if (_settings == null) {
      _error = 'تنظیمات پرداخت بارگذاری نشده است.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _updatePaymentSettings(
        id: _settings!.id,
        onlinePaymentEnabled: onlinePaymentEnabled,
        zarinpalEnabled: zarinpalEnabled,
        sepEnabled: sepEnabled,
        defaultGateway: defaultGateway,
      );

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('PGRST116')) {
      return 'تنظیمات پرداخت پیدا نشد.';
    }

    if (message.contains('42501')) {
      return 'شما دسترسی لازم برای تغییر تنظیمات پرداخت را ندارید.';
    }

    return 'خطایی در تنظیمات پرداخت رخ داد.';
  }
}