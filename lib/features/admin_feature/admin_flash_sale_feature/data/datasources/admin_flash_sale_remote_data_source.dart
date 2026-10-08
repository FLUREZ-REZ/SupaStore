import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFlashSaleRemoteDataSource {
  AdminFlashSaleRemoteDataSource({
    SupabaseClient? client,
  }) : _client =
      client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _productSelect = '''
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
      name,
      logo_url
    )
  ''';

  Future<List<Map<String, dynamic>>>
  getFlashSales() async {
    final response = await _client
        .from('flash_sale_products')
        .select('''
          id,
          product_id,
          discount_price,
          start_at,
          end_at,
          is_active,
          sort_order,
          created_at,
          products (
            $_productSelect
          )
        ''')
        .order(
      'sort_order',
      ascending: true,
    )
        .order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }

  Future<Map<String, dynamic>>
  createFlashSale({
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response = await _client
        .from('flash_sale_products')
        .insert({
      'product_id': productId,
      'discount_price': discountPrice,
      'start_at': startAt
          .toUtc()
          .toIso8601String(),
      'end_at': endAt
          .toUtc()
          .toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
    })
        .select('''
          id,
          product_id,
          discount_price,
          start_at,
          end_at,
          is_active,
          sort_order,
          created_at,
          products (
            $_productSelect
          )
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<Map<String, dynamic>>
  updateFlashSale({
    required String id,
    required String productId,
    required int discountPrice,
    required DateTime startAt,
    required DateTime endAt,
    required bool isActive,
    required int sortOrder,
  }) async {
    final response = await _client
        .from('flash_sale_products')
        .update({
      'product_id': productId,
      'discount_price': discountPrice,
      'start_at': startAt
          .toUtc()
          .toIso8601String(),
      'end_at': endAt
          .toUtc()
          .toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
    })
        .eq('id', id)
        .select('''
          id,
          product_id,
          discount_price,
          start_at,
          end_at,
          is_active,
          sort_order,
          created_at,
          products (
            $_productSelect
          )
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<void> deleteFlashSale({
    required String id,
  }) async {
    await _client
        .from('flash_sale_products')
        .delete()
        .eq('id', id);
  }

  Future<Map<String, dynamic>>
  updateFlashSaleStatus({
    required String id,
    required bool isActive,
  }) async {
    final response = await _client
        .from('flash_sale_products')
        .update({
      'is_active': isActive,
    })
        .eq('id', id)
        .select('''
          id,
          product_id,
          discount_price,
          start_at,
          end_at,
          is_active,
          sort_order,
          created_at,
          products (
            $_productSelect
          )
        ''')
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  Future<List<Map<String, dynamic>>>
  searchProducts({
    String query = '',
    int limit = 30,
  }) async {
    var request = _client
        .from('products')
        .select('''
          id,
          title,
          thumbnail,
          price
        ''')
        .eq('is_available', true);

    final trimmedQuery = query.trim();

    if (trimmedQuery.isNotEmpty) {
      request = request.ilike(
        'title',
        '%$trimmedQuery%',
      );
    }

    final response = await request
        .order(
      'created_at',
      ascending: false,
    )
        .limit(limit);

    return (response as List)
        .map(
          (item) =>
      Map<String, dynamic>.from(item),
    )
        .toList();
  }
}