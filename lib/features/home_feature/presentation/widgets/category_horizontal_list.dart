
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';

import 'category_item.dart';

class CategoryHorizontalList extends StatefulWidget {
  const CategoryHorizontalList({
    super.key,
    this.onCategoryTap,
  });

  final Function(CategoryEntity category)? onCategoryTap;

  @override
  State<CategoryHorizontalList> createState() =>
      _CategoryHorizontalListState();
}

class _CategoryHorizontalListState
    extends State<CategoryHorizontalList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  Timer? _minimumShimmerTimer;

  bool _minimumShimmerFinished = false;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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

      context.read<CategoryProvider>().loadCategories();
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
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        // شیمر در بارگذاری اولیه حداقل ۲ ثانیه نمایش داده می‌شود.
        if (provider.isLoading || !_minimumShimmerFinished) {
          return _CategoryListShimmer(
            controller: _shimmerController,
          );
        }

        if (provider.error != null) {
          return SizedBox(
            height: 110.h,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CategoryProvider>()
                            .loadCategories();
                      },
                      child: const Text('تلاش مجدد'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return SizedBox(
            height: 110.h,
            child: Center(
              child: Text(
                'دسته‌بندی‌ای وجود ندارد',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 110.h,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final category = provider.categories[index];

                return CategoryItem(
                  category: category,
                  onTap: () {
                    widget.onCategoryTap?.call(category);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// -------------------- Category List Shimmer --------------------

class _CategoryListShimmer extends StatelessWidget {
  const _CategoryListShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(width: 2.w),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 76.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    controller: controller,
                    width: 64.w,
                    height: 64.w,
                    radius: 18.r,
                  ),
                  SizedBox(height: 8.h),
                  _ShimmerBox(
                    controller: controller,
                    width: 52.w,
                    height: 10.h,
                    radius: 5.r,
                  ),
                  SizedBox(height: 5.h),
                  _ShimmerBox(
                    controller: controller,
                    width: 38.w,
                    height: 8.h,
                    radius: 5.r,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- Shimmer Box --------------------

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
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
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF292929)
        : const Color(0xFFEAEAEA);

    final highlightColor =
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF414141)
        : const Color(0xFFF7F7F7);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              final slide = controller.value * 2 - 1;

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
