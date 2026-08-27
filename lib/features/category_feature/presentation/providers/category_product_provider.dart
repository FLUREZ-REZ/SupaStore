import 'package:flutter/material.dart';

import '../../../product_feature/domain/entities/product_entity.dart';
import '../../domain/repositories/category_product_repository.dart';

class CategoryProductProvider extends ChangeNotifier {
  CategoryProductProvider({
    required CategoryProductRepository repository,
  }) : _repository = repository;

  final CategoryProductRepository _repository;

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
  // CATEGORY
  // ============================================================

  String? _categoryId;

  String? get categoryId => _categoryId;

  // ============================================================
  // PAGINATION
  // ============================================================

  int _page = 0;

  int get page => _page;

  static const int _pageSize = 10;

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
  // LOAD INITIAL PAGE
  // ============================================================

  Future<void> loadProducts({
    required String categoryId,
  }) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _error = null;

    _categoryId = categoryId;

    _page = 0;

    _hasNextPage = true;

    _products.clear();

    notifyListeners();

    try {
      final result =
      await _repository.getProductsByCategory(
        categoryId: categoryId,
        page: _page,
        limit: _pageSize,
      );

      _products.addAll(result);

      // اگر کمتر از 10 محصول برگشت،
      // یعنی صفحه بعدی وجود ندارد.
      if (result.length < _pageSize) {
        _hasNextPage = false;
      }
    } catch (e) {
      _error = e.toString();
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

    if (_categoryId == null) {
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
    if (_categoryId == null) {
      return;
    }

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getProductsByCategory(
        categoryId: _categoryId!,
        page: page,
        limit: _pageSize,
      );

      _products
        ..clear()
        ..addAll(result);

      _page = page;

      // اگر 10 محصول کامل برگشته،
      // احتمال وجود صفحه بعدی هست.
      //
      // اگر کمتر از 10 برگشته،
      // این آخرین صفحه است.
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
    if (_categoryId == null) {
      return;
    }

    await loadProducts(
      categoryId: _categoryId!,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _products.clear();

    _categoryId = null;

    _page = 0;

    _hasNextPage = true;

    _error = null;

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // GET CATEGORY
  // ============================================================

  Future<dynamic> getCategoryById(
      String categoryId,
      ) async {
    try {
      return await _repository.getCategoryById(
        categoryId,
      );
    } catch (e) {
      debugPrint(
        '❌ Get category by id error: $e',
      );

      return null;
    }
  }
}