import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/flash_sale_product_model.dart';

abstract class FlashSaleRemoteDataSource {
  Future<List<FlashSaleProductModel>>
  getActiveFlashSaleProducts();
}

class FlashSaleRemoteDataSourceImpl
    implements FlashSaleRemoteDataSource {
  final SupabaseClient supabase;

  const FlashSaleRemoteDataSourceImpl({
    required this.supabase,
  });

  @override
  Future<List<FlashSaleProductModel>>
  getActiveFlashSaleProducts() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final response = await supabase
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
          )
        ''')
        .eq('is_active', true)
        .lte('start_at', now)
        .gte('end_at', now)
        .order(
      'sort_order',
      ascending: true,
    );

    return (response as List)
        .map(
          (item) => FlashSaleProductModel.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}