import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_store_settings_entity.dart';
import '../../domain/usecases/get_admin_store_settings.dart';
import '../../domain/usecases/remove_admin_store_logo.dart';
import '../../domain/usecases/update_admin_store_logo.dart';
import '../../domain/usecases/update_admin_store_settings.dart';

class AdminStoreSettingsProvider
    extends ChangeNotifier {
  AdminStoreSettingsProvider({
    required GetAdminStoreSettings getSettings,
    required UpdateAdminStoreSettings updateSettings,
    required UpdateAdminStoreLogo updateLogo,
    required RemoveAdminStoreLogo removeLogo,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        _updateLogo = updateLogo,
        _removeLogo = removeLogo;

  final GetAdminStoreSettings _getSettings;
  final UpdateAdminStoreSettings _updateSettings;
  final UpdateAdminStoreLogo _updateLogo;
  final RemoveAdminStoreLogo _removeLogo;

  AdminStoreSettingsEntity? _settings;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isRemovingLogo = false;

  String? _error;

  AdminStoreSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingLogo => _isUploadingLogo;
  bool get isRemovingLogo => _isRemovingLogo;

  bool get isLogoBusy =>
      _isUploadingLogo || _isRemovingLogo;

  String? get error => _error;

  Future<void> loadSettings() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _getSettings();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings({
    required AdminStoreSettingsEntity settings,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _updateSettings(
        settings: settings,
      );

      _isSaving = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      _isSaving = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateLogo({
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    if (_isUploadingLogo) {
      return false;
    }

    final currentSettings = _settings;

    if (currentSettings == null) {
      _error = 'تنظیمات فروشگاه هنوز دریافت نشده است.';
      notifyListeners();
      return false;
    }

    _isUploadingLogo = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _updateLogo(
        settingsId: currentSettings.id,
        oldLogoUrl: currentSettings.logoUrl,
        bytes: bytes,
        extension: extension,
        contentType: contentType,
      );

      _isUploadingLogo = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      _isUploadingLogo = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> removeLogo() async {
    if (_isRemovingLogo) {
      return false;
    }

    final currentSettings = _settings;

    if (currentSettings == null) {
      _error = 'تنظیمات فروشگاه هنوز دریافت نشده است.';
      notifyListeners();
      return false;
    }

    if (currentSettings.logoUrl == null ||
        currentSettings.logoUrl!.trim().isEmpty) {
      return true;
    }

    _isRemovingLogo = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _removeLogo(
        settingsId: currentSettings.id,
        logoUrl: currentSettings.logoUrl,
      );

      _isRemovingLogo = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      _isRemovingLogo = false;
      notifyListeners();

      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}