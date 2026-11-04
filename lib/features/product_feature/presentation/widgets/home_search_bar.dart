import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isDesktop = width >= 1024;
        final bool isTablet = width >= 600 && width < 1024;

        final double horizontalPadding = isDesktop
            ? 24
            : isTablet
            ? 24
            : 20;

        final double verticalPadding = isDesktop
            ? 10
            : isTablet
            ? 10
            : 12;

        // Search bar height
        final double searchHeight = isDesktop
            ? 58
            : isTablet
            ? 54
            : 65;

        // Search icon container
        final double iconContainerSize = isDesktop
            ? 36
            : isTablet
            ? 32
            : 34;

        final double iconSize = isDesktop
            ? 21
            : isTablet
            ? 19
            : 20;

        // Text sizes
        final double hintFontSize = isDesktop
            ? 16
            : isTablet
            ? 14
            : 16;

        final double brandFontSize = isDesktop
            ? 22
            : isTablet
            ? 18
            : 22;

        final double radius = isDesktop ? 12 : 14;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 850 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(radius),
                    onTap: () {
                      context.pushNamed('search');
                    },
                    child: Container(
                      height: searchHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Search Icon
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              size: iconSize,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Search Hint
                          Expanded(
                            child: RichText(
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'جستجو در ',
                                    style: AppTextStyles.auth_textfield
                                        .copyWith(
                                      color: Colors.grey.shade500,
                                      fontSize: hintFontSize,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'سوپااستور',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontFamily: 'roosta',
                                      fontWeight: FontWeight.w700,
                                      fontSize: brandFontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Arrow Icon
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: isDesktop ? 16 : 15,
                            color: Colors.grey.shade400,
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
    );
  }
}