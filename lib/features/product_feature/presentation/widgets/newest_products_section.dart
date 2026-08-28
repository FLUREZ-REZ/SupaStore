import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/horizontal_product_card.dart';

class NewestProductsSection extends StatelessWidget {
  const NewestProductsSection({
    super.key,
    required this.onProductTap,
  });

  final void Function(ProductEntity product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        // ============================================================
        // LOADING
        // ============================================================

        if (provider.isLoading && provider.products.isEmpty) {
          return SizedBox(
            height: 320.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ============================================================
        // EMPTY
        // ============================================================

        if (provider.products.isEmpty) {
          return const SizedBox.shrink();
        }

        // ============================================================
        // PRODUCTS
        // ============================================================

        return SizedBox(
          height: 320.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),

            physics: const BouncingScrollPhysics(),

            itemCount: provider.products.length,

            separatorBuilder: (context, index) {
              return SizedBox(
                width: 12.w,
              );
            },

            itemBuilder: (context, index) {
              final product = provider.products[index];

              return SizedBox(
                width: 190.w,
                child: HorizontalProductCard(
                  product: product,
                  onTap: () {
                    onProductTap(product);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}