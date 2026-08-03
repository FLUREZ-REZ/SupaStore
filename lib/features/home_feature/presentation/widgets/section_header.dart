import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';


class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showSeeAll = true,
  });

  final String title;

  final VoidCallback? onSeeAll;

  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (showSeeAll)
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: onSeeAll,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 4.h,
                ),
                child: Row(
                  children: [
                    Text(
                      'مشاهده همه',
                      style: AppTextStyles.otp_title.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(width: 2.w),

                    Icon(
                      Icons.chevron_left,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}