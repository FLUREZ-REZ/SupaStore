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

class CompactProductCard extends StatelessWidget {
  const CompactProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
  });

  final ProductEntity product;

  final VoidCallback? onTap;

  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 370.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =====================================================
              // IMAGE
              // =====================================================

              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      left: 8.w,
                      right: 8.w,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: AspectRatio(
                        aspectRatio: 1.05,
                        child: CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (
                              context,
                              url,
                              ) {
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorWidget: (
                              context,
                              url,
                              error,
                              ) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                              ),
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
                    top: 14.h,
                    right: 14.w,
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
                        favoriteProvider.isProductLoading(
                          product.id,
                        );

                        return Material(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(50.r),
                          child: InkWell(
                            borderRadius:
                            BorderRadius.circular(50.r),
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
                                productId: product.id,
                              );

                              onFavorite?.call();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(5.w),
                              child: isLoading
                                  ? SizedBox(
                                width: 18.sp,
                                height: 18.sp,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 19.sp,
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
                      left: 14.w,
                      bottom: 7.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                          BorderRadius.circular(7.r),
                        ),
                        child: Text(
                          '${product.discountPercent}٪',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // =====================================================
              // SCROLLABLE INFORMATION
              // =====================================================

              Expanded(
                child: SingleChildScrollView(
                  physics:
                  const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    9.w,
                    8.h,
                    9.w,
                    9.h,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // ===============================================
                      // TITLE
                      // ===============================================

                      Text(
                        product.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.productCard,
                      ),

                      SizedBox(height: 6.h),

                      // ===============================================
                      // RATING
                      // ===============================================

                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 15.sp,
                            color: Colors.amber,
                          ),

                          SizedBox(width: 3.w),

                          Text(
                            product.rating.toStringAsFixed(1),
                            style:
                            AppTextStyles.auth_textfield
                                .copyWith(
                              fontSize: 12.sp,
                            ),
                          ),

                          SizedBox(width: 4.w),

                          Text(
                            '(${product.reviewCount})',
                            style:
                            AppTextStyles.review_text
                                .copyWith(
                              color: Colors.grey,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // ===============================================
                      // OLD PRICE
                      // ===============================================

                      if (product.hasDiscount)
                        Text(
                          PriceFormatter.format(
                            product.price,
                          ),
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          AppTextStyles.product_prize
                              .copyWith(
                            fontSize: 11.sp,
                            decoration:
                            TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),

                      if (product.hasDiscount)
                        SizedBox(height: 3.h),

                      // ===============================================
                      // FINAL PRICE
                      // ===============================================

                      Text(
                        PriceFormatter.format(
                          product.finalPrice,
                        ),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        AppTextStyles.product_prize
                            .copyWith(
                          fontSize: 13.sp,
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
      ),
    );
  }
}