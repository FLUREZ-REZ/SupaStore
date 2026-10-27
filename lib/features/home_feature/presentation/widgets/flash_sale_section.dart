
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/flash_sale_feature/presentation/providers/flash_sale_provider.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

import 'flash_sale_countdown.dart';
import 'flash_sale_product_card.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({
    super.key,
    this.onProductTap,
    this.onSeeAll,
  });

  final void Function(ProductEntity product)? onProductTap;
  final VoidCallback? onSeeAll;

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  Timer? _minimumShimmerTimer;
  bool _minimumShimmerFinished = false;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

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

      context.read<FlashSaleProvider>().fetchFlashSales();
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
    return Consumer<FlashSaleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading || !_minimumShimmerFinished) {
          return _FlashSaleShimmer(
            controller: _shimmerController,
          );
        }

        if (provider.errorMessage != null) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 28.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () {
                        context
                            .read<FlashSaleProvider>()
                            .fetchFlashSales();
                      },
                      child: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!provider.hasData) {
          return const SizedBox.shrink();
        }

        final endAt = provider.items.first.endAt;

        return Container(
          margin: EdgeInsets.only(
            top: 12.h,
            bottom: 12.h,
          ),
          padding: EdgeInsets.only(
            top: 14.h,
            bottom: 14.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.home_header_background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'شگفت‌انگیز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FlashSaleCountdown(endAt: endAt),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Products
              SizedBox(
                height: 275.h,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];

                      return FlashSaleProductCard(
                        item: item,
                        onTap: () {
                          widget.onProductTap?.call(item.product);
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // See All
              if (widget.onSeeAll != null)
                Center(
                  child: GestureDetector(
                    onTap: widget.onSeeAll,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        'مشاهده همه',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// Flash Sale Shimmer
// --------------------------------------------------

class _FlashSaleShimmer extends StatelessWidget {
  const _FlashSaleShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 12.h,
        bottom: 12.h,
      ),
      padding: EdgeInsets.only(
        top: 14.h,
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.home_header_background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _FlashSaleShimmerBox(
                  controller: controller,
                  width: 24.w,
                  height: 24.w,
                  radius: 6.r,
                ),
                SizedBox(width: 8.w),
                _FlashSaleShimmerBox(
                  controller: controller,
                  width: 100.w,
                  height: 18.h,
                  radius: 5.r,
                ),
                const Spacer(),
                _FlashSaleShimmerBox(
                  controller: controller,
                  width: 86.w,
                  height: 28.h,
                  radius: 8.r,
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Shimmer Product Cards
          SizedBox(
            height: 275.h,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  return _FlashSaleProductShimmerCard(
                    controller: controller,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Shimmer See All
          Center(
            child: _FlashSaleShimmerBox(
              controller: controller,
              width: 76.w,
              height: 13.h,
              radius: 5.r,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Product Card Skeleton
// --------------------------------------------------

class _FlashSaleProductShimmerCard extends StatelessWidget {
  const _FlashSaleProductShimmerCard({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          _FlashSaleShimmerBox(
            controller: controller,
            width: double.infinity,
            height: 125.h,
            radius: 9.r,
          ),

          SizedBox(height: 12.h),

          // Product title
          _FlashSaleShimmerBox(
            controller: controller,
            width: 125.w,
            height: 11.h,
            radius: 4.r,
          ),

          SizedBox(height: 7.h),

          _FlashSaleShimmerBox(
            controller: controller,
            width: 95.w,
            height: 11.h,
            radius: 4.r,
          ),

          const Spacer(),

          // Price
          Align(
            alignment: Alignment.centerLeft,
            child: _FlashSaleShimmerBox(
              controller: controller,
              width: 82.w,
              height: 15.h,
              radius: 4.r,
            ),
          ),

          SizedBox(height: 8.h),

          // Discount / old price
          _FlashSaleShimmerBox(
            controller: controller,
            width: 58.w,
            height: 10.h,
            radius: 4.r,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Animated Shimmer Box
// --------------------------------------------------

class _FlashSaleShimmerBox extends StatelessWidget {
  const _FlashSaleShimmerBox({
    required this.controller,
    required this.width,
    required this.height,
    required this.radius,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF303030)
        : const Color(0xFFE5E5E5);

    final highlightColor = isDark
        ? const Color(0xFF484848)
        : const Color(0xFFF7F7F7);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slide = (controller.value * 2) - 1;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(slide - 1, 0),
                end: Alignment(slide + 1, 0),
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: const [0.1, 0.5, 0.9],
              ).createShader(bounds);
            },
            child: Container(
              width: width,
              height: height,
              color: baseColor,
            ),
          ),
        );
      },
    );
  }
}
