import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 0,
    int limit = 10,
  }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

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
        .ilike(
      'title',
      '%$trimmedQuery%',
    )
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
}