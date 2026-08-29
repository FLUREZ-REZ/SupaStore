import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // =========================================================
  // ALL PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq('is_available', true)
        .order(
      'created_at',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  // =========================================================
  // FEATURED PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getFeaturedProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq('is_available', true)
        .eq('is_featured', true)
        .order(
      'created_at',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  // =========================================================
  // NEWEST PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getNewestProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq('is_available', true)
        .order(
      'created_at',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  // =========================================================
  // DISCOUNT PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getDiscountProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq('is_available', true)
        .gt(
      'discount_percent',
      0,
    )
        .order(
      'discount_percent',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  // =========================================================
  // PRODUCTS BY CATEGORY
  // =========================================================

  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
    String? excludeProductId,
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    var query = _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq(
      'category_id',
      categoryId,
    )
        .eq(
      'is_available',
      true,
    );

    if (excludeProductId != null) {
      query = query.neq(
        'id',
        excludeProductId,
      );
    }

    final response = await query
        .order(
      'created_at',
      ascending: false,
    )
        .range(
      from,
      to,
    );

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

  // =========================================================
  // RELATED PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getRelatedProducts({
    required String categoryId,
    required String productId,
    int limit = 10,
  }) async {
    return await getProductsByCategory(
      categoryId: categoryId,
      excludeProductId: productId,
      page: 0,
      limit: limit,
    );
  }

  // =========================================================
  // PRODUCT BY ID
  // =========================================================

  Future<ProductModel> getProductById(
      String productId,
      ) async {
    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq(
      'id',
      productId,
    )
        .single();

    return ProductModel.fromMap(
      response,
    );
  }

  // =========================================================
  // POPULAR PRODUCTS
  // =========================================================

  Future<List<ProductModel>> getPopularProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _client
        .from('products')
        .select('''
          *,
          brands(
            name,
            logo_url
          )
        ''')
        .eq(
      'is_available',
      true,
    )
        .order(
      'sold_count',
      ascending: false,
    )
        .range(
      from,
      to,
    );

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }
}