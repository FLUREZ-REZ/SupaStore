import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';


class OtpPinField extends StatelessWidget {
  const OtpPinField({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OtpProvider>();

    final defaultTheme = PinTheme(
      width: 54.w,
      height: 60.h,
      textStyle: AppTextStyles.otp_code_number.copyWith(
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: AppColors.otp_code_background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.primary,
        width: 1.5,
      ),
    );

    final submittedTheme = defaultTheme.copyDecorationWith(
      color: AppColors.primary.withValues(alpha: .08),
      border: Border.all(
        color: AppColors.primary,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        controller: provider.otpController,

        length: 6,

        autofocus: true,

        keyboardType: TextInputType.number,

        defaultPinTheme: defaultTheme,

        focusedPinTheme: focusedTheme,

        submittedPinTheme: submittedTheme,

        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],

        autofillHints: const [
          AutofillHints.oneTimeCode,
        ],

        onChanged: provider.onOtpChanged,

        onCompleted: (value) async {
          await provider.verifyCode();
        },
      ),
    );
  }
}