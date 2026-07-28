import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';



class OtpTimer extends StatelessWidget {
  const OtpTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<OtpProvider, String>(
      selector: (_, provider) => provider.formattedTime,
      builder: (context, time, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),

          child: Text(
            time,
            key: ValueKey(time.toPersianDigit()),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.otp_timer_number,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
            ),
          ),
        );
      },
    );
  }
}