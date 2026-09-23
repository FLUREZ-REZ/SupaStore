import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32.w,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_outlined,
                    size: 48.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'فروشگاه موقتاً در دسترس نیست',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge,
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                SizedBox(height: 24.h),
                Text(
                  'لطفاً بعداً دوباره مراجعه کنید.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}