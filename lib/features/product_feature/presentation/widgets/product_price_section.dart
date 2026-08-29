import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class ProductPriceSection extends StatelessWidget {
  const ProductPriceSection({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 18.h,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'قیمت محصول',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              if (product.hasDiscount)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${product.discountPercent}٪',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (product.hasDiscount)
                SizedBox(width: 10.w),

              Text(
                '${product.finalPrice}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              SizedBox(width: 5.w),

              Text(
                'تومان',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          if (product.hasDiscount) ...[
            SizedBox(height: 6.h),

            Row(
              children: [
                Text(
                  '${product.price} تومان',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                    decoration:
                    TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}