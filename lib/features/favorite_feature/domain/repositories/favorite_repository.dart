import 'package:supastore/features/favorite_feature/domain/entities/favorite_entity.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

abstract class FavoriteRepository {
  Future<FavoriteEntity> addFavorite({
    required String userId,
    required String productId,
  });

  Future<void> removeFavorite({
    required String userId,
    required String productId,
  });

  Future<bool> isFavorite({
    required String userId,
    required String productId,
  });

  Future<List<FavoriteEntity>> getFavorites({
    required String userId,
  });

  Future<List<ProductEntity>> getFavoriteProducts({
    required String userId,
  });
}