import 'package:supastore/features/cart_feature/data/datasource/cart_remote_datasource.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
import 'package:supastore/features/cart_feature/domain/repositories/cart_repository.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepositoryImpl
    implements CartRepository {
  CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource;

  final CartRemoteDataSource _remoteDataSource;

  final SupabaseClient _supabase =
      Supabase.instance.client;

  ProductEntity _mapProduct(
      Map<String, dynamic> map,
      ) {
    final brandData =
    map['brands']
    as Map<String, dynamic>?;

    final thumbnailPath =
    map['thumbnail'] as String;

    return ProductEntity(
      id: map['id'] as String,

      categoryId:
      map['category_id'] as String,

      brandId:
      map['brand_id'] as String?,

      title:
      map['title'] as String,

      slug:
      map['slug'] as String,

      description:
      map['description'] as String,

      /// همان Bucket محصولات اصلی
      thumbnail:
      _supabase.storage
          .from('assets')
          .getPublicUrl(
        thumbnailPath,
      ),

      price:
      map['price'] as int,

      discountPrice:
      map['discount_price'] as int?,

      discountPercent:
      map['discount_percent'] as int,

      rating:
      (map['rating'] as num)
          .toDouble(),

      reviewCount:
      map['review_count'] as int,

      isAvailable:
      map['is_available'] as bool,

      isFeatured:
      map['is_featured'] as bool,

      createdAt:
      DateTime.parse(
        map['created_at'] as String,
      ),

      soldCount:
      map['sold_count'] as int,

      isNew:
      map['is_new'] as bool,

      brandName:
      brandData?['name'] as String?,

      brandLogo:
      brandData?['logo_url'] != null
          ? _supabase.storage
          .from('assets')
          .getPublicUrl(
        brandData!['logo_url']
        as String,
      )
          : null,
    );
  }

  CartItemEntity _mapToEntity(
      Map<String, dynamic> map,
      ) {
    final productData =
    map['products']
    as Map<String, dynamic>;

    return CartItemEntity(
      id:
      map['id'] as String,

      userId:
      map['user_id'] as String,

      productId:
      map['product_id'] as String,

      quantity:
      map['quantity'] as int,

      createdAt:
      DateTime.parse(
        map['created_at'] as String,
      ),

      updatedAt:
      DateTime.parse(
        map['updated_at'] as String,
      ),

      product:
      _mapProduct(productData),
    );
  }

  @override
  Future<List<CartItemEntity>>
  getCartItems(
      String userId,
      ) async {
    final result =
    await _remoteDataSource
        .getCartItems(userId);

    return result
        .map(_mapToEntity)
        .toList();
  }

  @override
  Future<CartItemEntity>
  addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    final result =
    await _remoteDataSource
        .addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );

    return _mapToEntity(result);
  }

  @override
  Future<CartItemEntity>
  updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final result =
    await _remoteDataSource
        .updateQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    return _mapToEntity(result);
  }

  @override
  Future<void> removeFromCart(
      String cartItemId,
      ) async {
    await _remoteDataSource
        .removeFromCart(cartItemId);
  }

  @override
  Future<void> clearCart(
      String userId,
      ) async {
    await _remoteDataSource
        .clearCart(userId);
  }
}