import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/favorite_feature/domain/entities/favorite_entity.dart';
import 'package:supastore/features/product_feature/data/models/product_model.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class FavoriteRemoteDataSource {
  FavoriteRemoteDataSource({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<FavoriteEntity> addFavorite({
    required String userId,
    required String productId,
  }) async {
    final response = await _client
        .from('favorites')
        .insert({
      'user_id': userId,
      'product_id': productId,
    })
        .select()
        .single();

    return _favoriteFromMap(response);
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<void> removeFavorite({
    required String userId,
    required String productId,
  }) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  // ============================================================
  // IS FAVORITE
  // ============================================================

  Future<bool> isFavorite({
    required String userId,
    required String productId,
  }) async {
    final response = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // GET FAVORITES
  // ============================================================

  Future<List<FavoriteEntity>> getFavorites({
    required String userId,
  }) async {
    final response = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map(
          (item) => _favoriteFromMap(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  // ============================================================
  // GET FAVORITE PRODUCTS
  // ============================================================

  Future<List<ProductEntity>> getFavoriteProducts({
    required String userId,
  }) async {
    final response = await _client
        .from('favorites')
        .select('''
          id,
          user_id,
          product_id,
          created_at,
          products (
            *,
            brands (
              name,
              logo_url
            )
          )
        ''')
        .eq('user_id', userId)
        .order(
      'created_at',
      ascending: false,
    );

    final List<ProductEntity> products = [];

    for (final item in response as List) {
      final map =
      item as Map<String, dynamic>;

      final productData =
      map['products'];

      if (productData == null) {
        continue;
      }

      if (productData is Map<String, dynamic>) {
        products.add(
          ProductModel.fromMap(
            productData,
          ),
        );
      }
    }

    return products;
  }

  // ============================================================
  // FAVORITE MAPPER
  // ============================================================

  FavoriteEntity _favoriteFromMap(
      Map<String, dynamic> map,
      ) {
    return FavoriteEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      productId: map['product_id'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}