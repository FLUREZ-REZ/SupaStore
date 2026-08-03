import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/features/home_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/home_feature/presentation/widgets/product_card.dart';

class ProductHorizontalList extends StatelessWidget {
  const ProductHorizontalList({
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
      return SizedBox(
        height: 300.h,
        child: const Center(
          child: Text('محصولی وجود ندارد'),
        ),
      );
    }

    return SizedBox(
      height: 310.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),

        itemCount: products.length,

        separatorBuilder: (_, __) => SizedBox(width: 12.w),

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
    );
  }
}