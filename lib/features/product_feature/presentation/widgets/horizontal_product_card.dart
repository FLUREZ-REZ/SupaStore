import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/price_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../favorite_feature/presentation/providers/favorite_provider.dart';

import '../../domain/entities/product_entity.dart';

class HorizontalProductCard extends StatelessWidget {
  const HorizontalProductCard({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 170.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 150.h,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) {
                        return const Center(
                          child: CircularProgressIndicator(),
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

                // ==================================================
                // FAVORITE BUTTON
                // ==================================================

                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Consumer<FavoriteProvider>(
                    builder: (
                        context,
                        favoriteProvider,
                        child,
                        ) {
                      final bool isFavorite =
                      favoriteProvider.isFavorite(
                        product.id,
                      );

                      final bool isLoading =
                      favoriteProvider.isProductLoading(
                        product.id,
                      );

                      return Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
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
                            padding: EdgeInsets.all(6.w),
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
                              size: 20.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ==================================================
            // PRODUCT INFORMATION
            // ==================================================

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    SizedBox(
                      height: 40.h,
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.productCard,
                      ),
                    ),

                    SizedBox(
                      height: 8.h,
                    ),

                    const Spacer(),

                    // ==================================================
                    // PRICE
                    // ==================================================

                    SizedBox(
                      height: 24.h,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          PriceFormatter.format(
                            product.finalPrice,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.product_prize.copyWith(
                            color: AppColors.price,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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