import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required ProductRepository repository,
  }) : _repository = repository;

  final ProductRepository _repository;

  final List<ProductEntity> _products = [];

  List<ProductEntity> get products => List.unmodifiable(_products);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  int _page = 0;

  static const int _pageSize = 10;

  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _page = 0;
    _hasMore = true;
    _products.clear();

    notifyListeners();

    try {
      final result = await _repository.getProducts(
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

    _isLoadingMore = true;

    notifyListeners();

    try {
      _page++;

      final result = await _repository.getProducts(
        page: _page,
        limit: _pageSize,
      );

      _products.addAll(result);

      if (result.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _page--;

      _error = e.toString();
    }

    _isLoadingMore = false;

    notifyListeners();
  }

  /// Pull To Refresh
  Future<void> refresh() async {
    await loadProducts();
  }
}