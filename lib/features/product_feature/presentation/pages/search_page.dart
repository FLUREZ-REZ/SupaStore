import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/product_feature/presentation/providers/search_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_grid.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SearchProvider>(),
      child: const _SearchView(),
    );
  }
}

// ==================================================================
// SEARCH VIEW
// ==================================================================

class _SearchView extends StatelessWidget {
  const _SearchView();

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
            'جستجوی محصولات',
            style: AppTextStyles.second_title_section,
          ),
        ),

        // ==========================================================
        // BODY
        // ==========================================================

        body: Consumer<SearchProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Column(
              children: [
                // ==================================================
                // SEARCH FIELD
                // ==================================================

                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    autofocus: true,
                    onChanged: provider.search,
                    onSubmitted: (value) {
                      provider.addSearchHistory(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'نام محصول را وارد کنید...',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: Builder(
                    builder: (_) {
                      // =================================================
                      // INITIAL LOADING
                      // =================================================

                      if (provider.isLoading &&
                          provider.products.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // =================================================
                      // ERROR
                      // =================================================

                      if (provider.error != null &&
                          provider.products.isEmpty) {
                        return _ErrorView(
                          error: provider.error!,
                          onRetry: provider.refresh,
                        );
                      }

                      // =================================================
                      // EMPTY / HISTORY
                      // =================================================

                      if (provider.products.isEmpty) {
                        if (provider.history.isNotEmpty) {
                          return _SearchHistory(
                            provider: provider,
                          );
                        }

                        return const _EmptyView();
                      }

                      // =================================================
                      // PRODUCTS + PAGINATION
                      // =================================================

                      return Column(
                        children: [
                          // ===============================================
                          // PRODUCT GRID
                          // ===============================================

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

                          // ===============================================
                          // PAGINATION
                          // ===============================================

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
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==================================================================
// SEARCH HISTORY
// ==================================================================

class _SearchHistory extends StatelessWidget {
  const _SearchHistory({
    required this.provider,
  });

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            8.h,
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جستجوهای اخیر',
                style: AppTextStyles.productCard,
              ),
              TextButton(
                onPressed: provider.clearHistory,
                child: const Text(
                  'پاک کردن',
                ),
              ),
            ],
          ),
        ),

        ...provider.history.map(
              (item) {
            return ListTile(
              leading: const Icon(
                Icons.history,
              ),
              title: Text(
                item,
              ),
              onTap: () {
                provider.search(item);
              },
            );
          },
        ),
      ],
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

  final SearchProvider provider;

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
          // سمت راست صفحه
          // فلش راست = صفحه بعدی
          // ========================================================

          _PageButton(
            icon: Icons.chevron_right_rounded,
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
          // سمت چپ صفحه
          // فلش چپ = صفحه قبلی
          // ========================================================

          _PageButton(
            icon: Icons.chevron_left_rounded,
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
            Icons.search_off_rounded,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(
            height: 10.h,
          ),

          Text(
            'محصولی یافت نشد',
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