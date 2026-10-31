import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/core/theme/app_colors.dart';

import '../../data/intro_data.dart';
import '../providers/intro_provider.dart';
import '../widgets/intro_item.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.intro_background_gradiant,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final isMobile = width < 600;
              final isTablet = width >= 600 && width < 1024;
              final isDesktop = width >= 1024;

              final horizontalPadding = isMobile
                  ? 20.0
                  : isTablet
                  ? 40.0
                  : 64.0;

              final topPadding = isMobile
                  ? 8.0
                  : isTablet
                  ? 16.0
                  : 20.0;

              final bottomPadding = isMobile
                  ? 16.0
                  : isTablet
                  ? 24.0
                  : 28.0;

              final skipFontSize = isMobile
                  ? 14.0
                  : isTablet
                  ? 16.0
                  : 17.0;

              final buttonFontSize = isMobile
                  ? 15.0
                  : isTablet
                  ? 17.0
                  : 18.0;

              final dotSize = isMobile
                  ? 8.0
                  : isTablet
                  ? 9.0
                  : 10.0;

              final dotSpacing = isMobile ? 6.0 : 8.0;

              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    // TOP BAR - SKIP BUTTON

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: topPadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await provider.completeIntro();

                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 20,
                              vertical: 10,
                            ),
                            minimumSize: const Size(48, 44),
                            tapTargetSize:
                            MaterialTapTargetSize.padded,
                          ),
                          child: Text(
                            'رد کردن',
                            style: AppTextStyles.intro_skip_text.copyWith(
                              color: AppColors.intro_skip_text,
                              fontSize: skipFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // INTRO PAGES

                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1200 : 900,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: PageView.builder(
                              controller: provider.pageController,
                              itemCount: introList.length,
                              onPageChanged: provider.changePage,
                              itemBuilder: (context, index) {
                                final item = introList[index];

                                return IntroItem(
                                  image: item.image,
                                  title: item.title,
                                  description: item.description,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // BOTTOM CONTROLS

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isMobile ? 8 : 16,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // INDICATOR - EXACT CENTER

                            Selector<IntroProvider, int>(
                              selector: (_, p) => p.currentPage,
                              builder: (context, page, child) {
                                return SmoothPageIndicator(
                                  controller: provider.pageController,
                                  count: introList.length,
                                  effect: ExpandingDotsEffect(
                                    dotHeight: dotSize,
                                    dotWidth: dotSize,
                                    spacing: dotSpacing,
                                    activeDotColor:
                                    AppColors.intro_indicator_dots,
                                  ),
                                );
                              },
                            ),

                            // NEXT / START BUTTON - RIGHT

                            Align(
                              alignment: Alignment.centerRight,
                              child: Selector<IntroProvider, int>(
                                selector: (_, p) => p.currentPage,
                                builder: (context, page, child) {
                                  final isLastPage =
                                      page == introList.length - 1;

                                  return TextButton(
                                    onPressed: () async {
                                      if (isLastPage) {
                                        await provider.completeIntro();

                                        if (context.mounted) {
                                          context.go('/auth');
                                        }
                                      } else {
                                        provider.pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 8 : 16,
                                        vertical: 12,
                                      ),
                                      minimumSize: const Size(48, 44),
                                      tapTargetSize:
                                      MaterialTapTargetSize.padded,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      transitionBuilder:
                                          (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        isLastPage
                                            ? 'شروع خرید'
                                            : 'بعدی',
                                        key: ValueKey(isLastPage),
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles
                                            .intro_next_text
                                            .copyWith(
                                          color:
                                          AppColors.intro_next_text,
                                          fontSize: buttonFontSize,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}