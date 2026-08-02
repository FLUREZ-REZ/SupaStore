import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

class OtpHeader extends StatelessWidget {
  final String phoneNumber;

  const OtpHeader({
    super.key,
    required this.phoneNumber,
  });

  String maskPhoneNumber(String phone) {
    phone = phone.toEnglishDigit();
    phone = phone.replaceAll(' ', '');

    if (phone.length < 10) return phone;

    return '${phone.substring(0, 4)}*******${phone.substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),

        Text(
          'کد تایید را وارد نمایید',
          style: AppTextStyles.otp_title.copyWith(
            color: AppColors.otp_title,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'کد تایید به شماره زیر ارسال شد',
            textAlign: TextAlign.center,
            style: AppTextStyles.otp_sent_code.copyWith(
              color: AppColors.otp_send_code,
              height: 1.6,
            ),
          ),
        ),

        SizedBox(height: 18.h),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 12.h,
          ),

          decoration: BoxDecoration(
            color: AppColors.otp_phone_background,
            borderRadius: BorderRadius.circular(16.r),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 18.sp,
                color: AppColors.white,
              ),

              SizedBox(width: 10.w),

              Text(
                maskPhoneNumber(phoneNumber).toPersianDigit(),

                style: AppTextStyles.otp_phone_number.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}