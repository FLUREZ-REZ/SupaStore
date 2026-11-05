
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:supastore/features/home_feature/presentation/utils/banner_navigation_handler.dart';

import '../providers/banner_provider.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  bool _minimumShimmerFinished = false;

  late final AnimationController _shimmerController;

  Timer? _minimumShimmerTimer;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // حداقل زمان نمایش شیمر: ۲ ثانیه
    _minimumShimmerTimer = Timer(
      const Duration(seconds: 2),
          () {
        if (!mounted) return;

        setState(() {
          _minimumShimmerFinished = true;
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BannerProvider>().loadHeroBanners();
    });
  }

  @override
  void dispose() {
    _minimumShimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;

            // ============================================
            // RESPONSIVE BREAKPOINTS
            // ============================================

            final bool isMobile = screenWidth < 600;

            final bool isTablet =
                screenWidth >= 600 && screenWidth < 1024;

            final bool isLaptop =
                screenWidth >= 1024 && screenWidth < 1440;

            final bool isDesktop = screenWidth >= 1440;

            // ============================================
            // RESPONSIVE BANNER HEIGHT
            // ============================================

            final double bannerHeight = isMobile
                ? (screenWidth * 0.38).clamp(155.0, 190.0)
                : isTablet
                ? (screenWidth * 0.29).clamp(240.0, 300.0)
                : isLaptop
                ? (screenWidth * 0.30).clamp(330.0, 450.0)
                : (screenWidth * 0.30).clamp(400.0, 520.0);

            // ============================================
            // RESPONSIVE HORIZONTAL PADDING
            // ============================================

            final double horizontalPadding = isMobile
                ? 12
                : isTablet
                ? 24
                : isLaptop
                ? 24
                : 32;

            // ============================================
            // RESPONSIVE BORDER RADIUS
            // ============================================

            final double borderRadius = isMobile
                ? 14
                : isTablet
                ? 18
                : 22;

            // ============================================
            // RESPONSIVE INDICATOR
            // ============================================

            final double indicatorSpacing = isMobile
                ? 12
                : isTablet
                ? 16
                : 20;

            final double dotSize = isMobile
                ? 7
                : isTablet
                ? 8
                : 9;

            final double indicatorExpansion =
            isMobile ? 3 : 3.5;

            // ============================================
            // BANNER WIDTH
            // ============================================

            final double maxBannerWidth = isMobile
                ? screenWidth
                : isTablet
                ? 1100
                : isLaptop
                ? 1600
                : double.infinity;

            // ============================================
            // LOADING + MINIMUM 2 SECONDS SHIMMER
            // ============================================

            if (provider.isHeroLoading ||
                !_minimumShimmerFinished) {
              return _BannerSliderShimmer(
                controller: _shimmerController,
                height: bannerHeight,
                horizontalPadding: horizontalPadding,
                borderRadius: borderRadius,
                indicatorSpacing: indicatorSpacing,
                dotSize: dotSize,
                maxWidth: maxBannerWidth,
              );
            }

            // ============================================
            // ERROR
            // ============================================

            if (provider.heroError != null) {
              return SizedBox(
                height: bannerHeight,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.grey.shade600,
                          size: isMobile ? 28 : 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.heroError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () {
                            context
                                .read<BannerProvider>()
                                .loadHeroBanners();
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                          ),
                          label: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final banners = provider.heroBanners;

            // ============================================
            // EMPTY
            // ============================================

            if (banners.isEmpty) {
              return SizedBox(
                height: bannerHeight,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: isMobile ? 30 : 36,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'بنری وجود ندارد',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ============================================
            // PREVENT INVALID INDICATOR INDEX
            // ============================================

            if (_currentIndex >= banners.length) {
              _currentIndex = 0;
            }

            // ============================================
            // SLIDER
            // ============================================

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxBannerWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: CarouselSlider.builder(
                        itemCount: banners.length,
                        itemBuilder: (context, index, realIndex) {
                          final banner = banners[index];

                          return _BannerItem(
                            imageUrl:
                            '${banner.imageUrl}?v=${banner.updatedAt.millisecondsSinceEpoch}',
                            shimmerController: _shimmerController,
                            height: bannerHeight,
                            borderRadius: borderRadius,
                            onTap: () {
                              BannerNavigationHandler.handle(
                                context: context,
                                banner: banner,
                              );
                            },
                          );
                        },
                        options: CarouselOptions(
                          height: bannerHeight,
                          viewportFraction: 1.0,

                          autoPlay: banners.length > 1,
                          autoPlayInterval:
                          const Duration(seconds: 4),
                          autoPlayAnimationDuration:
                          const Duration(milliseconds: 600),
                          autoPlayCurve: Curves.easeInOut,

                          enlargeCenterPage: false,

                          onPageChanged: (index, reason) {
                            if (!mounted) return;

                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: indicatorSpacing),

                // ============================================
                // INDICATOR
                // ============================================

                AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: banners.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: dotSize,
                    dotWidth: dotSize,
                    expansionFactor: indicatorExpansion,
                    spacing: isMobile ? 5 : 6,
                    activeDotColor:
                    Theme.of(context).colorScheme.primary,
                    dotColor: Colors.grey.shade300,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ==================================================
// BANNER SLIDER SHIMMER
// ==================================================

class _BannerSliderShimmer extends StatelessWidget {
  const _BannerSliderShimmer({
    required this.controller,
    required this.height,
    required this.horizontalPadding,
    required this.borderRadius,
    required this.indicatorSpacing,
    required this.dotSize,
    required this.maxWidth,
  });

  final AnimationController controller;
  final double height;
  final double horizontalPadding;
  final double borderRadius;
  final double indicatorSpacing;
  final double dotSize;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    borderRadius,
                  ),
                  child: _ShimmerBox(
                    controller: controller,
                    width: double.infinity,
                    height: height,
                    radius: borderRadius,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: indicatorSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShimmerBox(
                controller: controller,
                width: dotSize * 2.8,
                height: dotSize,
                radius: 10,
              ),
              const SizedBox(width: 5),
              _ShimmerBox(
                controller: controller,
                width: dotSize,
                height: dotSize,
                radius: 10,
              ),
              const SizedBox(width: 5),
              _ShimmerBox(
                controller: controller,
                width: dotSize,
                height: dotSize,
                radius: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================
// SHIMMER BOX
// ==================================================

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    this.width,
    this.height,
    this.radius = 8,
  });

  final AnimationController controller;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value * 2 - 1;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(progress - 1, 0),
              end: Alignment(progress + 1, 0),
              colors: const [
                Color(0xFFE5E5E5),
                Color(0xFFF7F7F7),
                Color(0xFFE5E5E5),
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }
}

// ==================================================
// BANNER ITEM
// ==================================================

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.imageUrl,
    required this.onTap,
    required this.shimmerController,
    required this.height,
    required this.borderRadius,
  });

  final String imageUrl;
  final VoidCallback onTap;
  final AnimationController shimmerController;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: height,

          // حفظ نمایش کامل‌تر در دسکتاپ نیازمند
          // هماهنگی نسبت تصویر با فضای نمایش است.
          fit: BoxFit.cover,
          alignment: Alignment.center,

          // محدودیت رزولوشن Cache حذف شده است.

          placeholder: (context, url) {
            return _ShimmerBox(
              controller: shimmerController,
              width: double.infinity,
              height: height,
              radius: borderRadius,
            );
          },

          errorWidget: (context, url, error) {
            return Container(
              height: height,
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 30,
                color: Colors.grey.shade500,
              ),
            );
          },
        ),
      ),
    );
  }
}
