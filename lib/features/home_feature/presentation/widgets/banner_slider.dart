
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        // ============================================
        // Loading + Minimum 2 Seconds Shimmer
        // ============================================

        if (provider.isHeroLoading || !_minimumShimmerFinished) {
          return _BannerSliderShimmer(
            controller: _shimmerController,
          );
        }

        // ============================================
        // Error
        // ============================================

        if (provider.heroError != null) {
          return SizedBox(
            height: 180.h,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.grey.shade600,
                      size: 28.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      provider.heroError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextButton.icon(
                      onPressed: () {
                        context.read<BannerProvider>().loadHeroBanners();
                      },
                      icon: const Icon(Icons.refresh_rounded),
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
        // Empty
        // ============================================

        if (banners.isEmpty) {
          return SizedBox(
            height: 180.h,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 30.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'بنری وجود ندارد',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ============================================
        // Prevent Invalid Indicator Index
        // ============================================

        if (_currentIndex >= banners.length) {
          _currentIndex = 0;
        }

        // ============================================
        // Slider
        // ============================================

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: CarouselSlider.builder(
                itemCount: banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = banners[index];

                  return _BannerItem(
                    imageUrl:
                    '${banner.imageUrl}?v=${banner.updatedAt.millisecondsSinceEpoch}',
                    shimmerController: _shimmerController,
                    onTap: () {
                      BannerNavigationHandler.handle(
                        context: context,
                        banner: banner,
                      );
                    },
                  );
                },
                options: CarouselOptions(
                  height: 180.h,
                  viewportFraction: 1.0,

                  // Auto Play
                  autoPlay: banners.length > 1,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 600),
                  autoPlayCurve: Curves.easeInOut,

                  // No Side Banners
                  enlargeCenterPage: false,

                  // Page Changed
                  onPageChanged: (index, reason) {
                    if (!mounted) return;

                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // Indicator
            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: banners.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8.h,
                dotWidth: 8.w,
                expansionFactor: 3,
              ),
            ),
          ],
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
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: _ShimmerBox(
              controller: controller,
              width: double.infinity,
              height: 180.h,
              radius: 18.r,
            ),
          ),
        ),
        SizedBox(height: 14.h),

        // Shimmer indicator placeholders
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ShimmerBox(
              controller: controller,
              width: 22.w,
              height: 8.h,
              radius: 10.r,
            ),
            SizedBox(width: 5.w),
            _ShimmerBox(
              controller: controller,
              width: 8.w,
              height: 8.h,
              radius: 10.r,
            ),
            SizedBox(width: 5.w),
            _ShimmerBox(
              controller: controller,
              width: 8.w,
              height: 8.h,
              radius: 10.r,
            ),
          ],
        ),
      ],
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
              colors: [
                const Color(0xFFE5E5E5),
                const Color(0xFFF7F7F7),
                const Color(0xFFE5E5E5),
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
  });

  final String imageUrl;
  final VoidCallback onTap;
  final AnimationController shimmerController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,

          // Memory cache
          memCacheWidth: 1080,

          // Disk cache
          maxWidthDiskCache: 1440,

          // Shimmer while the image itself is loading
          placeholder: (context, url) {
            return _ShimmerBox(
              controller: shimmerController,
              width: double.infinity,
              height: 180.h,
              radius: 18.r,
            );
          },

          // Image error
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 30.sp,
                color: Colors.grey.shade500,
              ),
            );
          },
        ),
      ),
    );
  }
}
