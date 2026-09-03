import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

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

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),

        appBar: AppBar(
          backgroundColor: AppColors.orders_page_redi,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'جستجو',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        body: Consumer<SearchProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    12.h,
                    16.w,
                    8.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: provider.search,
                      onSubmitted: (value) {
                        provider.addSearchHistory(value);
                      },
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'جستجوی محصول...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22.sp,
                          color: Colors.grey.shade500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoading &&
                          provider.products.isEmpty) {
                        return const _SearchLoading();
                      }

                      if (provider.error != null &&
                          provider.products.isEmpty) {
                        return _ErrorView(
                          error: provider.error!,
                          onRetry: provider.refresh,
                        );
                      }

                      if (provider.products.isEmpty) {
                        if (provider.history.isNotEmpty) {
                          return _SearchHistory(
                            provider: provider,
                          );
                        }

                        return const _EmptyView();
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primary,
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

                          _Pagination(
                            provider: provider,
                          ),

                          SizedBox(
                            height: 8.h,
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

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 25.w,
        height: 25.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2.2,
        ),
      ),
    );
  }
}

class _SearchHistory extends StatelessWidget {
  const _SearchHistory({
    required this.provider,
  });

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 8.h,
        bottom: 20.h,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 8.h,
          ),
          child: Row(
            children: [
              Text(
                'جستجوهای اخیر',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: provider.clearHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'پاک کردن',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        ...provider.history.map(
              (item) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 3.h,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: () {
                    provider.search(item);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 13.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius:
                            BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 18.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Icon(
                          Icons.north_west_rounded,
                          size: 17.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

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
        vertical: 6.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled:
            provider.hasNextPage &&
                !provider.isLoading,
            onTap: provider.nextPage,
          ),

          SizedBox(width: 10.w),

          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Text(
              '$currentPage',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled:
            provider.hasPreviousPage &&
                !provider.isLoading,
            onTap: provider.previousPage,
          ),

          if (provider.isLoading) ...[
            SizedBox(width: 10.w),

            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
      color: Colors.white,
      borderRadius: BorderRadius.circular(11.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: enabled
                  ? Colors.grey.shade200
                  : Colors.grey.shade100,
            ),
          ),
          child: Icon(
            icon,
            size: 22.sp,
            color: enabled
                ? Colors.black87
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

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
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32.sp,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 14.h),

            Text(
              'مشکلی پیش آمده',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            SizedBox(height: 14.h),

            TextButton(
              onPressed: onRetry,
              child: Text(
                'تلاش مجدد',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82.w,
              height: 82.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 38.sp,
                color: Colors.grey.shade400,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              'محصولی یافت نشد',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              'عبارت دیگری را برای جستجو امتحان کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}