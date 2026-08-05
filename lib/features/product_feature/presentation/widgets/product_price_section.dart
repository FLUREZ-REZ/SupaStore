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
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 18.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "قیمت",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 18.h),

          if (product.hasDiscount) ...[
            Row(
              children: [

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "${product.discountPercent}٪",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                Text(
                  "${product.price}",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                "${product.finalPrice}",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              SizedBox(width: 6.w),

              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  "تومان",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}