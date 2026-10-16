import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/product_entity.dart';

class ProductRatingSection extends StatelessWidget {
  const ProductRatingSection({
    super.key,
    required this.product,
    this.onTap,
  });

  final ProductEntity product;
  final VoidCallback? onTap;

  String _toPersianDigits(String value) {
    const englishDigits = '0123456789';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    return value.split('').map((char) {
      final index = englishDigits.indexOf(char);
      return index == -1 ? char : persianDigits[index];
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'امتیاز و نظرات کاربران',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Icon(
                    Iconsax.star_copy,
                    color: Colors.amber,
                    size: 25.sp,
                  ),

                  SizedBox(width: 6.w),

                  Text(
                    _toPersianDigits(
                      product.rating.toStringAsFixed(1),
                    ),
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(width: 6.w),

                  Text(
                    'از ۵',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Container(
                    width: 1.w,
                    height: 18.h,
                    color: Colors.grey.shade300,
                  ),

                  SizedBox(width: 14.w),

                  Text(
                    '${_toPersianDigits(product.reviewCount.toString())} نظر',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13.sp,
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15.sp,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مشاهده همه نظرات',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),

                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14.sp,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}