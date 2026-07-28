import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';



class OtpResendButton extends StatelessWidget {
  const OtpResendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<OtpProvider, ({bool canResend, bool loading})>(
      selector: (_, provider) => (
      canResend: provider.canResend,
      loading: provider.isLoading,
      ),
      builder: (context, state, child) {
        return TextButton(
          onPressed: state.canResend && !state.loading
              ? () => context.read<OtpProvider>().resendCode()
              : null,
          child: Text(
            state.canResend
                ? 'ارسال مجدد کد'
                : 'کد را دریافت نکردید؟',
            style: AppTextStyles.body.copyWith(
              color: state.canResend
                  ? AppColors.otp_send_code
                  : AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}