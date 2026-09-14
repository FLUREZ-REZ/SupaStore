import 'package:flutter/foundation.dart';

import 'package:supastore/features/admin_feature/settings/domain/entities/admin_store_settings_entity.dart';
import 'package:supastore/features/admin_feature/settings/domain/repositories/admin_store_settings_repository.dart';

class StoreSettingsProvider extends ChangeNotifier {
  StoreSettingsProvider({
    required AdminStoreSettingsRepository repository,
  }) : _repository = repository;

  final AdminStoreSettingsRepository _repository;

  AdminStoreSettingsEntity? _settings;

  bool _isLoading = false;
  String? _error;

  AdminStoreSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isReady => _settings != null;

  String get storeName {
    return _settings?.storeName.trim().isNotEmpty == true
        ? _settings!.storeName
        : 'SupaStore';
  }

  String? get logoUrl {
    final value = _settings?.logoUrl?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  String? get tagline => _settings?.tagline;

  String? get description => _settings?.description;

  String? get phone => _settings?.phone;

  String? get email => _settings?.email;

  String? get address => _settings?.address;

  String? get instagram => _settings?.instagram;

  String? get telegram => _settings?.telegram;

  String? get website => _settings?.website;

  Future<void> loadSettings({
    bool forceRefresh = false,
  }) async {
    if (_isLoading) {
      return;
    }

    if (_settings != null && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _settings = await _repository.getSettings();
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadSettings(
      forceRefresh: true,
    );
  }

  void setSettings(
      AdminStoreSettingsEntity settings,
      ) {
    _settings = settings;
    _error = null;

    notifyListeners();
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