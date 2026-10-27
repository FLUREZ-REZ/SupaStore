import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/flash_sale_feature/presentation/providers/flash_sale_provider.dart';
import 'package:supastore/features/flash_sale_feature/presentation/widgets/flash_sale_product_grid.dart';

// ==================================================================
// FLASH SALE PAGE
// ==================================================================

class FlashSalePage extends StatelessWidget {
  const FlashSalePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FlashSaleProvider>(
      create: (_) => getIt<FlashSaleProvider>()
        ..fetchFlashSales(),
      child: const _FlashSaleView(),
    );
  }
}

// ==================================================================
// FLASH SALE VIEW
// ==================================================================

class _FlashSaleView extends StatefulWidget {
  const _FlashSaleView();

  @override
  State<_FlashSaleView> createState() => _FlashSaleViewState();
}

class _FlashSaleViewState extends State<_FlashSaleView> {
  bool _minimumLoadingFinished = false;

  @override
  void initState() {
    super.initState();


    Future<void>.delayed(
      const Duration(seconds: 1),
          () {
        if (!mounted) return;

        setState(() {
          _minimumLoadingFinished = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        // ==========================================================
        // APP BAR
        // ==========================================================

        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'شگفت‌انگیزها',
            style: AppTextStyles.second_title_section,
          ),
        ),

        // ==========================================================
        // BODY
        // ==========================================================

        body: Consumer<FlashSaleProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            // ======================================================
            // INITIAL SHIMMER
            //
            // شیمری حداقل ۲ ثانیه نمایش داده می‌شود.
            // اگر دریافت اطلاعات بیشتر طول بکشد، تا پایان آن
            // نمایش شیمری ادامه پیدا می‌کند.
            // ======================================================

            if (provider.items.isEmpty &&
                (!_minimumLoadingFinished || provider.isLoading)) {
              return const _FlashSaleShimmer();
            }

            // ======================================================
            // ERROR
            // ======================================================

            if (provider.errorMessage != null &&
                provider.items.isEmpty) {
              return _ErrorView(
                error: provider.errorMessage!,
                onRetry: () async {
                  // برای تلاش مجدد نیز حداقل زمان شیمری را اعمال کن.
                  setState(() {
                    _minimumLoadingFinished = false;
                  });

                  final stopwatch = Stopwatch()..start();

                  try {
                    await provider.fetchFlashSales();
                  } finally {
                    const minimumDuration = Duration(seconds: 2);
                    final remaining =
                        minimumDuration - stopwatch.elapsed;

                    if (remaining > Duration.zero) {
                      await Future<void>.delayed(remaining);
                    }

                    if (mounted) {
                      setState(() {
                        _minimumLoadingFinished = true;
                      });
                    }
                  }
                },
              );
            }

            // ======================================================
            // EMPTY
            // ======================================================

            if (provider.items.isEmpty) {
              return const _EmptyView();
            }

            // ======================================================
            // PRODUCTS + PAGINATION
            // ======================================================

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: FlashSaleProductGrid(
                      products: provider.items,
                      onProductTap: (
                          FlashSaleProductEntity item,
                          ) {
                        context.pushNamed(
                          'product-details',
                          extra: item.product,
                        );
                      },
                      onFavoriteTap: (
                          FlashSaleProductEntity item,
                          ) {
                        // مدیریت علاقه‌مندی در کارت محصول انجام می‌شود.
                      },
                    ),
                  ),
                ),

                // PAGINATION

                _Pagination(
                  provider: provider,
                ),

                SizedBox(height: 10.h),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==================================================================
// FLASH SALE SHIMMER
// ==================================================================

class _FlashSaleShimmer extends StatefulWidget {
  const _FlashSaleShimmer();

  @override
  State<_FlashSaleShimmer> createState() => _FlashSaleShimmerState();
}

class _FlashSaleShimmerState extends State<_FlashSaleShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        12.w,
        14.h,
        12.w,
        20.h,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.57,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFF0F0F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PLACEHOLDER

              Expanded(
                flex: 6,
                child: SizedBox(
                  width: double.infinity,
                  child: _ShimmerBlock(
                    controller: _controller,
                    radius: 12.r,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // PRODUCT TITLE

              _ShimmerLine(
                controller: _controller,
                width: 0.90,
                height: 12.h,
              ),

              SizedBox(height: 8.h),

              _ShimmerLine(
                controller: _controller,
                width: 0.68,
                height: 12.h,
              ),

              const Spacer(),

              // OLD PRICE

              _ShimmerLine(
                controller: _controller,
                width: 0.48,
                height: 10.h,
              ),

              SizedBox(height: 8.h),

              // DISCOUNTED PRICE

              _ShimmerLine(
                controller: _controller,
                width: 0.75,
                height: 15.h,
              ),

              SizedBox(height: 10.h),

              // BOTTOM BUTTON / ACTION

              _ShimmerLine(
                controller: _controller,
                width: 1,
                height: 30.h,
                radius: 8.r,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================================================================
// SHIMMER BLOCK
// ==================================================================

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.controller,
    this.radius = 8,
  });

  final AnimationController controller;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(
                -1.5 + 3 * controller.value,
                0,
              ),
              end: Alignment(
                -0.5 + 3 * controller.value,
                0,
              ),
              colors: const [
                Color(0xFFEAEAEA),
                Color(0xFFF8F8F8),
                Color(0xFFEAEAEA),
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

// ==================================================================
// SHIMMER LINE
// ==================================================================

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.controller,
    required this.width,
    required this.height,
    this.radius = 5,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: height,
        child: _ShimmerBlock(
          controller: controller,
          radius: radius,
        ),
      ),
    );
  }
}

// ==================================================================
// PAGINATION
// ==================================================================

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.provider,
  });

  final FlashSaleProvider provider;

  @override
  Widget build(BuildContext context) {
    final currentPage = provider.currentPage + 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // NEXT

          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled: provider.hasNextPage && !provider.isLoading,
            onTap: () {
              provider.nextPage();
            },
          ),

          SizedBox(width: 12.w),

          // CURRENT PAGE

          Container(
            height: 34.h,
            constraints: BoxConstraints(
              minWidth: 34.w,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '$currentPage',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // PREVIOUS

          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled: provider.hasPreviousPage &&
                !provider.isLoading,
            onTap: () {
              provider.previousPage();
            },
          ),

          // PAGINATION LOADING

          if (provider.isLoading) ...[
            SizedBox(width: 10.w),
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: const CircularProgressIndicator(
                strokeWidth: 1.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================================================================
// PAGE BUTTON
// ==================================================================

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? Colors.white
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(9.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9.r),
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: enabled
                ? Colors.grey.shade800
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR VIEW
// ==================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44.sp,
              color: Colors.grey.shade500,
            ),

            SizedBox(height: 12.h),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
            ),

            SizedBox(height: 16.h),

            TextButton(
              onPressed: onRetry,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY VIEW
// ==================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 10.h),

          Text(
            'در حال حاضر محصول شگفت‌انگیزی وجود ندارد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}