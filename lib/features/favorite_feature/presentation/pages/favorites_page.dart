
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لطفاً ابتدا وارد حساب کاربری شوید'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => getIt<FavoriteProvider>()
        ..loadFavorites(userId: user.id),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.favorite_page_redi,
          foregroundColor: Colors.white,
          title: const Text('علاقه‌مندی‌های من'),
          centerTitle: true,
        ),
        body: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      FavoriteProvider provider,
      ) {
    if (provider.isLoading) {
      return const _FavoritesShimmer();
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 55.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  final user =
                      Supabase.instance.client.auth.currentUser;

                  if (user == null) return;

                  provider.loadFavorites(userId: user.id);
                },
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.favoriteProducts.isEmpty) {
      return const _EmptyFavorites();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = Supabase.instance.client.auth.currentUser;

        if (user == null) return;

        await provider.loadFavorites(userId: user.id);
      },
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          30.h,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.48,
        ),
        itemCount: provider.favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = provider.favoriteProducts[index];

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
                  Supabase.instance.client.auth.currentUser;

              if (user == null) return;

              await provider.toggleFavorite(
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

// ---------------------------------------------------------
// Favorites shimmer
// ---------------------------------------------------------

class _FavoritesShimmer extends StatefulWidget {
  const _FavoritesShimmer();

  @override
  State<_FavoritesShimmer> createState() => _FavoritesShimmerState();
}

class _FavoritesShimmerState extends State<_FavoritesShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            30.h,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.48,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _FavoriteProductShimmer(
              animationValue: _animation.value,
            );
          },
        );
      },
    );
  }
}

class _FavoriteProductShimmer extends StatelessWidget {
  final double animationValue;

  const _FavoriteProductShimmer({
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(9.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تصویر محصول
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: double.infinity,
                  child: _ShimmerBox(
                    animationValue: animationValue,
                    height: double.infinity,
                    radius: 10.r,
                  )
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // عنوان محصول
            _ShimmerBox(
              animationValue: animationValue,
              width: double.infinity,
              height: 12.h,
              radius: 5.r,
            ),

            SizedBox(height: 7.h),

            _ShimmerBox(
              animationValue: animationValue,
              width: 0.72.sw,
              height: 10.h,
              radius: 5.r,
            ),

            const Spacer(),

            // امتیاز یا توضیح کوتاه
            _ShimmerBox(
              animationValue: animationValue,
              width: 65.w,
              height: 10.h,
              radius: 5.r,
            ),

            SizedBox(height: 10.h),

            // قیمت محصول
            Row(
              children: [
                Expanded(
                  child: _ShimmerBox(
                    animationValue: animationValue,
                    height: 15.h,
                    radius: 5.r,
                  ),
                ),
                SizedBox(width: 8.w),
                _ShimmerBox(
                  animationValue: animationValue,
                  width: 30.w,
                  height: 20.h,
                  radius: 6.r,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // فضای دکمه یا اطلاعات پایانی کارت
            _ShimmerBox(
              animationValue: animationValue,
              width: 85.w,
              height: 9.h,
              radius: 5.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double animationValue;
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.animationValue,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(animationValue - 1, 0),
          end: Alignment(animationValue, 0),
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Empty favorites
// ---------------------------------------------------------

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.heart_copy,
                size: 60.sp,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'هنوز محصولی را به علاقه‌مندی‌ها اضافه نکرده‌اید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'محصولات مورد علاقه خود را با زدن قلب ذخیره کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('بازگشت به فروشگاه'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
