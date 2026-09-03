import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';

class OtpPinField extends StatelessWidget {
  const OtpPinField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OtpProvider>();

    final defaultTheme = PinTheme(
      width: 48.w,
      height: 56.h,

      textStyle: AppTextStyles.otp_code_number.copyWith(
        color: Colors.black,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.18,
          ),
          width: 1,
        ),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(
        color: Colors.red,
        width: 1.5,
      ),
    );

    final submittedTheme = defaultTheme.copyDecorationWith(
      color: Colors.red.withValues(
        alpha: 0.06,
      ),
      border: Border.all(
        color: Colors.red,
        width: 1,
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

        cursor: Container(
          width: 2.w,
          height: 22.h,
          color: Colors.red,
        ),
      ),
    );
  }
}