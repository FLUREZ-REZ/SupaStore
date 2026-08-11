import 'package:flutter/foundation.dart';

import 'package:supastore/features/favorite_feature/domain/entities/favorite_entity.dart';

import 'package:supastore/features/favorite_feature/domain/repositories/favorite_repository.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider({
    required FavoriteRepository repository,
  }) : _repository = repository;

  final FavoriteRepository _repository;

  // ============================================================
  // FAVORITES
  // ============================================================

  List<FavoriteEntity> _favorites = [];

  List<FavoriteEntity> get favorites =>
      List.unmodifiable(_favorites);

  // ============================================================
  // FAVORITE PRODUCTS
  // ============================================================

  List<ProductEntity> _favoriteProducts = [];

  List<ProductEntity>
  get favoriteProducts =>
      List.unmodifiable(
        _favoriteProducts,
      );

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
  // PRODUCT LOADING
  // ============================================================

  final Set<String>
  _loadingProductIds = {};

  bool isProductLoading(
      String productId,
      ) {
    return _loadingProductIds
        .contains(productId);
  }

  // ============================================================
  // LOAD FAVORITES
  // ============================================================

  Future<void> loadFavorites({
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final favorites =
      await _repository.getFavorites(
        userId: userId,
      );

      final products =
      await _repository
          .getFavoriteProducts(
        userId: userId,
      );

      _favorites = favorites;

      _favoriteProducts = products;

      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _error = e.toString();

      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // IS FAVORITE
  // ============================================================

  bool isFavorite(
      String productId,
      ) {
    return _favorites.any(
          (favorite) =>
      favorite.productId ==
          productId,
    );
  }

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<bool> addFavorite({
    required String userId,
    required String productId,
  }) async {
    if (_loadingProductIds
        .contains(productId)) {
      return false;
    }

    if (isFavorite(productId)) {
      return true;
    }

    _loadingProductIds.add(productId);

    _error = null;

    notifyListeners();

    try {
      final favorite =
      await _repository.addFavorite(
        userId: userId,
        productId: productId,
      );

      _favorites = [
        ..._favorites,
        favorite,
      ];

      _loadingProductIds
          .remove(productId);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _loadingProductIds
          .remove(productId);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<bool> removeFavorite({
    required String userId,
    required String productId,
  }) async {
    if (_loadingProductIds
        .contains(productId)) {
      return false;
    }

    _loadingProductIds.add(productId);

    _error = null;

    notifyListeners();

    try {
      await _repository
          .removeFavorite(
        userId: userId,
        productId: productId,
      );

      _favorites = _favorites
          .where(
            (favorite) =>
        favorite.productId !=
            productId,
      )
          .toList();

      _favoriteProducts =
          _favoriteProducts
              .where(
                (product) =>
            product.id !=
                productId,
          )
              .toList();

      _loadingProductIds
          .remove(productId);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      _loadingProductIds
          .remove(productId);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // TOGGLE
  // ============================================================

  Future<bool> toggleFavorite({
    required String userId,
    required String productId,
  }) async {
    if (isFavorite(productId)) {
      return await removeFavorite(
        userId: userId,
        productId: productId,
      );
    }

    return await addFavorite(
      userId: userId,
      productId: productId,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearFavorites() {
    _favorites = [];

    _favoriteProducts = [];

    _error = null;

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