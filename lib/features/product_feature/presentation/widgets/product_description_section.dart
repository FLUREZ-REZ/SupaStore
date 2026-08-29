import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class ProductDescriptionSection extends StatefulWidget {
  const ProductDescriptionSection({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  State<ProductDescriptionSection> createState() =>
      _ProductDescriptionSectionState();
}

class _ProductDescriptionSectionState
    extends State<ProductDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.product.description.isEmpty
        ? 'توضیحاتی برای این محصول ثبت نشده است.'
        : widget.product.description;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================================================
            // HEADER
            // =================================================

            Row(
              children: [

                Icon(
                  Icons.description_outlined,
                  size: 21.sp,
                  color: Colors.black87,
                ),

                SizedBox(width: 8.w),

                Text(
                  'توضیحات محصول',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Divider(
              height: 1.h,
              color: Colors.grey.shade200,
            ),

            SizedBox(height: 14.h),

            // =================================================
            // DESCRIPTION
            // =================================================

            AnimatedCrossFade(
              firstChild: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),

              secondChild: Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.9,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),

              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,

              duration: const Duration(
                milliseconds: 250,
              ),
            ),

            SizedBox(height: 10.h),

            // =================================================
            // SHOW MORE / LESS
            // =================================================

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },

              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 6.h,
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      _isExpanded
                          ? 'بستن توضیحات'
                          : 'مشاهده بیشتر',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),

                    SizedBox(width: 5.w),

                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}