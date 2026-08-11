import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/favorite_feature/presentation/pages/favorites_page.dart';
import 'package:supastore/features/order_feature/presentation/pages/orders_page.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const _NotLoggedInView();
    }

    final email = user.email ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'پروفایل',
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 30.h,
          ),
          children: [
            // ============================================================
            // PROFILE HEADER
            // ============================================================

            ProfileHeader(
              email: email,
              userId: user.id,
            ),

            // ============================================================
            // ACCOUNT
            // ============================================================

            const _SectionTitle(
              title: 'حساب کاربری',
            ),

            _MenuContainer(
              children: [
                // ========================================================
                // ORDERS
                // ========================================================

                ProfileMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'سفارش‌های من',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OrdersPage(),
                      ),
                    );
                  },
                ),

                // ========================================================
                // FAVORITES
                // ========================================================

                ProfileMenuItem(
                  icon: Icons.favorite_border,
                  title: 'علاقه‌مندی‌های من',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoritesPage(),
                      ),
                    );
                  },
                ),

                // ========================================================
                // CART
                // ========================================================

                ProfileMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'سبد خرید',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CartPage(),
                      ),
                    );
                  },
                  showDivider: false,
                ),
              ],
            ),

            // ============================================================
            // SETTINGS
            // ============================================================

            const _SectionTitle(
              title: 'تنظیمات',
            ),

            _MenuContainer(
              children: [
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'تنظیمات',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'بخش تنظیمات به‌زودی اضافه می‌شود',
                        ),
                      ),
                    );
                  },
                  showDivider: false,
                ),
              ],
            ),

            // ============================================================
            // ACCOUNT
            // ============================================================

            const _SectionTitle(
              title: 'حساب',
            ),

            _MenuContainer(
              children: [
                ProfileMenuItem(
                  icon: Icons.logout_outlined,
                  title: 'خروج از حساب',
                  iconColor: Colors.red,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  showDivider: false,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ============================================================
            // VERSION
            // ============================================================

            Center(
              child: Text(
                'نسخه 1.0.0',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'خروج از حساب',
            ),
            content: const Text(
              'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'انصراف',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  await _logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'خروج',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در خروج از حساب: $e',
          ),
        ),
      );
    }
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18.w,
        18.h,
        18.w,
        8.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ============================================================
// MENU CONTAINER
// ============================================================

class _MenuContainer extends StatelessWidget {
  const _MenuContainer({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ============================================================
// NOT LOGGED IN
// ============================================================

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'پروفایل',
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),

                SizedBox(height: 16.h),

                Text(
                  'وارد حساب کاربری خود شوید',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'برای مشاهده سفارش‌ها، علاقه‌مندی‌ها و اطلاعات حساب خود ابتدا وارد شوید.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: const Text(
                      'ورود به حساب',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}