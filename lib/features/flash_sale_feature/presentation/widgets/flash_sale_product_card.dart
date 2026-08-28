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

class FlashSaleProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final product = item.product;

    final discountPrice = item.discountPrice;

    final originalPrice = item.originalPrice;

    final discountPercent = item.discountPercent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18.r),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            Stack(
              children: [
                Hero(
                  tag: product.id,

                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(
                      top: Radius.circular(18.r),
                    ),

                    child: AspectRatio(
                      aspectRatio: 1,

                      child: CachedNetworkImage(
                        imageUrl:
                        product.thumbnail,

                        fit: BoxFit.cover,

                        placeholder:
                            (_, __) =>
                        const Center(
                          child:
                          CircularProgressIndicator(),
                        ),

                        errorWidget:
                            (_, __, ___) =>
                        const Icon(
                          Icons
                              .image_not_supported,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // FAVORITE
                // ==================================================

                Positioned(
                  top: 8,
                  right: 8,

                  child:
                  Consumer<FavoriteProvider>(
                    builder: (
                        context,
                        favoriteProvider,
                        child,
                        ) {
                      final isFavorite =
                      favoriteProvider
                          .isFavorite(
                        product.id,
                      );

                      final isLoading =
                      favoriteProvider
                          .isProductLoading(
                        product.id,
                      );

                      return Material(
                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          50,
                        ),

                        child: InkWell(
                          borderRadius:
                          BorderRadius.circular(
                            50,
                          ),

                          onTap: isLoading
                              ? null
                              : () async {
                            final user =
                                Supabase
                                    .instance
                                    .client
                                    .auth
                                    .currentUser;

                            if (user ==
                                null) {
                              return;
                            }

                            await favoriteProvider
                                .toggleFavorite(
                              userId:
                              user.id,
                              productId:
                              product.id,
                            );

                            onFavorite
                                ?.call();
                          },

                          child: Padding(
                            padding:
                            EdgeInsets.all(
                              6.w,
                            ),

                            child: isLoading
                                ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,

                              child:
                              const CircularProgressIndicator(
                                strokeWidth:
                                2,
                              ),
                            )
                                : Icon(
                              isFavorite
                                  ? Icons
                                  .favorite
                                  : Icons
                                  .favorite_border,

                              size: 20.sp,

                              color:
                              Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ==================================================
                // FLASH SALE DISCOUNT
                // ==================================================

                Positioned(
                  left: 8,
                  bottom: 8,

                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors.red,

                      borderRadius:
                      BorderRadius.circular(
                        8.r,
                      ),
                    ),

                    child: Text(
                      '$discountPercent٪',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ======================================================
            // INFORMATION
            // ======================================================

            Expanded(
              child: Padding(
                padding:
                EdgeInsets.all(10.w),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      product.title,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      AppTextStyles.productCard,
                    ),

                    SizedBox(
                      height: 8.h,
                    ),

                    // ==================================================
                    // RATING
                    // ==================================================

                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16.sp,
                          color: Colors.amber,
                        ),

                        SizedBox(
                          width: 4.w,
                        ),

                        Text(
                          product.rating
                              .toStringAsFixed(
                            1,
                          ),

                          style:
                          AppTextStyles
                              .auth_textfield,
                        ),

                        const Spacer(),

                        Text(
                          '(${product.reviewCount})',

                          style:
                          AppTextStyles
                              .review_text
                              .copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ==================================================
                    // ORIGINAL PRICE
                    // ==================================================

                    Text(
                      PriceFormatter.format(
                        originalPrice,
                      ),

                      style: AppTextStyles
                          .product_prize
                          .copyWith(
                        decoration:
                        TextDecoration
                            .lineThrough,

                        color:
                        Colors.grey,
                      ),
                    ),

                    SizedBox(
                      height: 4.h,
                    ),

                    // ==================================================
                    // FLASH SALE PRICE
                    // ==================================================

                    Text(
                      PriceFormatter.format(
                        discountPrice,
                      ),

                      style: AppTextStyles
                          .product_prize
                          .copyWith(
                        color:
                        AppColors.price,

                        fontWeight:
                        FontWeight.bold,
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