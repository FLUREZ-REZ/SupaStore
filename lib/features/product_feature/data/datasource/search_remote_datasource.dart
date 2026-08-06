import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductModel>> searchProducts(
      String query,
      ) async {
    if (query.trim().isEmpty) {
      return [];
    }

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
      '%${query.trim()}%',
    )
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromMap(json),
    )
        .toList();
  }
}