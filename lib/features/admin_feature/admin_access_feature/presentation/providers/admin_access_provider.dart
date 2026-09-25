import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_access_entity.dart';
import '../../domain/usecases/get_current_user_access.dart';

class AdminAccessProvider extends ChangeNotifier {
  AdminAccessProvider({
    required GetCurrentUserAccess getCurrentUserAccess,
  }) : _getCurrentUserAccess = getCurrentUserAccess;

  final GetCurrentUserAccess _getCurrentUserAccess;

  AdminAccessEntity? _access;

  AdminAccessEntity? get access => _access;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get canAccessAdmin =>
      _access?.canAccessAdmin ?? false;

  bool get isSuperAdmin =>
      _access?.isSuperAdmin ?? false;

  bool get isOrderManager =>
      _access?.isOrderManager ?? false;

  bool get isProductManager =>
      _access?.isProductManager ?? false;

  String get adminRole =>
      _access?.adminRole ?? 'none';

  Future<void> loadAccess() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _access = await _getCurrentUserAccess();
    } catch (e) {
      _errorMessage = e.toString();
      _access = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _access = null;
    _errorMessage = null;
    notifyListeners();
  }
}