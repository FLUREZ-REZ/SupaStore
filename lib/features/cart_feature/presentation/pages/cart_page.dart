import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_item.dart';
import 'package:supastore/features/cart_feature/presentation/widgets/cart_summary.dart';
import 'package:supastore/features/order_feature/presentation/pages/checkout_page.dart';

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
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
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
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: AppColors.cart_page_redi ,
        surfaceTintColor: Colors.transparent,
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
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
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

      bottomNavigationBar:
      Consumer<CartProvider>(
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32.w,
        ),
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
                Icons.shopping_cart_outlined,
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