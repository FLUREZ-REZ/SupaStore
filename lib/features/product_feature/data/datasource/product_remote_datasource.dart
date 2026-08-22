import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

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
        .gt('discount_percent', 0)
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

  Future<List<ProductModel>> getProductsByCategory({
    required String categoryId,
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
        .eq('category_id', categoryId)
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

  Future<ProductModel> getProductById(
      String productId,
      ) async {
    final response = await _client
        .from('products')
        .select('''
        *,
        brands (
          name,
          logo_url
        )
      ''')
        .eq('id', productId)
        .single();

    return ProductModel.fromMap(response);
  }


  // soldout feature poplure hast !

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
        .eq('is_available', true)
        .order(
      'sold_count',
      ascending: false,
    )
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }

}