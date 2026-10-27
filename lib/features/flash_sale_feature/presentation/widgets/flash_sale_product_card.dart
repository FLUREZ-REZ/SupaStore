
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';

class FlashSaleProductCard extends StatefulWidget {
  const FlashSaleProductCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
  });

  final FlashSaleProductEntity item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  State<FlashSaleProductCard> createState() =>
      _FlashSaleProductCardState();
}

class _FlashSaleProductCardState extends State<FlashSaleProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  bool _imageLoaded = false;
  bool _imageFailed = false;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant FlashSaleProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.product.thumbnail !=
        widget.item.product.thumbnail) {
      _imageLoaded = false;
      _imageFailed = false;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;
    final discountPrice = widget.item.discountPrice;
    final originalPrice = widget.item.originalPrice;
    final discountPercent = widget.item.discountPercent;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // IMAGE
            // ------------------------------------------------------
            Stack(
              children: [
                Hero(
                  tag: product.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18.r),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Shimmer behind the image.
                          if (!_imageLoaded && !_imageFailed)
                            _ProductShimmer(
                              controller: _shimmerController,
                            ),

                          CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.cover,
                            memCacheWidth: 500,
                            maxWidthDiskCache: 600,
                            fadeInDuration:
                            const Duration(milliseconds: 200),
                            placeholder: (_, __) =>
                                _ProductShimmer(
                                  controller: _shimmerController,
                                ),
                            imageBuilder: (context, imageProvider) {
                              if (!_imageLoaded) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted || _imageLoaded) return;

                                  setState(() {
                                    _imageLoaded = true;
                                    _imageFailed = false;
                                  });
                                });
                              }

                              return Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              );
                            },
                            errorWidget: (_, __, ___) {
                              if (!_imageFailed) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted || _imageFailed) return;

                                  setState(() {
                                    _imageFailed = true;
                                    _imageLoaded = false;
                                  });
                                });
                              }

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
                        ],
                      ),
                    ),
                  ),
                ),

                // --------------------------------------------------
                // FAVORITE
                // --------------------------------------------------
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoriteProvider>(
                    builder: (
                        context,
                        favoriteProvider,
                        child,
                        ) {
                      final isFavorite =
                      favoriteProvider.isFavorite(product.id);

                      final isLoading =
                      favoriteProvider.isProductLoading(product.id);

                      return Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isLoading
                              ? null
                              : () async {
                            final user = Supabase
                                .instance.client.auth.currentUser;

                            if (user == null) return;

                            await favoriteProvider.toggleFavorite(
                              userId: user.id,
                              productId: product.id,
                            );

                            widget.onFavorite?.call();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: isLoading
                                ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --------------------------------------------------
                // FLASH SALE DISCOUNT
                // --------------------------------------------------
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${PriceFormatter.number(discountPercent)}٪',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ------------------------------------------------------
            // INFORMATION
            // ------------------------------------------------------
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productCard,
                    ),

                    SizedBox(height: 8.h),

                    // RATING
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyles.auth_textfield,
                        ),
                        const Spacer(),
                        Text(
                          '(${product.reviewCount})',
                          style: AppTextStyles.review_text.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ORIGINAL PRICE
                    Text(
                      PriceFormatter.format(originalPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.product_prize.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // FLASH SALE PRICE
                    Text(
                      PriceFormatter.format(discountPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.product_prize.copyWith(
                        color: AppColors.price,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Product Shimmer
// --------------------------------------------------

class _ProductShimmer extends StatelessWidget {
  const _ProductShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(
      controller: controller,
      width: double.infinity,
      height: double.infinity,
      radius: 0,
    );
  }
}

// --------------------------------------------------
// Shimmer Box
// --------------------------------------------------

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    required this.width,
    required this.height,
    required this.radius,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade200;
    final highlightColor = Colors.grey.shade50;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slide = controller.value * 2 - 1;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ShaderMask(
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
              width: width,
              height: height,
              color: baseColor,
            ),
          ),
        );
      },
    );
  }
}
