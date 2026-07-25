import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';


class OtpHeader extends StatelessWidget {
  final String phoneNumber;

  const OtpHeader({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),

        /// عنوان
        Text(
          'تأیید شماره موبایل',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        /// توضیح
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'کد تأیید ۶ رقمی به شماره زیر ارسال شده است.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
              height: 1.6,
            ),
          ),
        ),

        SizedBox(height: 18.h),

        /// شماره موبایل
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 12.h,
          ),

          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),

              SizedBox(width: 10.w),

              Text(
                phoneNumber,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}