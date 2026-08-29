import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/theme/app_text_styles.dart';

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
      padding: EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        18.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          /// -------------------------------------------
          /// Availability
          /// -------------------------------------------

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: product.isAvailable
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius:
              BorderRadius.circular(30.r),
            ),
            child: Text(
              product.isAvailable
                  ? 'موجود'
                  : 'ناموجود',
              style: TextStyle(
                color: product.isAvailable
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),

          SizedBox(height: 14.h),

          /// -------------------------------------------
          /// Product Title
          /// -------------------------------------------

          Text(
            product.title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title_section,
          ),

          SizedBox(height: 14.h),

          /// -------------------------------------------
          /// Brand
          /// -------------------------------------------

          if (product.brandName != null &&
              product.brandName!.isNotEmpty)
            Row(
              children: [

                if (product.brandLogo != null &&
                    product.brandLogo!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(6.r),
                    child: CachedNetworkImage(
                      imageUrl: product.brandLogo!,
                      width: 30.w,
                      height: 30.w,
                      fit: BoxFit.contain,

                      memCacheWidth: 120,
                      memCacheHeight: 120,

                      placeholder: (_, __) {
                        return SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child:
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },

                      errorWidget: (
                          _,
                          __,
                          ___,
                          ) {
                        return Icon(
                          Icons.store_outlined,
                          size: 22.sp,
                          color: Colors.grey,
                        );
                      },
                    ),
                  )
                else
                  Icon(
                    Icons.store_outlined,
                    size: 22.sp,
                    color: Colors.grey,
                  ),

                SizedBox(width: 10.w),

                Expanded(
                  child: Text(
                    'برند: ${product.brandName}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 12.h),

          /// -------------------------------------------
          /// Slug
          /// -------------------------------------------

          Row(
            children: [

              Icon(
                Icons.qr_code,
                size: 18.sp,
                color: Colors.grey,
              ),

              SizedBox(width: 6.w),

              Expanded(
                child: Text(
                  product.slug,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
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