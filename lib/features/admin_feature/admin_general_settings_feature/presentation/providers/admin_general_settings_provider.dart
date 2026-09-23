import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_general_settings_entity.dart';
import '../../domain/usecases/get_admin_general_settings.dart';
import '../../domain/usecases/update_admin_general_settings.dart';

class AdminGeneralSettingsProvider extends ChangeNotifier {
  AdminGeneralSettingsProvider({
    required GetAdminGeneralSettings getGeneralSettings,
    required UpdateAdminGeneralSettings updateGeneralSettings,
  })  : _getGeneralSettings = getGeneralSettings,
        _updateGeneralSettings = updateGeneralSettings;

  final GetAdminGeneralSettings _getGeneralSettings;
  final UpdateAdminGeneralSettings _updateGeneralSettings;

  AdminGeneralSettingsEntity? _settings;

  bool _isLoading = false;
  bool _isSaving = false;

  String? _error;
  String? _successMessage;

  AdminGeneralSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _settings = await _getGeneralSettings();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings({
    required AdminGeneralSettingsEntity settings,
  }) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _settings = await _updateGeneralSettings(
        settings: settings,
      );

      _successMessage =
      'تنظیمات عمومی با موفقیت ذخیره شد.';

      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('42501')) {
      return 'شما دسترسی لازم برای تغییر تنظیمات را ندارید.';
    }

    if (message.contains('PGRST116')) {
      return 'تنظیمات عمومی سیستم پیدا نشد.';
    }

    if (message.contains('network') ||
        message.contains('SocketException')) {
      return 'خطا در اتصال به سرور. لطفاً دوباره تلاش کنید.';
    }

    return 'خطایی در دریافت یا ذخیره تنظیمات رخ داد.';
  }
}