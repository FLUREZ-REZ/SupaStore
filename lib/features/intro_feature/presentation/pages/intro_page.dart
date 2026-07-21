import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/intro_data.dart';
import '../providers/intro_provider.dart';
import '../widgets/intro_item.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<IntroProvider>();

    return Scaffold(
        backgroundColor: AppColors.intro_background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
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
                  child: Text(
                    'رد کردن',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),

            /// Pages
            Expanded(
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


            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 20.h,
              ),
              child: Row(
                children: [

                  SizedBox(
                    width: 70.w,
                  ),

                  /// Indicator
                  Expanded(
                    child: Center(
                      child: Selector<
                          IntroProvider,
                          int>(
                        selector: (_, p) =>
                        p.currentPage,
                        builder:
                            (context, page, child) {
                          return SmoothPageIndicator(
                            controller: provider
                                .pageController,
                            count:
                            introList.length,
                            effect:
                            ExpandingDotsEffect(
                              dotHeight: 8.h,
                              dotWidth: 8.w,
                              spacing: 6.w,
                              activeDotColor:
                              AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Selector<
                      IntroProvider,
                      int>(
                    selector: (_, p) =>
                    p.currentPage,
                    builder:
                        (context, page, child) {
                      final isLastPage =
                          page ==
                              introList.length -
                                  1;

                      return TextButton(
                        onPressed: () async {
                          if (isLastPage) {
                            await provider
                                .completeIntro();

                            if (context.mounted) {
                              context.go(
                                  '/auth');
                            }
                          } else {
                            provider
                                .pageController
                                .nextPage(
                              duration:
                              const Duration(
                                milliseconds:
                                300,
                              ),
                              curve: Curves
                                  .easeInOut,
                            );
                          }
                        },
                        child: AnimatedSwitcher(
                          duration:
                          const Duration(
                            milliseconds: 250,
                          ),
                          transitionBuilder:
                              (child,
                              animation) {
                            return FadeTransition(
                              opacity:
                              animation,
                              child: child,
                            );
                          },
                          child: Text(
                            isLastPage
                                ? 'شروع خرید'
                                : 'بعدی',
                            key: ValueKey(
                                isLastPage),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors
                                  .primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}