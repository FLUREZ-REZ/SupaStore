
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive breakpoints
        final bool isDesktop = width >= 900;
        final bool isTablet = width >= 600 && width < 900;

        // Responsive dimensions
        final double cardHeight = isDesktop
            ? 390
            : isTablet
            ? 365
            : 340;

        final double imagePadding = isDesktop
            ? 12
            : isTablet
            ? 10
            : 8;

        final double imageRadius = isDesktop ? 14 : 12;

        final double titleFontSize = isDesktop
            ? 14
            : isTablet
            ? 13
            : 12;

        final double priceFontSize = isDesktop
            ? 15
            : isTablet
            ? 14
            : 13;

        final double ratingFontSize = isDesktop ? 13 : 12;

        final double horizontalPadding = isDesktop ? 12 : 9;

        return SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================
                    // PRODUCT IMAGE
                    // =========================================

                    Padding(
                      padding: EdgeInsets.all(imagePadding),
                      child: AspectRatio(
                        aspectRatio: 1.05,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(imageRadius),
                                child: CachedNetworkImage(
                                  imageUrl: product.thumbnail,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) {
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
                                  errorWidget: (context, url, error) {
                                    return const Center(
                                      child: Icon(
                                        Iconsax.image_copy,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // FAVORITE BUTTON

                            Positioned(
                              top: 6,
                              right: 6,
                              child: _buildFavoriteButton(),
                            ),

                            // DISCOUNT BADGE

                            if (product.hasDiscount)
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                    BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    '${product.discountPercent}٪',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 12 : 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // =========================================
                    // PRODUCT INFORMATION
                    // =========================================

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          2,
                          horizontalPadding,
                          10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PRODUCT TITLE

                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.productCard.copyWith(
                                fontSize: titleFontSize,
                              ),
                            ),

                            const SizedBox(height: 7),

                            // RATING

                            Row(
                              children: [
                                Icon(
                                  Iconsax.star_copy,
                                  size: isDesktop ? 16 : 14,
                                  color: Colors.amber,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: AppTextStyles.auth_textfield.copyWith(
                                    fontSize: ratingFontSize,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                Flexible(
                                  child: Text(
                                    '(${product.reviewCount})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.review_text.copyWith(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // OLD PRICE

                            if (product.hasDiscount) ...[
                              Text(
                                PriceFormatter.format(product.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.product_prize.copyWith(
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 3),
                            ],

                            // FINAL PRICE

                            Text(
                              PriceFormatter.format(product.finalPrice),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.product_prize.copyWith(
                                fontSize: priceFontSize,
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
          ),
        );
      },
    );
  }

  // =========================================
  // FAVORITE BUTTON
  // =========================================

  Widget _buildFavoriteButton() {
    return Consumer<FavoriteProvider>(
      builder: (
          context,
          favoriteProvider,
          child,
          ) {
        final isFavorite = favoriteProvider.isFavorite(
          product.id,
        );

        final isLoading = favoriteProvider.isProductLoading(
          product.id,
        );

        return Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isLoading
                ? null
                : () async {
              final user = Supabase.instance.client.auth.currentUser;

              if (user == null) {
                return;
              }

              await favoriteProvider.toggleFavorite(
                userId: user.id,
                productId: product.id,
              );

              onFavorite?.call();
            },
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 19,
                color: Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
