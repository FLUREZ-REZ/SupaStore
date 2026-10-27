
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_item.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_summary.dart';
import 'package:supastore/features/order_feature/presentation/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartProvider _cartProvider;

  bool _minimumLoadingFinished = false;

  @override
  void initState() {
    super.initState();

    _cartProvider = getIt<CartProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    final stopwatch = Stopwatch()..start();

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        await _cartProvider.loadCart(user.id);
      }
    } finally {
      final elapsed = stopwatch.elapsed;
      const minimumDuration = Duration(seconds: 1);

      if (elapsed < minimumDuration) {
        await Future.delayed(minimumDuration - elapsed);
      }

      if (mounted) {
        setState(() {
          _minimumLoadingFinished = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: Center(
          child: Text('لطفاً ابتدا وارد حساب کاربری شوید'),
        ),
      );
    }

    return ChangeNotifierProvider<CartProvider>.value(
      value: _cartProvider,
      child: _CartView(
        minimumLoadingFinished: _minimumLoadingFinished,
      ),
    );
  }
}

class _CartView extends StatelessWidget {
  final bool minimumLoadingFinished;

  const _CartView({
    required this.minimumLoadingFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: AppColors.cart_page_redi,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'سبد خرید',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.cart_page_white,
          ),
        ),
      ),

      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          final showShimmer =
              provider.isLoading || !minimumLoadingFinished;

          if (showShimmer) {
            return const _CartShimmerList();
          }

          if (provider.error != null && provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }

          if (provider.items.isEmpty) {
            return const _EmptyCart();
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: 8.h,
              bottom: 20.h,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];

              return CartItem(
                item: item,
                onIncrease: () {
                  provider.increaseQuantity(item);
                },
                onDecrease: () {
                  provider.decreaseQuantity(item);
                },
                onRemove: () {
                  provider.removeFromCart(item.id);
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, provider, child) {
          final showShimmer =
              provider.isLoading || !minimumLoadingFinished;

          if (showShimmer) {
            return const _CartSummaryShimmer();
          }

          if (provider.isEmpty) {
            return const SizedBox.shrink();
          }

          return CartSummary(
            onCheckout: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    cartItems: provider.items,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------------------------------
// Cart list shimmer
// --------------------------------------------------

class _CartShimmerList extends StatefulWidget {
  const _CartShimmerList();

  @override
  State<_CartShimmerList> createState() => _CartShimmerListState();
}

class _CartShimmerListState extends State<_CartShimmerList>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 20.h,
          ),
          children: List.generate(
            4,
                (index) => _CartShimmerCard(
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _CartShimmerCard extends StatelessWidget {
  final double progress;

  const _CartShimmerCard({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(
            progress: progress,
            width: 100.w,
            height: 112.h,
            radius: 10.r,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),

                _ShimmerBlock(
                  progress: progress,
                  width: double.infinity,
                  height: 13.h,
                  radius: 5.r,
                ),

                SizedBox(height: 9.h),

                _ShimmerBlock(
                  progress: progress,
                  width: 125.w,
                  height: 11.h,
                  radius: 5.r,
                ),

                SizedBox(height: 17.h),

                _ShimmerBlock(
                  progress: progress,
                  width: 90.w,
                  height: 14.h,
                  radius: 5.r,
                ),

                SizedBox(height: 15.h),

                Row(
                  children: [
                    _ShimmerBlock(
                      progress: progress,
                      width: 27.w,
                      height: 27.w,
                      radius: 7.r,
                    ),

                    SizedBox(width: 8.w),

                    _ShimmerBlock(
                      progress: progress,
                      width: 20.w,
                      height: 13.h,
                      radius: 4.r,
                    ),

                    SizedBox(width: 8.w),

                    _ShimmerBlock(
                      progress: progress,
                      width: 27.w,
                      height: 27.w,
                      radius: 7.r,
                    ),

                    const Spacer(),

                    _ShimmerBlock(
                      progress: progress,
                      width: 25.w,
                      height: 25.w,
                      radius: 7.r,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Cart summary shimmer
// --------------------------------------------------

class _CartSummaryShimmer extends StatefulWidget {
  const _CartSummaryShimmer();

  @override
  State<_CartSummaryShimmer> createState() =>
      _CartSummaryShimmerState();
}

class _CartSummaryShimmerState extends State<_CartSummaryShimmer>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12.r,
                offset: Offset(0, -3.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 95.w,
                    height: 13.h,
                    radius: 5.r,
                  ),
                  const Spacer(),
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 105.w,
                    height: 13.h,
                    radius: 5.r,
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 75.w,
                    height: 12.h,
                    radius: 5.r,
                  ),
                  const Spacer(),
                  _ShimmerBlock(
                    progress: _controller.value,
                    width: 85.w,
                    height: 12.h,
                    radius: 5.r,
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              _ShimmerBlock(
                progress: _controller.value,
                width: double.infinity,
                height: 48.h,
                radius: 12.r,
              ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// Reusable shimmer block
// --------------------------------------------------

class _ShimmerBlock extends StatelessWidget {
  final double progress;
  final double width;
  final double height;
  final double radius;

  const _ShimmerBlock({
    required this.progress,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1.5 + (3 * progress), 0),
            end: Alignment(-0.5 + (3 * progress), 0),
            colors: const [
              Color(0xFFEAEAEA),
              Color(0xFFF8F8F8),
              Color(0xFFEAEAEA),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Empty cart
// --------------------------------------------------

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: AppColors.cart_page_redi,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Icon(
                Iconsax.shopping_cart_copy,
                size: 42.sp,
                color: AppColors.cart_page_white,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'سبد خرید شما خالی است',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'محصولات موردنظر خود را به سبد خرید اضافه کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
