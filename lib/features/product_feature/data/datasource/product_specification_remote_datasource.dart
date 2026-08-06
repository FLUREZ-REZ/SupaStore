import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_specification_model.dart';

class ProductSpecificationRemoteDataSource {
  ProductSpecificationRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductSpecificationModel>> getProductSpecifications(
      String productId,
      ) async {
    final response = await _client
        .from('product_specifications')
        .select()
        .eq('product_id', productId)
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<ProductSpecificationModel>(
          (json) => ProductSpecificationModel.fromMap(json),
    )
        .toList();
  }
}