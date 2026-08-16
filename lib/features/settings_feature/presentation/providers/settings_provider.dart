import 'package:flutter/foundation.dart';

import 'package:supastore/features/settings_feature/data/datasources/settings_local_data_source.dart';

class SettingsProvider
    extends ChangeNotifier {
  SettingsProvider({
    required SettingsLocalDataSource
    localDataSource,
  }) : _localDataSource =
      localDataSource;

  final SettingsLocalDataSource
  _localDataSource;

  bool _notificationsEnabled = true;

  bool get notificationsEnabled =>
      _notificationsEnabled;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _notificationsEnabled =
        _localDataSource
            .getNotificationsEnabled();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(
      bool enabled,
      ) async {
    final oldValue =
        _notificationsEnabled;

    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final success =
      await _localDataSource
          .setNotificationsEnabled(
        enabled,
      );

      if (!success) {
        _notificationsEnabled =
            oldValue;
        notifyListeners();
      }
    } catch (e) {
      _notificationsEnabled =
          oldValue;
      notifyListeners();
    }
  }

  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(
      !_notificationsEnabled,
    );
  }
}