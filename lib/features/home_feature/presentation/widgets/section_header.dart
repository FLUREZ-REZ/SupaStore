
import 'package:flutter/material.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'home_content_container.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showSeeAll = true,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
        ? 20
        : 24;

    final double titleFontSize = isMobile
        ? 16
        : isTablet
        ? 15
        : 16;

    final double seeAllFontSize = 12;
    final double iconSize = isMobile ? 18 : 17;

    return HomeContentContainer(
      maxWidth: 1200,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isMobile ? 8 : 10,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.section_title.copyWith(
                    color: AppColors.section_header,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showSeeAll)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'مشاهده همه',
                          style: AppTextStyles.section_title.copyWith(
                            color: AppColors.section_seeAll,
                            fontSize: seeAllFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_left,
                          size: iconSize,
                          color: AppColors.primary,
                        ),
                      ],
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
