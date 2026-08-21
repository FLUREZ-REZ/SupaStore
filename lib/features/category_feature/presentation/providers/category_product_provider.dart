import 'package:flutter/material.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';

import '../../../product_feature/domain/entities/product_entity.dart';
import '../../domain/repositories/category_product_repository.dart';

class CategoryProductProvider extends ChangeNotifier {
  CategoryProductProvider({
    required CategoryProductRepository repository,
  }) : _repository = repository;

  final CategoryProductRepository _repository;

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

  String? _categoryId;

  String? get categoryId => _categoryId;

  int _page = 0;

  static const int _pageSize = 10;

 
  Future<void> loadProducts({
    required String categoryId,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    _categoryId = categoryId;

    _page = 0;
    _hasMore = true;

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

      if (result.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;

    if (!_hasMore) return;

    if (_categoryId == null) return;

    _isLoadingMore = true;

    notifyListeners();

    try {
      final nextPage = _page + 1;

      final result =
      await _repository.getProductsByCategory(
        categoryId: _categoryId!,
        page: nextPage,
        limit: _pageSize,
      );

      _products.addAll(result);

      _page = nextPage;

      if (result.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingMore = false;

    notifyListeners();
  }

  Future<void> refresh() async {
    if (_categoryId == null) return;

    await loadProducts(
      categoryId: _categoryId!,
    );
  }

  void clear() {
    _products.clear();

    _categoryId = null;

    _page = 0;

    _hasMore = true;

    _error = null;

    notifyListeners();
  }

  Future<CategoryEntity?> getCategoryById(
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