import 'package:flutter/material.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required ProductRepository repository,
  }) : _repository = repository;

  final ProductRepository _repository;

  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int _pageSize = 10;

  // ============================================================
  // STATE
  // ============================================================

  final List<ProductEntity> _products = [];

  List<ProductEntity> get products =>
      List.unmodifiable(_products);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  String? _error;

  String? get error => _error;

  int _page = 0;

  int get currentPage => _page;

  // ============================================================
  // CURRENT PRODUCT TYPE
  // ============================================================

  ProductListType _currentType =
      ProductListType.all;

  ProductListType get currentType =>
      _currentType;

  String? _currentCategoryId;

  String? get currentCategoryId =>
      _currentCategoryId;

  // ============================================================
  // LOAD ALL PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }

    _currentType = ProductListType.all;

    _currentCategoryId = null;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD NEWEST PRODUCTS
  // ============================================================

  Future<void> loadNewestProducts() async {
    if (_isLoading) {
      return;
    }

    _currentType =
        ProductListType.newest;

    _currentCategoryId = null;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD FEATURED PRODUCTS
  // ============================================================

  Future<void> loadFeaturedProducts() async {
    if (_isLoading) {
      return;
    }

    _currentType =
        ProductListType.featured;

    _currentCategoryId = null;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD DISCOUNT PRODUCTS
  // ============================================================

  Future<void> loadDiscountProducts() async {
    if (_isLoading) {
      return;
    }

    _currentType =
        ProductListType.discount;

    _currentCategoryId = null;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD POPULAR PRODUCTS
  // ============================================================

  Future<void> loadPopularProducts() async {
    if (_isLoading) {
      return;
    }

    _currentType =
        ProductListType.popular;

    _currentCategoryId = null;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD CATEGORY PRODUCTS
  // ============================================================

  Future<void> loadProductsByCategory({
    required String categoryId,
  }) async {
    if (_isLoading) {
      return;
    }

    _currentType =
        ProductListType.category;

    _currentCategoryId =
        categoryId;

    await _loadFirstPage();
  }

  // ============================================================
  // LOAD FIRST PAGE
  // ============================================================

  Future<void> _loadFirstPage() async {
    _isLoading = true;

    _error = null;

    _page = 0;

    _hasMore = true;

    _products.clear();

    notifyListeners();

    try {
      final result =
      await _fetchProducts(
        page: 0,
      );

      _products.addAll(result);

      if (result.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();

      debugPrint(
        '❌ Product loading error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // LOAD NEXT PAGE
  // ============================================================

  Future<void> loadMore() async {
    if (_isLoading) {
      return;
    }

    if (_isLoadingMore) {
      return;
    }

    if (!_hasMore) {
      return;
    }

    _isLoadingMore = true;

    _error = null;

    notifyListeners();

    final nextPage = _page + 1;

    try {
      final result =
      await _fetchProducts(
        page: nextPage,
      );

      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(result);

        _page = nextPage;

        if (result.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();

      debugPrint(
        '❌ Load more products error: $e',
      );
    }

    _isLoadingMore = false;

    notifyListeners();
  }

  // ============================================================
  // FETCH PRODUCTS BASED ON CURRENT TYPE
  // ============================================================

  Future<List<ProductEntity>> _fetchProducts({
    required int page,
  }) async {
    switch (_currentType) {
      case ProductListType.all:
        return await _repository.getProducts(
          page: page,
          limit: _pageSize,
        );

      case ProductListType.newest:
        return await _repository.getNewestProducts(
          page: page,
          limit: _pageSize,
        );

      case ProductListType.featured:
        return await _repository.getFeaturedProducts(
          page: page,
          limit: _pageSize,
        );

      case ProductListType.discount:
        return await _repository.getDiscountProducts(
          page: page,
          limit: _pageSize,
        );

      case ProductListType.popular:
        return await _repository.getPopularProducts(
          page: page,
          limit: _pageSize,
        );

      case ProductListType.category:
        if (_currentCategoryId == null ||
            _currentCategoryId!.isEmpty) {
          throw Exception(
            'Category ID is required.',
          );
        }

        return await _repository
            .getProductsByCategory(
          categoryId: _currentCategoryId!,
          page: page,
          limit: _pageSize,
        );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    switch (_currentType) {
      case ProductListType.all:
        await loadProducts();
        break;

      case ProductListType.newest:
        await loadNewestProducts();
        break;

      case ProductListType.featured:
        await loadFeaturedProducts();
        break;

      case ProductListType.discount:
        await loadDiscountProducts();
        break;

      case ProductListType.popular:
        await loadPopularProducts();
        break;

      case ProductListType.category:
        if (_currentCategoryId != null &&
            _currentCategoryId!.isNotEmpty) {
          await loadProductsByCategory(
            categoryId: _currentCategoryId!,
          );
        }
        break;
    }
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  Future<ProductEntity?> getProductById(
      String productId,
      ) async {
    try {
      return await _repository.getProductById(
        productId,
      );
    } catch (e) {
      debugPrint(
        '❌ Get product by id error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }
}

// ================================================================
// PRODUCT LIST TYPE
// ================================================================

enum ProductListType {
  all,
  newest,
  featured,
  discount,
  popular,
  category,
}