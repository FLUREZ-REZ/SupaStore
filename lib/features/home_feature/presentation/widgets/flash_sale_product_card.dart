
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';

class FlashSaleProductCard extends StatefulWidget {
  const FlashSaleProductCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final FlashSaleProductEntity item;
  final VoidCallback? onTap;

  @override
  State<FlashSaleProductCard> createState() =>
      _FlashSaleProductCardState();
}

class _FlashSaleProductCardState extends State<FlashSaleProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final product = item.product;

    final originalPrice = item.originalPrice;
    final discountPrice = item.discountPrice;
    final discountPercent = item.discountPercent;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 165.w,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
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

                        placeholder: (context, url) {
                          return _FlashSaleImageShimmer(
                            controller: _shimmerController,
                          );
                        },

                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 32.sp,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Discount badge
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

            // Product title
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

            // Original price
            if (discountPercent > 0)
              Text(
                PriceFormatter.format(originalPrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),

            SizedBox(height: 3.h),

            // Final price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    PriceFormatter.number(discountPrice),
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

// --------------------------------------------------
// Image Shimmer
// --------------------------------------------------

class _FlashSaleImageShimmer extends StatelessWidget {
  const _FlashSaleImageShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade200;
    final highlightColor = Colors.grey.shade50;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slide = controller.value * 2 - 1;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: baseColor,
          ),
        );
      },
    );
  }
}
