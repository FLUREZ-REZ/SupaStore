import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/flash_sale_product_model.dart';

abstract class FlashSaleRemoteDataSource {
  Future<List<FlashSaleProductModel>>
  getActiveFlashSaleProducts({
    int page = 0,
    int limit = 20,
  });
}

class FlashSaleRemoteDataSourceImpl
    implements FlashSaleRemoteDataSource {
  final SupabaseClient supabase;

  const FlashSaleRemoteDataSourceImpl({
    required this.supabase,
  });

  @override
  Future<List<FlashSaleProductModel>>
  getActiveFlashSaleProducts({
    int page = 0,
    int limit = 20,
  }) async {

    // ============================================================
    // PAGINATION
    // ============================================================

    final from = page * limit;

    final to = from + limit - 1;


    // ============================================================
    // CURRENT TIME
    // ============================================================

    final now =
    DateTime.now().toUtc().toIso8601String();


    // ============================================================
    // SUPABASE QUERY
    // ============================================================

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

    // ========================================================
    // ONLY ACTIVE FLASH SALES
    // ========================================================

        .eq(
      'is_active',
      true,
    )

    // ========================================================
    // FLASH SALE HAS STARTED
    // ========================================================

        .lte(
      'start_at',
      now,
    )

    // ========================================================
    // FLASH SALE HAS NOT EXPIRED
    // ========================================================

        .gte(
      'end_at',
      now,
    )

    // ========================================================
    // ORDER
    // ========================================================

        .order(
      'sort_order',
      ascending: true,
    )

    // ========================================================
    // PAGINATION
    // ========================================================

        .range(
      from,
      to,
    );


    // ============================================================
    // CONVERT RESPONSE TO MODEL
    // ============================================================

    return (response as List)
        .map(
          (item) =>
          FlashSaleProductModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }
}