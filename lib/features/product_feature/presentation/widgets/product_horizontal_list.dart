import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';
import 'horizontal_product_card.dart';


class ProductHorizontalList extends StatelessWidget {

  const ProductHorizontalList({
    super.key,
    required this.products,
    this.onProductTap,
    this.onFavoriteTap,
  });


  final List<ProductEntity> products;


  final Function(ProductEntity product)? onProductTap;


  final Function(ProductEntity product)? onFavoriteTap;



  @override
  Widget build(BuildContext context) {


    if (products.isEmpty) {

      return SizedBox(
        height: 270.h,
        child: const Center(
          child: Text(
            "محصولی موجود نیست",
          ),
        ),
      );

    }



    return SizedBox(

      height: 270.h,


      child: ListView.builder(

        scrollDirection: Axis.horizontal,


        physics:
        const BouncingScrollPhysics(),


        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),


        itemCount: products.length,


        itemBuilder: (context, index) {


          final product =
          products[index];



          return Padding(

            padding: EdgeInsets.only(
              right: 12.w,
            ),


            child: SizedBox(

              width: 170.w,


              child: HorizontalProductCard(

                product: product,


                onTap: () {

                  onProductTap?.call(product);

                },

              ),

            ),

          );

        },

      ),

    );

  }

}