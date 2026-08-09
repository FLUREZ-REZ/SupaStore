import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_item.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_summary.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartProvider _cartProvider;

  @override
  void initState() {
    super.initState();

    _cartProvider = getIt<CartProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          Supabase.instance.client.auth.currentUser;

      if (user != null) {
        _cartProvider.loadCart(user.id);
      }
    });
  }

  @override
  void dispose() {
    _cartProvider.dispose();
    super.dispose();
  }

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

    return ChangeNotifierProvider.value(
      value: _cartProvider,
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سبد خرید',
        ),
        centerTitle: true,
      ),

      body: Consumer<CartProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null &&
              provider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.items.isEmpty) {
            return const _EmptyCart();
          }

          return ListView.builder(
            physics:
            const BouncingScrollPhysics(),

            padding: EdgeInsets.only(
              top: 8.h,
              bottom: 20.h,
            ),

            itemCount:
            provider.items.length,

            itemBuilder: (
                context,
                index,
                ) {
              final item =
              provider.items[index];

              return CartItem(
                item: item,

                onIncrease: () {
                  provider.increaseQuantity(
                    item,
                  );
                },

                onDecrease: () {
                  provider.decreaseQuantity(
                    item,
                  );
                },

                onRemove: () {
                  provider.removeFromCart(
                    item.id,
                  );
                },
              );
            },
          );
        },
      ),

      /// خلاصه سفارش همیشه پایین صفحه
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoading ||
              provider.isEmpty) {
            return const SizedBox.shrink();
          }

          return CartSummary(
            onCheckout: () {
              // بعداً صفحه Checkout
              // اینجا باز می‌شود.
            },
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

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
            Icon(
              Icons.shopping_cart_outlined,
              size: 80.sp,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: 18.h),

            Text(
              'سبد خرید شما خالی است',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'محصولات موردنظر خود را به سبد خرید اضافه کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}