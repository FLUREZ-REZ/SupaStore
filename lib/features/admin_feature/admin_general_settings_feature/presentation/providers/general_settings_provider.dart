import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_general_settings_entity.dart';
import '../../domain/usecases/get_admin_general_settings.dart';

class GeneralSettingsProvider extends ChangeNotifier {
  GeneralSettingsProvider({
    required GetAdminGeneralSettings getGeneralSettings,
  }) : _getGeneralSettings = getGeneralSettings;

  final GetAdminGeneralSettings _getGeneralSettings;

  AdminGeneralSettingsEntity? _settings;

  bool _isLoading = false;
  String? _error;

  AdminGeneralSettingsEntity? get settings => _settings;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasSettings => _settings != null;

  bool get maintenanceMode =>
      _settings?.maintenanceMode ?? false;

  bool get registrationEnabled =>
      _settings?.registrationEnabled ?? true;

  bool get shoppingEnabled =>
      _settings?.shoppingEnabled ?? true;

  bool get showUnavailableProducts =>
      _settings?.showUnavailableProducts ?? true;

  bool get reviewsEnabled =>
      _settings?.reviewsEnabled ?? true;

  bool get verifiedPurchaseReviewsOnly =>
      _settings?.verifiedPurchaseReviewsOnly ?? false;

  int get minimumOrderAmount =>
      _settings?.minimumOrderAmount ?? 0;

  int get maxCartQuantity =>
      _settings?.maxCartQuantity ?? 20;

  String get appName =>
      _settings?.appName ?? 'SupaStore';

  String get maintenanceMessage =>
      _settings?.maintenanceMessage ??
          'فروشگاه در حال بروزرسانی است. لطفاً بعداً دوباره مراجعه کنید.';

  Future<void> loadSettings() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;

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

  Future<void> refresh() async {
    await loadSettings();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('PGRST116')) {
      return 'تنظیمات عمومی سیستم پیدا نشد.';
    }

    if (message.contains('network') ||
        message.contains('SocketException')) {
      return 'خطا در اتصال به سرور. لطفاً دوباره تلاش کنید.';
    }

    return 'خطایی در دریافت تنظیمات عمومی رخ داد.';
  }
}