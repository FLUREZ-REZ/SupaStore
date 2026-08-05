import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            children: [

              Icon(
                Icons.description_outlined,
                size: 22.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                'توضیحات محصول',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          Divider(
            height: 1.h,
          ),

          SizedBox(height: 18.h),

          Text(
            product.description.isEmpty
                ? 'توضیحاتی برای این محصول ثبت نشده است.'
                : product.description,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.9,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}