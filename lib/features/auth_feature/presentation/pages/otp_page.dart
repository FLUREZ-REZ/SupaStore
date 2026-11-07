import 'package:flutter/material.dart';
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
      if (!mounted) return;

      final provider = context.read<OtpProvider>();

      provider.setPhone(widget.phoneNumber);

// تشخیص حساب‌های دمو
      final isDemoAccount =
          widget.phoneNumber == '+989120000001' ||
              widget.phoneNumber == '+989120000002';

      if (isDemoAccount) {
        provider.setDemoOtp();
      }

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

          final authRoleService = getIt<AuthRoleService>();

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
                borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final bool isMobile = width < 600;
              final bool isTablet = width >= 600 && width < 1024;

              final double contentWidth = isMobile
                  ? width
                  : isTablet
                  ? 480
                  : 500;

              final double horizontalPadding = isMobile
                  ? 24
                  : isTablet
                  ? 32
                  : 40;

              final double topSpacing = isMobile
                  ? (height * 0.04).clamp(16.0, 32.0)
                  : isTablet
                  ? 36
                  : 42;

              final double headerSpacing = isMobile
                  ? 38
                  : isTablet
                  ? 46
                  : 52;

              final double pinTimerSpacing = isMobile ? 24 : 30;

              final double timerResendSpacing = isMobile ? 8 : 12;

              final double bottomSpacing = isMobile ? 20 : 24;

              return Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: topSpacing),

                                // OTP HEADER
                                OtpHeader(
                                  phoneNumber: widget.phoneNumber,
                                ),

                                SizedBox(height: headerSpacing),

                                // OTP INPUT
                                const OtpPinField(),

                                SizedBox(height: pinTimerSpacing),

                                // TIMER
                                const OtpTimer(),

                                SizedBox(height: timerResendSpacing),

                                // RESEND BUTTON
                                const OtpResendButton(),

                                const Spacer(),

                                SizedBox(
                                  height: isMobile ? 48 : 64,
                                ),

                                // VERIFY BUTTON
                                const OtpVerifyButton(),

                                SizedBox(height: bottomSpacing),

                                // HELPER TEXT
                                Text(
                                  'کد ارسال‌شده را وارد کنید',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile
                                        ? 11
                                        : isTablet
                                        ? 12
                                        : 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                    height: 1.6,
                                  ),
                                ),

                                SizedBox(height: bottomSpacing),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}