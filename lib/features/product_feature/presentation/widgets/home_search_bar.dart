import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 12.h,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pushNamed('search');
          },
          child: Container(
            height: 65.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 10.w),

                // Search Icon
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(width: 12.w),

                // Hint
                Expanded(
                  child: RichText(
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'جستجو در ',
                          style: AppTextStyles.auth_textfield.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: 'سوپااستور',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'roosta',
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 16.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}