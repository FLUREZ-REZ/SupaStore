import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  static const String _notificationsKey =
      'settings_notifications_enabled';

  bool getNotificationsEnabled() {
    return _preferences.getBool(
      _notificationsKey,
    ) ??
        true;
  }

  Future<bool> setNotificationsEnabled(
      bool enabled,
      ) async {
    return _preferences.setBool(
      _notificationsKey,
      enabled,
    );
  }
}