
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _callSupport(
      BuildContext context,
      String phone,
      ) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('امکان برقراری تماس وجود ندارد.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('امکان برقراری تماس وجود ندارد.'),
        ),
      );
    }
  }

  Future<void> _sendEmail(
      BuildContext context,
      String email,
      ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('برنامه‌ای برای ارسال ایمیل پیدا نشد.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برنامه‌ای برای ارسال ایمیل پیدا نشد.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.support_page_redi,
          elevation: 0,
        ),
        body: Consumer<StoreSettingsProvider>(
          builder: (context, storeSettingsProvider, child) {
            final phone = storeSettingsProvider.phone?.trim();
            final email = storeSettingsProvider.email?.trim();

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final horizontalPadding = width < 600
                    ? 16.0
                    : width < 1000
                    ? 28.0
                    : 40.0;

                final contentMaxWidth =
                width >= 1000 ? 900.0 : double.infinity;

                final isMobile = width < 600;
                final cardPadding = isMobile ? 18.0 : 24.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isMobile ? 20 : 30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: isMobile ? 64 : 76,
                                  height: isMobile ? 64 : 76,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.support_agent_rounded,
                                    size: isMobile ? 34 : 40,
                                    color: AppColors.support_page_redi,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'چطور می‌توانیم کمکتان کنیم؟',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'در صورت داشتن سوال یا مشکل، با ما در ارتباط باشید.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    height: 1.7,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // CONTACT SECTION
                          if ((phone != null && phone.isNotEmpty) ||
                              (email != null && email.isNotEmpty)) ...[
                            const _SectionTitle(
                              title: 'راه‌های ارتباطی',
                            ),

                            const SizedBox(height: 8),
                          ],

                          if (phone != null && phone.isNotEmpty)
                            _SupportItem(
                              icon: Iconsax.call_copy,
                              title: 'تماس با پشتیبانی',
                              subtitle: phone,
                              iconColor: Colors.green,
                              onTap: () {
                                _callSupport(context, phone);
                              },
                            ),

                          if (phone != null &&
                              phone.isNotEmpty &&
                              email != null &&
                              email.isNotEmpty)
                            const SizedBox(height: 10),

                          if (email != null && email.isNotEmpty)
                            _SupportItem(
                              icon: Iconsax.message_copy,
                              title: 'ایمیل پشتیبانی',
                              subtitle: email,
                              iconColor: Colors.blue,
                              onTap: () {
                                _sendEmail(context, email);
                              },
                            ),

                          const SizedBox(height: 24),

                          // WORKING HOURS
                          const _SectionTitle(
                            title: 'ساعات پاسخگویی',
                          ),

                          const SizedBox(height: 8),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isMobile ? 42 : 48,
                                  height: isMobile ? 42 : 48,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Iconsax.clock_copy,
                                    color: Colors.orange,
                                    size: isMobile ? 23 : 26,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'شنبه تا پنجشنبه',
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        '۹:۰۰ تا ۱۸:۰۰',
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // FAQ
                          const _SectionTitle(
                            title: 'سوالات متداول',
                          ),

                          const SizedBox(height: 8),

                          const _FaqItem(
                            question: 'چطور سفارش خود را پیگیری کنم؟',
                            answer:
                            'از بخش «سفارش‌های من» در پروفایل می‌توانید وضعیت سفارش‌های خود را مشاهده کنید.',
                          ),

                          const SizedBox(height: 8),

                          const _FaqItem(
                            question: 'چطور اطلاعات پروفایل را تغییر دهم؟',
                            answer:
                            'از صفحه پروفایل وارد بخش ویرایش پروفایل شوید و اطلاعات موردنظر را تغییر دهید.',
                          ),

                          const SizedBox(height: 8),

                          const _FaqItem(
                            question:
                            'اگر مشکلی در سفارش وجود داشته باشد چه کار کنم؟',
                            answer:
                            'می‌توانید با استفاده از اطلاعات تماس بالا با پشتیبانی ارتباط برقرار کنید.',
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ====================================================
// SECTION TITLE
// ====================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? 15 : 17,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

// ====================================================
// SUPPORT ITEM
// ====================================================

class _SupportItem extends StatelessWidget {
  const _SupportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 44 : 50,
                height: isMobile ? 44 : 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isMobile ? 23 : 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isMobile ? 16 : 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================
// FAQ ITEM
// ====================================================

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 22,
          vertical: 4,
        ),
        childrenPadding: EdgeInsets.only(
          left: isMobile ? 16 : 22,
          right: isMobile ? 16 : 22,
          bottom: 16,
        ),
        title: Text(
          question,
          style: TextStyle(
            fontSize: isMobile ? 13 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Colors.grey.shade500,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                height: 1.8,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
