import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/auth_feature/presentation/widgets/phone_textfield.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.auth_background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  final bool isMobile = width < 600;
                  final bool isTablet = width >= 600 && width < 1024;
                  final bool isDesktop = width >= 1024;

                  final double contentMaxWidth = isMobile
                      ? 480
                      : isTablet
                      ? 460
                      : 480;

                  final double horizontalPadding = isMobile
                      ? 24
                      : isTablet
                      ? 32
                      : 40;

                  final double logoSize = isMobile
                      ? 120
                      : isTablet
                      ? 135
                      : 145;

                  final double topSpacing = isMobile
                      ? (height * 0.08).clamp(24.0, 64.0)
                      : isTablet
                      ? 48
                      : 56;

                  final double sectionSpacing = isMobile ? 24 : 28;

                  final double titleSpacing = isMobile ? 8 : 12;

                  final double fieldSpacing = isMobile ? 20 : 24;

                  final double bottomSpacing = isMobile ? 20 : 24;

                  return Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: height,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: contentMaxWidth,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: topSpacing),

                                    // LOGO
                                    SvgPicture.asset(
                                      'assets/logo/logo.svg',
                                      width: logoSize,
                                      height: logoSize,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.intro_description,
                                        BlendMode.srcIn,
                                      ),
                                      fit: BoxFit.contain,
                                    ),

                                    const SizedBox(height: 8),

                                    // APP NAME
                                    Text(
                                      'SupaStore',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.auth_title_text
                                          .copyWith(
                                        color: AppColors.auth_title_text,
                                        fontSize: isMobile
                                            ? 24
                                            : isTablet
                                            ? 27
                                            : 29,
                                      ),
                                    ),

                                    SizedBox(height: sectionSpacing),

                                    // DESCRIPTION
                                    SizedBox(height: titleSpacing),

                                    Text(
                                      'برای ادامه شماره موبایل خود را وارد کنید',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.auth_countinue
                                          .copyWith(
                                        color: AppColors.auth_continue,
                                        fontSize: isMobile
                                            ? 14
                                            : isTablet
                                            ? 16
                                            : 17,
                                        height: 1.8,
                                      ),
                                    ),

                                    SizedBox(height: fieldSpacing),

                                    // PHONE FIELD
                                    PhoneTextField(
                                      controller: provider.phoneController,
                                      onChanged: provider.phoneChanged,
                                    ),

                                    const Spacer(),

                                    SizedBox(height: isMobile ? 40 : 56),

                                    // CONTINUE BUTTON
                                    AuthButton(
                                      loading: provider.isLoading,
                                      enabled: provider.isValidPhone,
                                      onTap: () async {
                                        final success =
                                        await provider.sendOtp();

                                        if (!context.mounted) return;

                                        if (success) {
                                          context.push(
                                            '/otp',
                                            extra:
                                            '+98${provider.phoneController.text.replaceAll(' ', '')}',
                                          );
                                        }
                                      },
                                    ),

                                    SizedBox(height: bottomSpacing),

                                    // TERMS
                                    Text(
                                      'با ورود، قوانین و حریم خصوصی را می‌پذیرید',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.auth_rules.copyWith(
                                        color: AppColors.auth_rules,
                                        fontSize: isMobile ? 11 : 12,
                                        height: 1.8,
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
          );
        },
      ),
    );
  }
}