import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_horizontal_list.dart';

class PopularProductsSection extends StatelessWidget {
  const PopularProductsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      getIt<ProductProvider>()
        ..loadPopularProducts(),
      child: const _PopularProductsContent(),
    );
  }
}

class _PopularProductsContent
    extends StatelessWidget {
  const _PopularProductsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // ==========================================
        // Loading
        // ==========================================

        if (provider.isLoading) {
          return SizedBox(
            height: 300.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ==========================================
        // Error
        // ==========================================

        if (provider.error != null) {
          return SizedBox(
            height: 300.h,
            child: Center(
              child: Text(
                provider.error!,
              ),
            ),
          );
        }

        // ==========================================
        // Empty
        // ==========================================

        if (provider.products.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: Text(
                'محصول پرفروشی وجود ندارد',
              ),
            ),
          );
        }

        // ==========================================
        // Products
        // ==========================================

        return ProductHorizontalList(
          products: provider.products,

          onProductTap: (product) {
            context.pushNamed(
              'product-details',
              extra: product,
            );
          },

          onFavoriteTap: (product) {
            debugPrint(
              'Favorite: ${product.id}',
            );
          },
        );
      },
    );
  }
}