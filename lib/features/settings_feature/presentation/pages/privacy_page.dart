
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supastore/core/theme/app_colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.privacy_page_redi,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 600
                ? 20.0
                : width < 1000
                ? 32.0
                : 40.0;

            final contentMaxWidth = width >= 1000 ? 850.0 : double.infinity;

            final bodyFontSize = width < 600 ? 13.0 : 14.0;
            final cardPadding = width < 600 ? 18.0 : 24.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: width < 600 ? 20 : 30,
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
                        child: Row(
                          children: [
                            Container(
                              width: width < 600 ? 52 : 60,
                              height: width < 600 ? 52 : 60,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.security_copy,
                                size: width < 600 ? 28 : 32,
                                color: primaryColor,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حریم خصوصی',
                                    style: TextStyle(
                                      fontSize: width < 600 ? 18 : 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'محافظت از اطلاعات شما برای ما اهمیت دارد.',
                                    style: TextStyle(
                                      fontSize: width < 600 ? 12 : 14,
                                      color: Colors.grey.shade600,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // INTRO
                      _PrivacySection(
                        title: 'اطلاعاتی که دریافت می‌کنیم',
                        icon: Iconsax.user_copy,
                        iconColor: Colors.blue,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'برای استفاده از برخی امکانات Supastore ممکن است اطلاعاتی مانند شماره همراه، نام و اطلاعات مربوط به حساب کاربری شما دریافت شود.',
                        ),
                      ),

                      // PROFILE
                      _PrivacySection(
                        title: 'اطلاعات حساب کاربری',
                        icon: Iconsax.profile_circle_copy,
                        iconColor: Colors.green,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'اطلاعات حساب کاربری شما برای شناسایی حساب، نمایش اطلاعات پروفایل و ارائه خدمات فروشگاه استفاده می‌شود.',
                        ),
                      ),

                      // ORDERS
                      _PrivacySection(
                        title: 'اطلاعات سفارش‌ها',
                        icon: Iconsax.receipt_copy,
                        iconColor: Colors.orange,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'اطلاعات مربوط به سبد خرید و سفارش‌های شما برای ثبت، پردازش و پیگیری سفارش‌ها استفاده می‌شود.',
                        ),
                      ),

                      // SECURITY
                      _PrivacySection(
                        title: 'امنیت اطلاعات',
                        icon: Iconsax.lock_1_copy,
                        iconColor: Colors.red,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'ما تلاش می‌کنیم اطلاعات کاربران به شکل مناسب نگهداری و محافظت شود و دسترسی به اطلاعات فقط در محدوده مورد نیاز برنامه انجام شود.',
                        ),
                      ),

                      // DATA SHARING
                      _PrivacySection(
                        title: 'اشتراک‌گذاری اطلاعات',
                        icon: Iconsax.share_copy,
                        iconColor: Colors.purple,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'اطلاعات شخصی کاربران بدون مجوز قانونی یا رضایت کاربر، در اختیار اشخاص و مجموعه‌های غیرمرتبط قرار نخواهد گرفت.',
                        ),
                      ),

                      // USER CONTROL
                      _PrivacySection(
                        title: 'کنترل اطلاعات',
                        icon: Iconsax.information_copy,
                        iconColor: Colors.teal,
                        bodyFontSize: bodyFontSize,
                        cardPadding: cardPadding,
                        child: const Text(
                          'شما می‌توانید اطلاعات پروفایل خود مانند نام و تصویر پروفایل را از طریق بخش ویرایش پروفایل تغییر دهید.',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // LAST UPDATE
                      Center(
                        child: Text(
                          'آخرین بروزرسانی: 2026',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ====================================================
// PRIVACY SECTION
// ====================================================

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.bodyFontSize,
    required this.cardPadding,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final double bodyFontSize;
  final double cardPadding;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isCompact ? 38 : 44,
                height: isCompact ? 38 : 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 21 : 24,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          DefaultTextStyle(
            style: TextStyle(
              fontSize: bodyFontSize,
              height: 1.9,
              color: Colors.grey.shade700,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
