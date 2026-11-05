
import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/presentation/widgets/product_card.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onFavoriteTap,
  });

  final List<ProductEntity> products;

  final void Function(ProductEntity product)? onProductTap;

  final void Function(ProductEntity product)? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text('محصولی یافت نشد'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // =========================================
        // RESPONSIVE BREAKPOINTS
        // =========================================

        int crossAxisCount;

        if (width < 600) {
          crossAxisCount = 2;
        } else if (width < 800) {
          crossAxisCount = 3;
        } else if (width < 1100) {
          crossAxisCount = 4;
        } else if (width < 1500) {
          crossAxisCount = 5;
        } else {
          crossAxisCount = 6;
        }

        // =========================================
        // RESPONSIVE SPACING
        // =========================================

        final double spacing = width < 600 ? 10 : 16;

        final double horizontalPadding =
        width < 600 ? 12 : 20;

        // =========================================
        // RESPONSIVE CARD HEIGHT
        // =========================================

        final double cardHeight = width < 600
            ? 340
            : width < 800
            ? 355
            : width < 1100
            ? 370
            : 390;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1600,
            ),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),

              physics: const BouncingScrollPhysics(),

              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: cardHeight,
              ),

              itemCount: products.length,

              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  product: product,

                  onTap: () {
                    onProductTap?.call(product);
                  },

                  onFavorite: () {
                    onFavoriteTap?.call(product);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
