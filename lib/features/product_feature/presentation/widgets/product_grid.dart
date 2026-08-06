import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        child: Text(
          'محصولی یافت نشد',
        ),
      );
    }


    return GridView.builder(

      padding: EdgeInsets.all(16.w),

      physics: const BouncingScrollPhysics(),

      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 2,

        crossAxisSpacing: 12.w,

        mainAxisSpacing: 12.h,

        // ارتفاع ثابت کارت محصول
        mainAxisExtent: 320.h,

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
    );
  }
}