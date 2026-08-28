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

class FlashSalePage extends StatelessWidget {
  const FlashSalePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      getIt<FlashSaleProvider>()
        ..fetchFlashSales(),

      child: const _FlashSaleView(),
    );
  }
}

// ==================================================================
// FLASH SALE VIEW
// ==================================================================

class _FlashSaleView extends StatelessWidget {
  const _FlashSaleView();

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
            // INITIAL LOADING
            // ======================================================

            if (provider.isLoading &&
                provider.items.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ======================================================
            // ERROR
            // ======================================================

            if (provider.errorMessage != null &&
                provider.items.isEmpty) {
              return _ErrorView(
                error: provider.errorMessage!,

                onRetry: () {
                  provider.fetchFlashSales();
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
                // ==================================================
                // FLASH SALE GRID
                // ==================================================

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
                        // FavoriteProvider
                        // در کارت مدیریت می‌شود.
                      },
                    ),
                  ),
                ),

                // ==================================================
                // PAGINATION
                // ==================================================

                _Pagination(
                  provider: provider,
                ),

                SizedBox(
                  height: 10.h,
                ),
              ],
            );
          },
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
    final currentPage =
        provider.currentPage + 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 8.h,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          // ========================================================
          // NEXT
          //
          // فلش راست = صفحه بعد
          // ========================================================

          _PageButton(
            icon: Icons.chevron_right_rounded,

            enabled:
            provider.hasNextPage &&
                !provider.isLoading,

            onTap: () {
              provider.nextPage();
            },
          ),

          SizedBox(
            width: 12.w,
          ),

          // ========================================================
          // CURRENT PAGE
          // ========================================================

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

              borderRadius:
              BorderRadius.circular(9.r),
            ),

            child: Text(
              '$currentPage',

              style: TextStyle(
                fontSize: 12.sp,
                fontWeight:
                FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(
            width: 12.w,
          ),

          // ========================================================
          // PREVIOUS
          //
          // فلش چپ = صفحه قبل
          // ========================================================

          _PageButton(
            icon: Icons.chevron_left_rounded,

            enabled:
            provider.hasPreviousPage &&
                !provider.isLoading,

            onTap: () {
              provider.previousPage();
            },
          ),

          // ========================================================
          // LOADING
          // ========================================================

          if (provider.isLoading) ...[
            SizedBox(
              width: 10.w,
            ),

            SizedBox(
              width: 14.w,
              height: 14.w,

              child:
              const CircularProgressIndicator(
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

      borderRadius:
      BorderRadius.circular(9.r),

      child: InkWell(
        onTap: enabled
            ? onTap
            : null,

        borderRadius:
        BorderRadius.circular(9.r),

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
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44.sp,
              color: Colors.grey.shade500,
            ),

            SizedBox(
              height: 12.h,
            ),

            Text(
              error,

              textAlign:
              TextAlign.center,

              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
            ),

            SizedBox(
              height: 16.h,
            ),

            TextButton(
              onPressed: onRetry,

              child: const Text(
                'تلاش مجدد',
              ),
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
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'در حال حاضر محصول شگفت‌انگیزی وجود ندارد',

            textAlign:
            TextAlign.center,

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