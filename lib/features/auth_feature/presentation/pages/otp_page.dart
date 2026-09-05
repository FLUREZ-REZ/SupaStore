import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/auth_feature/data/services/auth_role_service.dart';
import 'package:supastore/features/auth_feature/presentation/providers/otp_provider.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/otp_header.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/otp_timer.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/otp_resend_button.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/otp_verify_button.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/tp_pin_field.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  OtpStatus? _lastStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OtpProvider>();

      provider.setPhone(widget.phoneNumber);
      provider.startTimer();
    });
  }

  void _handleStatus(OtpProvider provider) {
    if (_lastStatus == provider.status) return;

    _lastStatus = provider.status;

    switch (provider.status) {
      case OtpStatus.success:
        provider.clearStatus();

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          final authRoleService =
          getIt<AuthRoleService>();

          final isAdmin =
          await authRoleService.isCurrentUserAdmin();

          if (!mounted) return;

          if (isAdmin) {
            context.go('/admin');
          } else {
            context.go('/home');
          }
        });

        break;

      case OtpStatus.invalidOtp:
        provider.clearStatus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              content: const Text(
                'کد تایید صحیح نیست.',
              ),
            ),
          );
        });

        break;

      case OtpStatus.networkError:
        provider.clearStatus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              content: const Text(
                'خطا در ارتباط با سرور.',
              ),
            ),
          );
        });

        break;

      case OtpStatus.initial:
      case OtpStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OtpProvider>();

    _handleStatus(provider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 28.h,
                ),

                OtpHeader(
                  phoneNumber: widget.phoneNumber,
                ),

                SizedBox(
                  height: 46.h,
                ),

                const OtpPinField(),

                SizedBox(
                  height: 26.h,
                ),

                const OtpTimer(),

                SizedBox(
                  height: 8.h,
                ),

                const OtpResendButton(),

                const Spacer(),

                const OtpVerifyButton(),

                SizedBox(
                  height: 18.h,
                ),

                Text(
                  'کد ارسال‌شده را وارد کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}