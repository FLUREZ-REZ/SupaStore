import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({
    required SearchRepository repository,
  }) : _repository = repository {
    loadHistory();
  }

  final SearchRepository _repository;

  // ============================================================
  // DEBOUNCE
  // ============================================================

  Timer? _debounce;

  static const Duration _debounceDuration = Duration(
    milliseconds: 400,
  );

  // ============================================================
  // PRODUCTS
  // ============================================================

  final List<ProductEntity> _products = [];

  List<ProductEntity> get products =>
      List.unmodifiable(_products);

  // ============================================================
  // SEARCH QUERY
  // ============================================================

  String _query = '';

  String get query => _query;

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ============================================================
  // ERROR
  // ============================================================

  String? _error;

  String? get error => _error;

  // ============================================================
  // PAGINATION
  // ============================================================

  int _page = 0;

  int get page => _page;

  static const int _pageSize = 20;

  int get pageSize => _pageSize;

  // ============================================================
  // HAS NEXT PAGE
  // ============================================================

  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;

  // ============================================================
  // HAS PREVIOUS PAGE
  // ============================================================

  bool get hasPreviousPage => _page > 0;

  // ============================================================
  // SEARCH
  // ============================================================

  void search(String value) {
    final newQuery = value.trim();

    // قبلی را لغو می‌کنیم.
    _debounce?.cancel();

    // ==========================================================
    // EMPTY QUERY
    // ==========================================================

    if (newQuery.isEmpty) {
      _query = '';

      _products.clear();

      _page = 0;

      _hasNextPage = false;

      _error = null;

      _isLoading = false;

      notifyListeners();

      return;
    }

    // ==========================================================
    // NEW QUERY
    // ==========================================================

    _query = newQuery;

    _page = 0;

    _hasNextPage = true;

    _products.clear();

    _error = null;

    notifyListeners();

    // ==========================================================
    // START DEBOUNCE
    // ==========================================================

    _debounce = Timer(
      _debounceDuration,
          () {
        _loadPage(
          page: 0,
        );
      },
    );
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  Future<void> nextPage() async {
    if (_isLoading) {
      return;
    }

    if (!_hasNextPage) {
      return;
    }

    if (_query.isEmpty) {
      return;
    }

    final nextPage = _page + 1;

    await _loadPage(
      page: nextPage,
    );
  }

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  Future<void> previousPage() async {
    if (_isLoading) {
      return;
    }

    if (!hasPreviousPage) {
      return;
    }

    if (_query.isEmpty) {
      return;
    }

    final previousPage = _page - 1;

    await _loadPage(
      page: previousPage,
    );
  }

  // ============================================================
  // LOAD PAGE
  // ============================================================

  Future<void> _loadPage({
    required int page,
  }) async {
    if (_query.isEmpty) {
      return;
    }

    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {
      final result = await _repository.searchProducts(
        query: _query,
        page: page,
        limit: _pageSize,
      );

      _products
        ..clear()
        ..addAll(result);

      _page = page;

      // اگر 10 محصول برگشت،
      // احتمال وجود صفحه بعد وجود دارد.
      _hasNextPage = result.length == _pageSize;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    if (_query.isEmpty) {
      return;
    }

    await _loadPage(
      page: _page,
    );
  }

  // ============================================================
  // SEARCH HISTORY
  // ============================================================

  List<String> _history = [];

  List<String> get history =>
      List.unmodifiable(_history);

  // ============================================================
  // LOAD SEARCH HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs =
    await SharedPreferences.getInstance();

    _history = prefs.getStringList(
      'search_history',
    ) ??
        [];

    notifyListeners();
  }

  // ============================================================
  // ADD SEARCH HISTORY
  // ============================================================

  Future<void> addSearchHistory(
      String value,
      ) async {
    value = value.trim();

    if (value.isEmpty) {
      return;
    }

    // حذف مورد تکراری
    _history.remove(value);

    // مورد جدید اول لیست
    _history.insert(
      0,
      value,
    );

    // فقط 10 مورد آخر
    if (_history.length > 10) {
      _history = _history.sublist(
        0,
        10,
      );
    }

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setStringList(
      'search_history',
      _history,
    );

    notifyListeners();
  }

  // ============================================================
  // CLEAR SEARCH HISTORY
  // ============================================================

  Future<void> clearHistory() async {
    _history.clear();

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'search_history',
    );

    notifyListeners();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _debounce?.cancel();

    _products.clear();

    _query = '';

    _page = 0;

    _hasNextPage = false;

    _error = null;

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _debounce?.cancel();

    super.dispose();
  }
}