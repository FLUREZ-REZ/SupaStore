import 'package:supabase_flutter/supabase_flutter.dart';

class CartRemoteDataSource {
  CartRemoteDataSource();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  /// دریافت Cart کاربر
  Future<List<Map<String, dynamic>>> getCartItems(
      String userId,
      ) async {
    final response = await _supabase
        .from('cart_items')
        .select('''
          id,
          user_id,
          product_id,
          quantity,
          created_at,
          updated_at,
          products (
            id,
            category_id,
            brand_id,
            title,
            slug,
            description,
            thumbnail,
            price,
            discount_price,
            discount_percent,
            rating,
            review_count,
            is_available,
            is_featured,
            created_at,
            sold_count,
            is_new,
            brands (
              id,
              name,
              logo_url
            )
          )
        ''')
        .eq(
      'user_id',
      userId,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }

  /// افزودن محصول به Cart
  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    final response = await _supabase
        .from('cart_items')
        .upsert(
      {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      },
      onConflict: 'user_id,product_id',
    )
        .select('''
          id,
          user_id,
          product_id,
          quantity,
          created_at,
          updated_at,
          products (
            id,
            category_id,
            brand_id,
            title,
            slug,
            description,
            thumbnail,
            price,
            discount_price,
            discount_percent,
            rating,
            review_count,
            is_available,
            is_featured,
            created_at,
            sold_count,
            is_new,
            brands (
              id,
              name,
              logo_url
            )
          )
        ''')
        .single();

    return response;
  }

  /// تغییر تعداد
  Future<Map<String, dynamic>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _supabase
        .from('cart_items')
        .update({
      'quantity': quantity,
      'updated_at':
      DateTime.now().toIso8601String(),
    })
        .eq(
      'id',
      cartItemId,
    )
        .select('''
          id,
          user_id,
          product_id,
          quantity,
          created_at,
          updated_at,
          products (
            id,
            category_id,
            brand_id,
            title,
            slug,
            description,
            thumbnail,
            price,
            discount_price,
            discount_percent,
            rating,
            review_count,
            is_available,
            is_featured,
            created_at,
            sold_count,
            is_new,
            brands (
              id,
              name,
              logo_url
            )
          )
        ''')
        .single();

    return response;
  }

  /// حذف محصول
  Future<void> removeFromCart(
      String cartItemId,
      ) async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq(
      'id',
      cartItemId,
    );
  }

  /// خالی کردن Cart
  Future<void> clearCart(
      String userId,
      ) async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq(
      'user_id',
      userId,
    );
  }
}