
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
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

                                    const SizedBox(height: 22),

                                    // DEMO ACCOUNTS TITLE
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: AppColors.auth_continue
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'ورود سریع دمو',
                                            style: AppTextStyles.auth_rules
                                                .copyWith(
                                              color: AppColors.auth_continue,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: AppColors.auth_continue
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // DEMO ACCOUNT CARDS
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _DemoAccountCard(
                                            title: 'حساب مدیر',
                                            phone: '9120000001',
                                            icon: Icons.admin_panel_settings,
                                            color: const Color(0xFF023E8A),
                                            onTap: () {
                                              provider.selectDemoAccount('9120000001');
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _DemoAccountCard(
                                            title: 'حساب مشتری',
                                            phone: '9120000002',
                                            icon: Icons.person_outline,
                                            color: const Color(0xFF0096C7),
                                            onTap: () {
                                              provider.selectDemoAccount('9120000002');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    SizedBox(
                                      height: isMobile ? 36 : 44,
                                    ),

                                    // CONTINUE BUTTON
                                    AuthButton(
                                      loading: provider.isLoading,
                                      enabled: provider.isValidPhone,
                                      onTap: () async {
                                        final success =
                                        await provider.sendOtp();

                                        if (!context.mounted) return;

                                        if (success) {
                                          final phone = provider
                                              .phoneController.text
                                              .replaceAll(' ', '');

                                          context.push(
                                            '/otp',
                                            extra: '+98$phone',
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

class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard({
    required this.title,
    required this.phone,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String phone;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 25,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                phone,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'انتخاب حساب',
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
