
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/phone_textfield.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static const Color _primary = Color(0xFF03045E);
  static const Color _blue = Color(0xFF0077B6);
  static const Color _lightBlue = Color(0xFFEAF6FC);
  static const Color _background = Color(0xFFF5F7FB);
  static const Color _textDark = Color(0xFF202438);
  static const Color _textGrey = Color(0xFF8992A5);
  static const Color _border = Color(0xFFE9EDF3);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: _background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  final isMobile = width < 600;
                  final isTablet = width >= 600 && width < 1024;

                  final contentWidth = isMobile ? width : 460.0;

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
                                horizontal: isMobile ? 20 : 28,
                                vertical: isMobile ? 24 : 36,
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    // BRAND NAME (WITHOUT LOGO)
                                    const SizedBox(height: 12),

                                    const Text(
                                      'SupaStore',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _primary,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.8,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      'تجربه‌ای متفاوت از خرید آنلاین',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _textGrey,
                                        fontSize: isMobile ? 12 : 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(
                                      height: isMobile ? 28 : 36,
                                    ),

                                    // LOGIN CARD
                                    Container(
                                      padding: EdgeInsets.all(
                                        isMobile ? 22 : 28,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(24),
                                        border: Border.all(
                                          color: _border,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _primary.withValues(
                                              alpha: 0.045,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          // TITLE
                                          const Text(
                                            'خوش اومدی!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w800,
                                              color: _textDark,
                                            ),
                                          ),

                                          const SizedBox(height: 9),

                                          Text(
                                            'برای ورود یا ثبت‌نام، شماره موبایلت رو وارد کن',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isMobile ? 12 : 13,
                                              height: 1.9,
                                              color: _textGrey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),

                                          const SizedBox(height: 28),

                                          // PHONE LABEL
                                          const Text(
                                            'شماره موبایل',
                                            style: TextStyle(
                                              color: _textDark,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          // PHONE FIELD
                                          PhoneTextField(
                                            controller:
                                            provider.phoneController,
                                            onChanged: provider.phoneChanged,
                                          ),

                                          const SizedBox(height: 25),

                                          // DEMO DIVIDER
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 1,
                                                  color: _border,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.bolt_rounded,
                                                      color: _blue,
                                                      size: 17,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'ورود سریع دمو',
                                                      style: TextStyle(
                                                        color: _textDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 1,
                                                  color: _border,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // DEMO ACCOUNTS
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _DemoAccountCard(
                                                  title: 'حساب مدیر',
                                                  subtitle: 'مدیریت فروشگاه',
                                                  phone: '9120000001',
                                                  icon: Icons
                                                      .admin_panel_settings_rounded,
                                                  color: _primary,
                                                  background: const Color(
                                                    0xFFF0F1FA,
                                                  ),
                                                  selected:
                                                  provider.phoneController
                                                      .text
                                                      .replaceAll(
                                                    ' ',
                                                    '',
                                                  ) ==
                                                      '9120000001',
                                                  onTap: () {
                                                    provider.selectDemoAccount(
                                                      '9120000001',
                                                    );
                                                  },
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: _DemoAccountCard(
                                                  title: 'حساب مشتری',
                                                  subtitle: 'خرید از فروشگاه',
                                                  phone: '9120000002',
                                                  icon: Icons.person_rounded,
                                                  color: _blue,
                                                  background: _lightBlue,
                                                  selected:
                                                  provider.phoneController
                                                      .text
                                                      .replaceAll(
                                                    ' ',
                                                    '',
                                                  ) ==
                                                      '9120000002',
                                                  onTap: () {
                                                    provider.selectDemoAccount(
                                                      '9120000002',
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 28),

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

                                          const SizedBox(height: 18),

                                          // SECURITY MESSAGE
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.lock_outline_rounded,
                                                size: 14,
                                                color: _textGrey.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'اطلاعات شما محفوظ و امن خواهد بود',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: _textGrey,
                                                    fontSize:
                                                    isMobile ? 10 : 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // FOOTER
                                    Text(
                                      'با ورود به سوپاستور، قوانین و حریم خصوصی را می‌پذیرید.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _textGrey,
                                        fontSize: isMobile ? 10 : 11,
                                        height: 1.8,
                                      ),
                                    ),
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

// --------------------------------------------------
// DEMO ACCOUNT CARD
// --------------------------------------------------

class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard({
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.color,
    required this.background,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: selected ? background : const Color(0xFFFAFBFD),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.65)
                  : const Color(0xFFE9EDF3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // ICON
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),

              const SizedBox(height: 11),

              // TITLE
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              // SUBTITLE
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8992A5),
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 9),

              // PHONE
              Text(
                phone,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 10),

              // SELECTION STATUS
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color
                      : color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selected ? 'انتخاب شد' : 'انتخاب حساب',
                  style: TextStyle(
                    color: selected ? Colors.white : color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
