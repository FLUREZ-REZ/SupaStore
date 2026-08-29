import 'package:flutter/foundation.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/domain/repositories/product_repository.dart';



class RelatedProductsProvider extends ChangeNotifier {
  RelatedProductsProvider({
    required ProductRepository repository,
  }) : _repository = repository;

  final ProductRepository _repository;

  // =========================================================
  // STATE
  // =========================================================

  List<ProductEntity> _products = [];

  bool _isLoading = false;

  String? _error;

  bool _hasLoaded = false;

  // =========================================================
  // GETTERS
  // =========================================================

  List<ProductEntity> get products => _products;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasLoaded => _hasLoaded;

  // =========================================================
  // LOAD RELATED PRODUCTS
  // =========================================================

  Future<void> loadRelatedProducts({
    required String categoryId,
    required String productId,
    int limit = 6,
  }) async {
    // جلوگیری از درخواست تکراری
    if (_isLoading) {
      return;
    }

    debugPrint('========================================');
    debugPrint('🔵 RELATED PRODUCTS START');
    debugPrint('categoryId: $categoryId');
    debugPrint('productId: $productId');
    debugPrint('limit: $limit');

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final result =
      await _repository.getRelatedProducts(
        categoryId: categoryId,
        productId: productId,
        limit: limit,
      );

      debugPrint(
        '🟢 RELATED PRODUCTS RESULT: ${result.length}',
      );

      _products = result;

      _hasLoaded = true;
    } catch (e) {
      debugPrint(
        '🔴 RELATED PRODUCTS ERROR: $e',
      );


      _error = e.toString();

      _products = [];
    } finally {
      _isLoading = false;

      notifyListeners();

      debugPrint('🔵 RELATED PRODUCTS END');
      debugPrint('========================================');
    }
  }

  // =========================================================
  // CLEAR
  // =========================================================

  void clear() {
    _products = [];

    _error = null;

    _isLoading = false;

    _hasLoaded = false;

    notifyListeners();
  }
}