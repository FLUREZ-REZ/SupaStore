import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class ProductTitleSection extends StatelessWidget {
  const ProductTitleSection({
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
          /// وضعیت موجودی
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: product.isAvailable
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              product.isAvailable ? 'موجود' : 'ناموجود',
              style: TextStyle(
                color: product.isAvailable
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          /// عنوان محصول
          Text(
            product.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),

          SizedBox(height: 14.h),

          /// برند
          if (product.brandName != null &&
              product.brandName!.isNotEmpty)
            Row(
              children: [
                if (product.brandLogo != null &&
                    product.brandLogo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),

                    child: CachedNetworkImage(
                      imageUrl: product.brandLogo!,
                      width: 28.w,
                      height: 28.w,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => SizedBox(
                        width: 28.w,
                        height: 28.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.store_outlined,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.store_outlined,
                    size: 22,
                    color: Colors.grey,
                  ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Text(
                    'برند: ${product.brandName}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 14.h),

          /// شناسه محصول
          Row(
            children: [
              const Icon(
                Icons.qr_code,
                size: 18,
                color: Colors.grey,
              ),

              SizedBox(width: 6.w),

              Expanded(
                child: Text(
                  product.slug,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
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