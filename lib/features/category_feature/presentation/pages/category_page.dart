import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/category_feature/presentation/providers/category_product_provider.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';

import 'package:supastore/features/product_feature/presentation/widgets/product_grid.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<CategoryProductProvider>()
        ..loadProducts(
          categoryId: category.id,
        ),
      child: _CategoryView(
        category: category,
      ),
    );
  }
}

// ==================================================================
// CATEGORY VIEW
// ==================================================================

class _CategoryView extends StatelessWidget {
  const _CategoryView({
    required this.category,
  });

  final CategoryEntity category;

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
            category.name,
            style: AppTextStyles.second_title_section,
          ),
        ),

        // ==========================================================
        // BODY
        // ==========================================================

        body: Consumer<CategoryProductProvider>(
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
                onRetry: () {
                  provider.loadProducts(
                    categoryId: category.id,
                  );
                },
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
                        // را بعداً اینجا وصل می‌کنیم.
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

  final CategoryProductProvider provider;

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
          // PREVIOUS
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

          SizedBox(
            width: 12.w,
          ),

          // ========================================================
          // CURRENT PAGE
          // ========================================================

          Container(
            height: 32.h,
            constraints: BoxConstraints(
              minWidth: 32.w,
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

          SizedBox(
            width: 12.w,
          ),

          // ========================================================
          // NEXT
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
          ? Colors.white
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(9.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            icon,
            size: 18.sp,
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
            Icons.inventory_2_outlined,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'محصولی در این دسته وجود ندارد',
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