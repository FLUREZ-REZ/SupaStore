import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class ProductRatingSection extends StatelessWidget {
  const ProductRatingSection({
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
            "امتیاز کاربران",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 26.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(width: 8.w),

              Text(
                "از 5",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          LinearProgressIndicator(
            value: product.rating / 5,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(20.r),
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(
              Colors.amber,
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 20.sp,
                color: Colors.grey,
              ),

              SizedBox(width: 8.w),

              Text(
                "${product.reviewCount} نظر ثبت شده",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}