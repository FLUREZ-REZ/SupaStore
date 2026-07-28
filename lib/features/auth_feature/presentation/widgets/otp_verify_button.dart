import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';

class OtpVerifyButton extends StatelessWidget {
  const OtpVerifyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<OtpProvider, ({bool loading, bool isComplete})>(
      selector: (_, provider) => (
      loading: provider.isLoading,
      isComplete: provider.isOtpComplete,
      ),
      builder: (context, state, child) {
        final provider = context.read<OtpProvider>();

        return SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: state.loading || !state.isComplete
                ? null
                : () async {
              FocusScope.of(context).unfocus();
              await provider.verifyCode();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: state.loading
                  ? SizedBox(
                key: const ValueKey('loading'),
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'تأیید',
                key: const ValueKey('text'),
                style: AppTextStyles.button.copyWith(
                  color: state.isComplete
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}