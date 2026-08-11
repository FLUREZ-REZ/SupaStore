import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';

import 'package:supastore/features/product_feature/presentation/widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید',
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
      getIt<FavoriteProvider>()
        ..loadFavorites(
          userId: user.id,
        ),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView
    extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<FavoriteProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'علاقه‌مندی‌های من',
          ),
          centerTitle: true,
        ),
        body: _buildBody(
          context,
          provider,
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      FavoriteProvider provider,
      ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 55.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                provider.error!,
                textAlign:
                TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  final user =
                      Supabase
                          .instance
                          .client
                          .auth
                          .currentUser;

                  if (user == null) {
                    return;
                  }

                  provider.loadFavorites(
                    userId: user.id,
                  );
                },
                child: const Text(
                  'تلاش مجدد',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.favoriteProducts
        .isEmpty) {
      return const _EmptyFavorites();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user =
            Supabase.instance.client.auth
                .currentUser;

        if (user == null) {
          return;
        }

        await provider.loadFavorites(
          userId: user.id,
        );
      },
      child: GridView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(
          parent:
          BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          30.h,
        ),
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.68,
        ),
        itemCount:
        provider.favoriteProducts
            .length,
        itemBuilder: (
            context,
            index,
            ) {
          final product =
          provider.favoriteProducts[
          index];

          return ProductCard(
            product: product,
            onTap: () {
              context.pushNamed(
                'product-details',
                extra: product,
              );
            },
            onFavorite: () async {
              final user =
                  Supabase.instance.client
                      .auth.currentUser;

              if (user == null) {
                return;
              }

              await provider
                  .toggleFavorite(
                userId: user.id,
                productId: product.id,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites
    extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration:
              BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60.sp,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'هنوز محصولی را به علاقه‌مندی‌ها اضافه نکرده‌اید',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'محصولات مورد علاقه خود را با زدن قلب ذخیره کنید.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:
                Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 180.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12.r,
                    ),
                  ),
                ),
                child: const Text(
                  'بازگشت به فروشگاه',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}