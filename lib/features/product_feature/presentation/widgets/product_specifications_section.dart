import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_specification_entity.dart';

class ProductSpecificationsSection extends StatefulWidget {
  const ProductSpecificationsSection({
    super.key,
    required this.specifications,
  });

  final List<ProductSpecificationEntity> specifications;

  @override
  State<ProductSpecificationsSection> createState() =>
      _ProductSpecificationsSectionState();
}

class _ProductSpecificationsSectionState
    extends State<ProductSpecificationsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final specifications = widget.specifications;

    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    // فقط دو مورد در حالت بسته
    final visibleSpecifications = _isExpanded
        ? specifications
        : specifications.take(2).toList();

    final hasMore = specifications.length > 2;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 12.h),
        color: Colors.white,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================================================
            // HEADER
            // =================================================

            Text(
              'مشخصات فنی',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            // =================================================
            // SPECIFICATIONS
            // =================================================

            ...List.generate(
              visibleSpecifications.length,
                  (index) {
                final item =
                visibleSpecifications[index];

                final isLast =
                    index ==
                        visibleSpecifications.length - 1;

                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 13.h,
                  ),

                  decoration: isLast
                      ? null
                      : BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                        Colors.grey.shade200,
                      ),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // =======================================
                      // TITLE
                      // =======================================

                      SizedBox(
                        width: 120.w,

                        child: Text(
                          item.title,

                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                            fontSize: 13.sp,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // =======================================
                      // VALUE
                      // =======================================

                      Expanded(
                        child: Text(
                          item.value,

                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // =================================================
            // SHOW MORE
            // =================================================

            if (hasMore) ...[
              SizedBox(height: 10.h),

              GestureDetector(
                behavior:
                HitTestBehavior.opaque,

                onTap: () {
                  setState(() {
                    _isExpanded =
                    !_isExpanded;
                  });
                },

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 7.h,
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      Text(
                        _isExpanded
                            ? 'بستن مشخصات'
                            : 'مشاهده همه مشخصات',

                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Colors.blue.shade700,
                        ),
                      ),

                      SizedBox(width: 5.w),

                      AnimatedRotation(
                        turns:
                        _isExpanded
                            ? 0.5
                            : 0,

                        duration:
                        const Duration(
                          milliseconds: 200,
                        ),

                        child: Icon(
                          Icons
                              .keyboard_arrow_down_rounded,
                          size: 19.sp,
                          color:
                          Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}