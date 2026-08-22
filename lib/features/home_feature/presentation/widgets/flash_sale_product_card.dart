import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/constants/price_formatter.dart';

import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';

class FlashSaleProductCard extends StatelessWidget {
  const FlashSaleProductCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final FlashSaleProductEntity item;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    final originalPrice = item.originalPrice;
    final discountPrice = item.discountPrice;
    final discountPercent = item.discountPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165.w,

        // در RTL فاصله از سمت راست
        margin: EdgeInsets.only(
          right: 8.w,
        ),

        padding: EdgeInsets.all(8.w),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────
            // IMAGE
            // ─────────────────────────────────

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.contain,

                        memCacheWidth: 500,
                        maxWidthDiskCache: 600,

                        placeholder: (
                            context,
                            url,
                            ) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },

                        errorWidget: (
                            context,
                            url,
                            error,
                            ) {
                          return Icon(
                            Icons.image_not_supported_outlined,
                            size: 32.sp,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),

                  // ─────────────────────────────
                  // DISCOUNT
                  // ─────────────────────────────

                  if (discountPercent > 0)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${PriceFormatter.number(discountPercent)}٪',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // ─────────────────────────────────
            // TITLE
            // ─────────────────────────────────

            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),

            SizedBox(height: 6.h),

            // ─────────────────────────────────
            // ORIGINAL PRICE
            // ─────────────────────────────────

            if (discountPercent > 0)
              Text(
                PriceFormatter.format(
                  originalPrice,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),

            SizedBox(height: 3.h),

            // ─────────────────────────────────
            // FINAL PRICE
            // ─────────────────────────────────

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    PriceFormatter.number(
                      discountPrice,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                Text(
                  'تومان',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}