import 'package:flutter/material.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';


class ProductProvider extends ChangeNotifier {

  ProductProvider({
    required ProductRepository repository,
  }) : _repository = repository;


  final ProductRepository _repository;


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


  static const int _pageSize = 10;



  /// همه محصولات
  Future<void> loadProducts() async {

    if (_isLoading) return;


    _isLoading = true;

    _error = null;

    _page = 0;

    _hasMore = true;

    _products.clear();


    notifyListeners();


    try {

      final result =
      await _repository.getProducts(
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



  Future<void> loadNewestProducts() async {

    if (_isLoading) return;


    _isLoading = true;

    _error = null;

    _products.clear();


    notifyListeners();


    try {

      debugPrint("🔥 Loading newest products...");


      final result =
      await _repository.getNewestProducts(
        page: 0,
        limit: _pageSize,
      );


      debugPrint(
        "✅ Newest products count: ${result.length}",
      );


      _products.addAll(result);


    } catch (e) {

      debugPrint(
        "❌ Newest products error: $e",
      );

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

      final result =
      await _repository.getProducts(
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
  Future<void> refresh() async {

    await loadProducts();

  }

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

}