import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/product_feature/presentation/providers/popular_products_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_grid.dart';

class PopularProductsPage extends StatelessWidget {
  const PopularProductsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<PopularProductsProvider>()
        ..loadProducts(),
      child: const _PopularProductsView(),
    );
  }
}

// ==================================================================
// POPULAR PRODUCTS VIEW
// ==================================================================

class _PopularProductsView extends StatelessWidget {
  const _PopularProductsView();

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
            'پرفروش‌ترین محصولات',
            style: AppTextStyles.second_title_section,
          ),
        ),

        // ==========================================================
        // BODY
        // ==========================================================

        body: Consumer<PopularProductsProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            // ======================================================
            // INITIAL LOADING
            // ======================================================

            if (provider.isLoading &&
                provider.products.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ======================================================
            // ERROR
            // ======================================================

            if (provider.error != null &&
                provider.products.isEmpty) {
              return _ErrorView(
                error: provider.error!,
                onRetry: provider.loadProducts,
              );
            }

            // ======================================================
            // EMPTY
            // ======================================================

            if (provider.products.isEmpty) {
              return const _EmptyView();
            }

            // ======================================================
            // PRODUCTS + PAGINATION
            // ======================================================

            return Column(
              children: [
                // ==================================================
                // PRODUCT GRID
                // ==================================================

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: ProductGrid(
                      products: provider.products,

                      onProductTap: (product) {
                        context.pushNamed(
                          'product-details',
                          extra: product,
                        );
                      },

                      onFavoriteTap: (product) {
                        // FavoriteProvider
                        // بعداً اینجا وصل می‌کنیم.
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

  final PopularProductsProvider provider;

  @override
  Widget build(BuildContext context) {
    final currentPage = provider.page + 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ========================================================
          // NEXT
          //
          // سمت راست
          // فلش راست = صفحه بعدی
          // ========================================================

          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled:
            provider.hasNextPage &&
                !provider.isLoading,
            onTap: provider.nextPage,
          ),

          SizedBox(
            width: 12.w,
          ),

          // ========================================================
          // CURRENT PAGE
          // ========================================================

          Container(
            height: 40.h,
            constraints: BoxConstraints(
              minWidth: 40.w,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
              BorderRadius.circular(10.r),
            ),
            child: Text(
              '$currentPage',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
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
          // سمت چپ
          // فلش چپ = صفحه قبلی
          // ========================================================

          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled:
            provider.hasPreviousPage &&
                !provider.isLoading,
            onTap: provider.previousPage,
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
          ? AppColors.primary.withValues(
        alpha: 0.08,
      )
          : Colors.grey.shade100,
      borderRadius:
      BorderRadius.circular(10.r),
      child: InkWell(
        onTap: enabled
            ? onTap
            : null,
        borderRadius:
        BorderRadius.circular(10.r),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(
            icon,
            size: 22.sp,
            color: enabled
                ? AppColors.primary
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
  final Future<void> Function() onRetry;

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

            SizedBox(
              height: 12.h,
            ),

            Text(
              error,
              textAlign: TextAlign.center,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'محصولی برای نمایش وجود ندارد',
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