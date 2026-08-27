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
  State<FlashSaleSection> createState() =>
      _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<FlashSaleProvider>()
          .fetchFlashSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashSaleProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // ─────────────────────────────────────
        // Loading
        // ─────────────────────────────────────

        if (provider.isLoading) {
          return SizedBox(
            height: 320.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ─────────────────────────────────────
        // Error
        // ─────────────────────────────────────

        if (provider.errorMessage != null) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Text(
                provider.errorMessage!,
              ),
            ),
          );
        }

        // ─────────────────────────────────────
        // Empty
        // ─────────────────────────────────────

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
              // ─────────────────────────────────
              // Header
              // ─────────────────────────────────

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
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
                    FlashSaleCountdown(
                      endAt: endAt,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ─────────────────────────────────
              // Products
              // ─────────────────────────────────

              SizedBox(
                height: 275.h,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                    ),
                    itemCount: provider.items.length,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final item = provider.items[index];

                      return FlashSaleProductCard(
                        item: item,
                        onTap: () {
                          widget.onProductTap?.call(
                            item.product,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // ─────────────────────────────────
              // See All
              // ─────────────────────────────────

              if (widget.onSeeAll != null)
                Center(
                  child: GestureDetector(
                    onTap: widget.onSeeAll,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                      ),
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