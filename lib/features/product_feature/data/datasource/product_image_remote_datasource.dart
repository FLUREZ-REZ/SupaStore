import 'package:flutter/foundation.dart';
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
    debugPrint('======================================');
    debugPrint('🔍 Loading images for product: $productId');

    final response = await _client
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order(
      'sort_order',
      ascending: true,
    );

    debugPrint(
      '📦 Raw product_images count: ${response.length}',
    );

    for (final image in response) {
      debugPrint(
        '🖼 product_id: ${image['product_id']}',
      );

      debugPrint(
        '🔗 image_url: ${image['image_url']}',
      );

      debugPrint(
        '🔢 sort_order: ${image['sort_order']}',
      );
    }

    debugPrint('======================================');

    return response
        .map<ProductImageModel>(
          (json) => ProductImageModel.fromMap(json),
    )
        .toList();
  }
}