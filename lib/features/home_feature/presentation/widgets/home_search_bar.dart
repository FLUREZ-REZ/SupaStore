import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 12.h,
      ),
      child: Material(

        borderRadius: BorderRadius.circular(18.r),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {
            // بعداً:
            // context.push('/search');
          },
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 24.sp,
                    color: Colors.grey.shade600,
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Text(
                      "جستوجو محصول",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  Container(
                    width: 1.w,
                    height: 24.h,
                    color: Colors.grey.shade300,
                  ),

                  SizedBox(width: 12.w),

                  Icon(
                    Icons.mic_none_rounded,
                    size: 24.sp,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}