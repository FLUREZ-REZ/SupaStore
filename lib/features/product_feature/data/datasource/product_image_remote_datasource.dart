import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_image_model.dart';

class ProductImageRemoteDataSource {
  ProductImageRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductImageModel>> getProductImages(
      String productId,
      ) async {
    final response = await _client
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order(
      'sort_order',
      ascending: true,
    );

    return response
        .map<ProductImageModel>(
          (json) => ProductImageModel.fromMap(json),
    )
        .toList();
  }
}