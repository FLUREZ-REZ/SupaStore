
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/address_feature/presentation/pages/addresses_page.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/favorite_feature/presentation/pages/favorites_page.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';

import 'package:supastore/features/order_feature/presentation/pages/orders_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/order_provider.dart';

import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_header.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_menu_item.dart';

import 'package:supastore/features/settings_feature/presentation/pages/settings_page.dart';

// ==================================================================
// PROFILE PAGE
// ==================================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید',
          ),
        ),
      );
    }

    return ChangeNotifierProvider<OrderProvider>(
      create: (_) => getIt<OrderProvider>()
        ..loadOrders(user.id),
      child: _ProfileView(
        user: user,
      ),
    );
  }
}

// ==================================================================
// PROFILE VIEW
// ==================================================================

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final pendingCount = orderProvider.orders
        .where((order) => order.status == 'pending')
        .length;

    final processingCount = orderProvider.orders
        .where((order) => order.status == 'processing')
        .length;

    final shippedCount = orderProvider.orders
        .where((order) => order.status == 'shipped')
        .length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: AppBar(

          centerTitle: true,
          backgroundColor: AppColors.profile_page_redi,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: RefreshIndicator(
          color: AppColors.profile_page_redi,
          onRefresh: () async {
            await Future.wait([
              profileProvider.refreshProfile(
                userId: user.id,
              ),
              orderProvider.refreshOrders(user.id),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              bottom: 30.h,
            ),
            children: [
              // PROFILE HEADER + SHIMMER
              if (profileProvider.isLoading)
                const _ProfileHeaderShimmer()
              else
                ProfileHeader(
                  email: user.email ?? '',
                  userId: user.id,
                  profile: profileProvider.profile,
                ),

              SizedBox(height: 20.h),

              const _SectionTitle(
                title: 'سفارش‌های من',
              ),

              // ORDER STATUS + SHIMMER
              if (orderProvider.isLoading && orderProvider.orders.isEmpty)
                const _OrderStatusShimmer()
              else
                _OrderStatusSection(
                  pendingCount: pendingCount,
                  processingCount: processingCount,
                  shippedCount: shippedCount,
                ),

              SizedBox(height: 22.h),

              const _SectionTitle(
                title: 'حساب کاربری',
              ),

              _MenuContainer(
                children: [
                  ProfileMenuItem(
                    icon: Iconsax.user_edit_copy,
                    title: 'ویرایش پروفایل',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: profileProvider,
                            child: const EditProfilePage(),
                          ),
                        ),
                      );

                      if (!context.mounted) {
                        return;
                      }

                      await profileProvider.refreshProfile(
                        userId: user.id,
                      );
                    },
                  ),

                  const _MenuDivider(),

                  ProfileMenuItem(
                    icon: Iconsax.shopping_bag_copy,
                    title: 'همه سفارش‌ها',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrdersPage(),
                        ),
                      );
                    },
                  ),

                  const _MenuDivider(),

                  ProfileMenuItem(
                    icon: Iconsax.heart_copy,
                    title: 'علاقه‌مندی‌های من',
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),

                  const _MenuDivider(),

                  ProfileMenuItem(
                    icon: Iconsax.truck_copy,
                    title: 'سبد خرید',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 22.h),

              const _SectionTitle(
                title: 'تنظیمات',
              ),

              _MenuContainer(
                children: [
                  ProfileMenuItem(
                    icon: Iconsax.location_copy,
                    title: 'آدرس‌های من',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressesPage(),
                        ),
                      );
                    },
                  ),

                  const _MenuDivider(),

                  ProfileMenuItem(
                    icon: Iconsax.setting_2_copy,
                    title: 'تنظیمات',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 22.h),

              _MenuContainer(
                children: [
                  ProfileMenuItem(
                    icon: Iconsax.logout_copy,
                    title: 'خروج از حساب',
                    iconColor: Colors.red,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              Center(
                child: Text(
                  'Supastore',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

              SizedBox(height: 5.h),

              Center(
                child: Text(
                  'نسخه 1.0.0',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================================
  // LOGOUT CONFIRMATION
  // ==================================================================

  Future<void> _showLogoutDialog(
      BuildContext context,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161A1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          title: const Text(
            'خروج از حساب',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'خروج',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _logout(
      context,
      user.id,
    );
  }

  // ==================================================================
  // LOGOUT
  // ==================================================================

  Future<void> _logout(
      BuildContext context,
      String userId,
      ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      context.read<ProfileProvider>().clearProfile();

      getIt<FavoriteProvider>().clearFavorites();

      await getIt<CartProvider>().clearCart(userId);

      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();

      context.goNamed('auth');
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در خروج از حساب: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ==================================================================
// PROFILE HEADER SHIMMER
// ==================================================================

class _ProfileHeaderShimmer extends StatefulWidget {
  const _ProfileHeaderShimmer();

  @override
  State<_ProfileHeaderShimmer> createState() =>
      _ProfileHeaderShimmerState();
}

class _ProfileHeaderShimmerState extends State<_ProfileHeaderShimmer>
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
          margin: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            0,
          ),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFEDEDED),
            ),
          ),
          child: Row(
            children: [
              // AVATAR
              _ShimmerBox(
                animationValue: _controller.value,
                width: 64.w,
                height: 64.w,
                radius: 40.r,
              ),

              SizedBox(width: 14.w),

              // USER DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      animationValue: _controller.value,
                      width: 135.w,
                      height: 14.h,
                      radius: 5.r,
                    ),
                    SizedBox(height: 10.h),
                    _ShimmerBox(
                      animationValue: _controller.value,
                      width: 175.w,
                      height: 11.h,
                      radius: 5.r,
                    ),
                    SizedBox(height: 9.h),
                    _ShimmerBox(
                      animationValue: _controller.value,
                      width: 95.w,
                      height: 10.h,
                      radius: 5.r,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================================================================
// ORDER STATUS SHIMMER
// ==================================================================

class _OrderStatusShimmer extends StatefulWidget {
  const _OrderStatusShimmer();

  @override
  State<_OrderStatusShimmer> createState() =>
      _OrderStatusShimmerState();
}

class _OrderStatusShimmerState extends State<_OrderStatusShimmer>
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(
        vertical: 18.h,
        horizontal: 8.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            children: [
              Expanded(
                child: _OrderStatusShimmerItem(
                  animationValue: _controller.value,
                ),
              ),
              Container(
                width: 1,
                height: 65.h,
                color: const Color(0xFFEDEDED),
              ),
              Expanded(
                child: _OrderStatusShimmerItem(
                  animationValue: _controller.value,
                ),
              ),
              Container(
                width: 1,
                height: 65.h,
                color: const Color(0xFFEDEDED),
              ),
              Expanded(
                child: _OrderStatusShimmerItem(
                  animationValue: _controller.value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderStatusShimmerItem extends StatelessWidget {
  const _OrderStatusShimmerItem({
    required this.animationValue,
  });

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShimmerBox(
          animationValue: animationValue,
          width: 42.w,
          height: 42.w,
          radius: 30.r,
        ),
        SizedBox(height: 8.h),
        _ShimmerBox(
          animationValue: animationValue,
          width: 54.w,
          height: 10.h,
          radius: 5.r,
        ),
      ],
    );
  }
}

// ==================================================================
// REUSABLE SHIMMER BOX
// ==================================================================

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animationValue,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double animationValue;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(
            -1.5 + animationValue * 3,
            0,
          ),
          end: Alignment(
            -0.5 + animationValue * 3,
            0,
          ),
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.1, 0.5, 0.9],
        ),
      ),
    );
  }
}

// ==================================================================
// ORDER STATUS SECTION
// ==================================================================

class _OrderStatusSection extends StatelessWidget {
  const _OrderStatusSection({
    required this.pendingCount,
    required this.processingCount,
    required this.shippedCount,
  });

  final int pendingCount;
  final int processingCount;
  final int shippedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 18.h,
        horizontal: 8.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderStatusItem(
              count: pendingCount,
              title: 'در انتظار',
              icon: Iconsax.clock_copy,
              color: const Color(0xFFF59E0B),
              status: 'pending',
            ),
          ),
          Container(
            width: 1,
            height: 65.h,
            color: const Color(0xFFEDEDED),
          ),
          Expanded(
            child: _OrderStatusItem(
              count: processingCount,
              title: 'در حال پردازش',
              icon: Iconsax.box_copy,
              color: const Color(0xFF3B82F6),
              status: 'processing',
            ),
          ),
          Container(
            width: 1,
            height: 65.h,
            color: const Color(0xFFEDEDED),
          ),
          Expanded(
            child: _OrderStatusItem(
              count: shippedCount,
              title: 'ارسال شده',
              icon: Iconsax.truck_fast_copy,
              color: const Color(0xFF22C55E),
              status: 'shipped',
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ORDER STATUS ITEM
// ==================================================================

class _OrderStatusItem extends StatelessWidget {
  const _OrderStatusItem({
    required this.count,
    required this.title,
    required this.icon,
    required this.color,
    required this.status,
  });

  final int count;
  final String title;
  final IconData icon;
  final Color color;
  final String status;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrdersPage(
              initialStatus: status,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.10),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: color,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5.h,
                    right: -5.w,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// MENU CONTAINER
// ==================================================================

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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

// ==================================================================
// MENU DIVIDER
// ==================================================================

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 58.w,
      ),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF1F1F1),
      ),
    );
  }
}

// ==================================================================
// SECTION TITLE
// ==================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 20.w,
        bottom: 9.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF555555),
        ),
      ),
    );
  }
}
