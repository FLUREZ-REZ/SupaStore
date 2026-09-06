import 'package:flutter/foundation.dart';
import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/Users/domain/usecases/get_admin_users.dart';

class AdminUserProvider extends ChangeNotifier {
  AdminUserProvider({
    required GetAdminUsers getUsers,
  }) : _getUsers = getUsers;

  static const int pageSize = 10;

  final GetAdminUsers _getUsers;

  final List<AdminUser> _users = [];

  List<AdminUser> get users =>
      List.unmodifiable(_users);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  int _page = 0;

  String _search = '';

  String? _error;

  String? get error => _error;

  Future<void> initialize() async {
    await loadUsers(
      refresh: true,
    );
  }

  Future<void> loadUsers({
    bool refresh = false,
    String? search,
  }) async {
    if (_isLoading || _isLoadingMore) {
      return;
    }

    if (refresh) {
      _page = 0;
      _hasMore = true;
      _users.clear();
    }

    if (search != null) {
      _search = search.trim();

      _page = 0;
      _hasMore = true;
      _users.clear();
    }

    final isFirstPage = _page == 0;

    if (isFirstPage) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _error = null;

    notifyListeners();

    try {
      final result = await _getUsers(
        page: _page,
        limit: pageSize,
        search: _search.isEmpty
            ? null
            : _search,
      );

      _users.addAll(result);

      if (result.length < pageSize) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _isLoadingMore = false;

    notifyListeners();
  }

  Future<void> refreshUsers() async {
    await loadUsers(
      refresh: true,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}