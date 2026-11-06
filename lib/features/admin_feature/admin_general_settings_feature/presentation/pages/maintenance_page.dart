import 'package:flutter/material.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1000;
            final isTablet = width >= 600 && width < 1000;

            final horizontalPadding = isDesktop
                ? 48.0
                : isTablet
                ? 36.0
                : 24.0;

            final iconSize = isDesktop
                ? 112.0
                : isTablet
                ? 104.0
                : 92.0;

            final symbolSize = isDesktop
                ? 54.0
                : isTablet
                ? 50.0
                : 44.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.build_outlined,
                            size: symbolSize,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'فروشگاه موقتاً در دسترس نیست',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: isDesktop
                                ? 26
                                : isTablet
                                ? 23
                                : 20,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            height: 1.9,
                            fontSize: isDesktop
                                ? 17
                                : isTablet
                                ? 15
                                : 14,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          width: 56,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'لطفاً بعداً دوباره مراجعه کنید.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: isDesktop ? 15 : 13,
                          ),
                        ),
                      ],
                    ),
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