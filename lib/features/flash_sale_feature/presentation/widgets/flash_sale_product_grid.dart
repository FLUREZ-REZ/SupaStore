import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/flash_sale_feature/presentation/widgets/flash_sale_product_card.dart';

class FlashSaleProductGrid extends StatelessWidget {
  const FlashSaleProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onFavoriteTap,
  });

  final List<FlashSaleProductEntity> products;

  final Function(
      FlashSaleProductEntity product,
      )? onProductTap;

  final Function(
      FlashSaleProductEntity product,
      )? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // EMPTY
    // ============================================================

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'محصولی در شگفت‌انگیزها وجود ندارد',
        ),
      );
    }

    // ============================================================
    // GRID
    // ============================================================

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        12.h,
      ),

      physics:
      const AlwaysScrollableScrollPhysics(),

      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
        // ========================================================
        // COLUMNS
        // ========================================================

        crossAxisCount: 2,

        // ========================================================
        // HORIZONTAL SPACE
        // ========================================================

        crossAxisSpacing: 12.w,

        // ========================================================
        // VERTICAL SPACE
        // ========================================================

        mainAxisSpacing: 12.h,

        // ========================================================
        // CARD SIZE
        //
        // مقدار کمتر = کارت بلندتر
        //
        // برای FlashSaleProductCard
        // فضای بیشتری برای قیمت‌ها لازم داریم.
        // ========================================================

        childAspectRatio: 0.56,
      ),

      // ==========================================================
      // ITEMS
      // ==========================================================

      itemCount: products.length,

      // ==========================================================
      // ITEM BUILDER
      // ==========================================================

      itemBuilder: (
          context,
          index,
          ) {
        final item = products[index];

        return FlashSaleProductCard(
          item: item,

          // ======================================================
          // PRODUCT TAP
          // ======================================================

          onTap: () {
            onProductTap?.call(item);
          },

          // ======================================================
          // FAVORITE
          // ======================================================

          onFavorite: () {
            onFavoriteTap?.call(item);
          },
        );
      },
    );
  }
}