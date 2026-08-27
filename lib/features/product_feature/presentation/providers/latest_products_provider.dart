import 'package:flutter/material.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';

class LatestProductsProvider extends ChangeNotifier {
  LatestProductsProvider({
    required ProductRepository repository,
  }) : _repository = repository;

  final ProductRepository _repository;

  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int _pageSize = 20;

  int get pageSize => _pageSize;

  // ============================================================
  // PRODUCTS
  // ============================================================

  final List<ProductEntity> _products = [];

  List<ProductEntity> get products =>
      List.unmodifiable(_products);

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

  // ============================================================
  // NEXT PAGE
  // ============================================================

  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;

  // ============================================================
  // PREVIOUS PAGE
  // ============================================================

  bool get hasPreviousPage => _page > 0;

  // ============================================================
  // LOAD INITIAL PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;

    _page = 0;
    _hasNextPage = true;

    _products.clear();

    notifyListeners();

    try {
      final result =
      await _repository.getNewestProducts(
        page: _page,
        limit: _pageSize,
      );

      _products.addAll(result);

      if (result.length < _pageSize) {
        _hasNextPage = false;
      }
    } catch (e) {
      _error = e.toString();

      debugPrint(
        '❌ Latest products loading error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
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

    final previousPage = _page - 1;

    await _loadPage(
      page: previousPage,
    );
  }

  // ============================================================
  // LOAD SPECIFIC PAGE
  // ============================================================

  Future<void> _loadPage({
    required int page,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getNewestProducts(
        page: page,
        limit: _pageSize,
      );

      _products
        ..clear()
        ..addAll(result);

      _page = page;

      _hasNextPage =
          result.length == _pageSize;
    } catch (e) {
      _error = e.toString();

      debugPrint(
        '❌ Latest products page loading error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadProducts();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _products.clear();

    _page = 0;

    _hasNextPage = true;

    _error = null;

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}