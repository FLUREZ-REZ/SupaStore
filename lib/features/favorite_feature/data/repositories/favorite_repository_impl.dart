import 'package:supastore/features/favorite_feature/data/datasource/favorite_remote_datasource.dart';

import 'package:supastore/features/favorite_feature/domain/entities/favorite_entity.dart';

import 'package:supastore/features/favorite_feature/domain/repositories/favorite_repository.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class FavoriteRepositoryImpl
    implements FavoriteRepository {
  FavoriteRepositoryImpl({
    required FavoriteRemoteDataSource
    remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource;

  final FavoriteRemoteDataSource
  _remoteDataSource;

  // ============================================================
  // ADD
  // ============================================================

  @override
  Future<FavoriteEntity> addFavorite({
    required String userId,
    required String productId,
  }) async {
    return await _remoteDataSource
        .addFavorite(
      userId: userId,
      productId: productId,
    );
  }

  // ============================================================
  // REMOVE
  // ============================================================

  @override
  Future<void> removeFavorite({
    required String userId,
    required String productId,
  }) async {
    await _remoteDataSource
        .removeFavorite(
      userId: userId,
      productId: productId,
    );
  }

  // ============================================================
  // IS FAVORITE
  // ============================================================

  @override
  Future<bool> isFavorite({
    required String userId,
    required String productId,
  }) async {
    return await _remoteDataSource
        .isFavorite(
      userId: userId,
      productId: productId,
    );
  }

  // ============================================================
  // GET FAVORITES
  // ============================================================

  @override
  Future<List<FavoriteEntity>> getFavorites({
    required String userId,
  }) async {
    return await _remoteDataSource
        .getFavorites(
      userId: userId,
    );
  }

  // ============================================================
  // GET FAVORITE PRODUCTS
  // ============================================================

  @override
  Future<List<ProductEntity>>
  getFavoriteProducts({
    required String userId,
  }) async {
    return await _remoteDataSource
        .getFavoriteProducts(
      userId: userId,
    );
  }
}