
import 'dart:async';

import 'package:flutter/material.dart';
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

class _CategoryHorizontalListState extends State<CategoryHorizontalList>
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
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth >= 1024 ? 1200 : double.infinity,
        ),
        child: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            final width = MediaQuery.sizeOf(context).width;

            final bool isMobile = width < 600;
            final bool isTablet = width >= 600 && width < 1024;
            final bool isDesktop = width >= 1024;

            final double listHeight = isMobile
                ? 112
                : isTablet
                ? 126
                : 140;

            final double horizontalPadding = isMobile
                ? 16
                : isTablet
                ? 24
                : 32;

            final double itemSpacing = isMobile
                ? 4
                : isTablet
                ? 12
                : 20;

            if (provider.isLoading || !_minimumShimmerFinished) {
              return _CategoryListShimmer(
                controller: _shimmerController,
                height: listHeight,
                horizontalPadding: horizontalPadding,
                itemSpacing: itemSpacing,
                isMobile: isMobile,
                isTablet: isTablet,
              );
            }

            if (provider.error != null) {
              return SizedBox(
                height: listHeight,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                height: listHeight,
                child: Center(
                  child: Text(
                    'دسته‌بندی‌ای وجود ندارد',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: listHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: isDesktop
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int index = 0;
                              index < provider.categories.length;
                              index++) ...[
                                CategoryItem(
                                  category: provider.categories[index],
                                  onTap: () {
                                    widget.onCategoryTap?.call(
                                      provider.categories[index],
                                    );
                                  },
                                ),
                                if (index !=
                                    provider.categories.length - 1)
                                  SizedBox(width: itemSpacing),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Category List Shimmer
// --------------------------------------------------

class _CategoryListShimmer extends StatelessWidget {
  const _CategoryListShimmer({
    required this.controller,
    required this.height,
    required this.horizontalPadding,
    required this.itemSpacing,
    required this.isMobile,
    required this.isTablet,
  });

  final AnimationController controller;
  final double height;
  final double horizontalPadding;
  final double itemSpacing;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double imageSize = isMobile
        ? 64
        : isTablet
        ? 72
        : 80;

    final double itemWidth = isMobile
        ? 76
        : isTablet
        ? 88
        : 96;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) => Padding(
                        padding: EdgeInsets.only(
                          left: index == 4 ? 0 : itemSpacing,
                        ),
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _ShimmerBox(
                                controller: controller,
                                width: imageSize,
                                height: imageSize,
                                radius: isMobile ? 18 : 20,
                              ),
                              const SizedBox(height: 8),
                              _ShimmerBox(
                                controller: controller,
                                width: itemWidth * 0.68,
                                height: 10,
                                radius: 5,
                              ),
                              const SizedBox(height: 5),
                              _ShimmerBox(
                                controller: controller,
                                width: itemWidth * 0.48,
                                height: 8,
                                radius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------
// Shimmer Box
// --------------------------------------------------

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
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color baseColor = isDark
        ? const Color(0xFF292929)
        : const Color(0xFFEAEAEA);

    final Color highlightColor = isDark
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
