import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/features/home_feature/presentation/widgets/product_card.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';
import 'package:supastore/features/product_feature/presentation/pages/product_details_page.dart';
import 'package:supastore/features/product_feature/presentation/widgets/CompactProductCard.dart';

class RelatedProductsSection extends StatelessWidget {
  const RelatedProductsSection({
    super.key,
    required this.products,
    this.onProductTap,
  });

  final List<ProductEntity> products;

  final void Function(ProductEntity product)? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.only(
          top: 18.h,
          bottom: 20.h,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================================================
            // HEADER
            // =====================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              child: Row(
                children: [

                  Text(
                    'محصولات مرتبط',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                ],
              ),
            ),

            SizedBox(height: 12.h),

            // =====================================================
            // PRODUCTS
            // =====================================================

            SizedBox(
              height: 340.h,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics:
                  const BouncingScrollPhysics(),

                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),

                  itemCount: products.length,

                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final product =
                    products[index];

                    return RepaintBoundary(
                      child: SizedBox(
                        width: 190.w,

                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 8.w,
                          ),

                          child: CompactProductCard(
                            product: product,
                            onTap: () {
                              onProductTap?.call(product);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}