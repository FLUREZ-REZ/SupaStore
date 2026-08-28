import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  final VoidCallback? onTap;

  final VoidCallback? onFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // =====================================================
              // IMAGE
              // =====================================================

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
                          imageUrl: product.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) {
                            return const Center(
                              child:
                              CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (_, __, ___) {
                            return const Icon(
                              Icons.image_not_supported,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // FAVORITE
                  // =================================================

                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Consumer<FavoriteProvider>(
                      builder: (
                          context,
                          favoriteProvider,
                          child,
                          ) {
                        final isFavorite =
                        favoriteProvider.isFavorite(
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
                          BorderRadius.circular(50),
                          child: InkWell(
                            borderRadius:
                            BorderRadius.circular(50),
                            onTap: isLoading
                                ? null
                                : () async {
                              final user =
                                  Supabase
                                      .instance
                                      .client
                                      .auth
                                      .currentUser;

                              if (user == null) {
                                return;
                              }

                              await favoriteProvider
                                  .toggleFavorite(
                                userId: user.id,
                                productId:
                                product.id,
                              );

                              onFavorite?.call();
                            },
                            child: Padding(
                              padding:
                              EdgeInsets.all(6.w),
                              child: isLoading
                                  ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons
                                    .favorite_border,
                                size: 20.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // =================================================
                  // DISCOUNT
                  // =================================================

                  if (product.hasDiscount)
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                          BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${product.discountPercent}٪',
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

              // =====================================================
              // INFORMATION
              // =====================================================

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10.w,
                    right: 10.w,
                    top: 8.h,
                    bottom: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // TITLE
                      // =============================================

                      SizedBox(
                        height: 38.h,
                        width: double.infinity,
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          AppTextStyles.productCard,
                        ),
                      ),

                      SizedBox(
                        height: 8.h,
                      ),

                      // =============================================
                      // RATING
                      // =============================================

                      SizedBox(
                        height: 22.h,
                        width: double.infinity,
                        child: Row(
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
                                  .toStringAsFixed(1),
                              style: AppTextStyles
                                  .auth_textfield,
                            ),

                            const Spacer(),

                            Text(
                              '(${product.reviewCount})',
                              style: AppTextStyles
                                  .review_text
                                  .copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // =============================================
                      // PRICE CONTAINER
                      // =============================================

                      SizedBox(
                        height: 50.h,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // =========================================
                            // OLD PRICE
                            // =========================================

                            SizedBox(
                              height: 21.h,
                              width: double.infinity,
                              child: product.hasDiscount
                                  ? Align(
                                alignment:
                                Alignment.centerLeft,
                                child: Text(
                                  PriceFormatter
                                      .format(
                                    product.price,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
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
                              )
                                  : const SizedBox(),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            // =========================================
                            // FINAL PRICE
                            // =========================================

                            SizedBox(
                              height: 25.h,
                              width: double.infinity,
                              child: Align(
                                alignment:
                                Alignment.centerLeft,
                                child: Text(
                                  PriceFormatter.format(
                                    product.finalPrice,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: AppTextStyles
                                      .product_prize
                                      .copyWith(
                                    color:
                                    AppColors.price,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}