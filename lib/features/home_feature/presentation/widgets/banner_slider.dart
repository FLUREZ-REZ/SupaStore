import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:supastore/features/home_feature/presentation/utils/banner_navigation_handler.dart';

import '../providers/banner_provider.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({
    super.key,
  });

  @override
  State<BannerSlider> createState() =>
      _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<BannerProvider>()
          .loadHeroBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // ============================================
        // Loading
        // ============================================

        if (provider.isHeroLoading) {
          return SizedBox(
            height: 210.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ============================================
        // Error
        // ============================================

        if (provider.heroError != null) {
          return SizedBox(
            height: 180.h,
            child: Center(
              child: Text(
                provider.heroError!,
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
            child: const Center(
              child: Text(
                'بنری وجود ندارد',
              ),
            ),
          );
        }

        // ============================================
        // Prevent invalid indicator index
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
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              child: CarouselSlider.builder(
                itemCount: banners.length,

                itemBuilder: (
                    context,
                    index,
                    realIndex,
                    ) {
                  final banner =
                  banners[index];

                  return _BannerItem(
                    imageUrl:
                    '${banner.imageUrl}?v=${banner.updatedAt.millisecondsSinceEpoch}',
                    onTap: () {
                      BannerNavigationHandler.handle(
                        context: context,
                        banner: banner,
                      );
                    },
                  );
                },

                options: CarouselOptions(
                  // ==================================
                  // One banner only
                  // ==================================

                  height: 180.h,

                  viewportFraction: 1.0,

                  // ==================================
                  // Auto Play
                  // ==================================

                  autoPlay: banners.length > 1,

                  autoPlayInterval:
                  const Duration(
                    seconds: 4,
                  ),

                  autoPlayAnimationDuration:
                  const Duration(
                    milliseconds: 600,
                  ),

                  autoPlayCurve:
                  Curves.easeInOut,

                  // ==================================
                  // No side banners
                  // ==================================

                  enlargeCenterPage: false,

                  // ==================================
                  // Page changed
                  // ==================================

                  onPageChanged: (
                      index,
                      reason,
                      ) {
                    if (!mounted) return;

                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),

            // ========================================
            // Indicator
            // ========================================

            SizedBox(
              height: 14.h,
            ),

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
// Banner Item
// ==================================================

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(18.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,

          width: double.infinity,

          fit: BoxFit.cover,

          // ========================================
          // Memory cache
          // ========================================

          memCacheWidth: 1080,

          // ========================================
          // Disk cache
          // ========================================

          maxWidthDiskCache: 1440,

          // ========================================
          // Placeholder
          // ========================================

          placeholder: (
              context,
              url,
              ) {
            return Container(
              color: Colors.grey.shade200,
            );
          },

          // ========================================
          // Error
          // ========================================

          errorWidget: (
              context,
              url,
              error,
              ) {
            return const Center(
              child: Icon(
                Icons.error_outline,
              ),
            );
          },
        ),
      ),
    );
  }
}