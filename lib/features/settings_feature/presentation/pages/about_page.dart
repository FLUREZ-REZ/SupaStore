
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supastore/core/theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
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
          title: const Text('درباره ما'),
          centerTitle: true,
          backgroundColor: AppColors.about_us_page_redi,
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

            final contentMaxWidth = width >= 1000 ? 720.0 : double.infinity;

            final logoSize = width < 600 ? 100.0 : 112.0;
            final titleSize = width < 600 ? 24.0 : 28.0;
            final bodyFontSize = width < 600 ? 14.0 : 15.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: width < 600 ? 25 : 36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentMaxWidth,
                  ),
                  child: Column(
                    children: [
                      // LOGO
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: AppColors.about_us_page_redi,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.shop_copy,
                          size: width < 600 ? 52 : 58,
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // APP NAME
                      Text(
                        'Supastore',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // SHORT DESCRIPTION
                      Text(
                        'فروشگاه آنلاین Supastore',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ABOUT CARD
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(width < 600 ? 20 : 26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.info_circle_copy,
                                  size: 22,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'درباره Supastore',
                                    style: TextStyle(
                                      fontSize: width < 600 ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Supastore یک فروشگاه آنلاین است که با هدف ارائه تجربه‌ای ساده، سریع و راحت برای خرید طراحی شده است.',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                height: 1.8,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // VERSION CARD
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: width < 600 ? 20 : 26,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.mobile_copy,
                              size: 22,
                              color: Colors.grey.shade600,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'نسخه برنامه',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Text(
                              '1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // COPYRIGHT
                      Text(
                        '© 2026 Supastore',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
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
