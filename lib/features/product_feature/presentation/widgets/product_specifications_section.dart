import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_specification_entity.dart';

class ProductSpecificationsSection extends StatelessWidget {
  const ProductSpecificationsSection({
    super.key,
    required this.specifications,
  });

  final List<ProductSpecificationEntity> specifications;

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.h),
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "مشخصات فنی",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 18.h),

          ...List.generate(
            specifications.length,
                (index) {
              final item = specifications[index];

              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 14.h,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(
                      width: 120.w,
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}