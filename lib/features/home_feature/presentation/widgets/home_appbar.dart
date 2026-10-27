
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/notification_feature/presentation/pages/notifications_page.dart';
import 'package:supastore/features/notification_feature/presentation/providers/notifications_provider.dart';

import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  bool _minimumShimmerFinished = false;
  late final AnimationController _shimmerController;
  Timer? _minimumShimmerTimer;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Minimum shimmer duration: 2 seconds.
    _minimumShimmerTimer = Timer(
      const Duration(seconds: 1),
          () {
        if (!mounted) return;

        setState(() {
          _minimumShimmerFinished = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _minimumShimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN EDIT PROFILE
  // ============================================================

  Future<void> _openEditProfile(BuildContext context) async {
    final provider = context.read<ProfileProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ProfileProvider>.value(
          value: provider,
          child: const EditProfilePage(),
        ),
      ),
    );
  }

  // ============================================================
  // OPEN CART
  // ============================================================

  Future<void> _openCart(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CartPage(),
      ),
    );
  }

  // ============================================================
  // OPEN NOTIFICATIONS
  // ============================================================

  Future<void> _openNotifications(BuildContext context) async {
    final notificationProvider = getIt<NotificationsProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        ChangeNotifierProvider<NotificationsProvider>.value(
          value: notificationProvider,
          child: const NotificationsPage(),
        ),
      ),
    );

    if (!context.mounted) return;

    await notificationProvider.loadNotifications();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    final cartProvider = context.watch<CartProvider>();
    final cartCount = cartProvider.totalItems;

    // Show shimmer for at least 2 seconds, and longer if loading continues.
    final showProfileShimmer = !_minimumShimmerFinished ||
        (profileProvider.isLoading && profile == null);

    String title;
    String subtitle;

    if (profileProvider.isLoading && profile == null) {
      title = 'کاربر';
      subtitle = 'در حال دریافت اطلاعات...';
    } else {
      final fullName = profile?.fullName?.trim();
      final phone = profile?.phone?.trim() ?? user?.phone?.trim();

      if (fullName != null && fullName.isNotEmpty) {
        title = fullName;
        subtitle = phone?.isNotEmpty == true ? phone! : 'ویرایش پروفایل';
      } else {
        title = 'کاربر';
        subtitle = phone?.isNotEmpty == true ? phone! : 'ویرایش پروفایل';
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.home_header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          10.h,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // USER AVATAR
              _UserAvatar(
                isLoading: showProfileShimmer,
                shimmerController: _shimmerController,
                onTap: () => _openEditProfile(context),
              ),

              SizedBox(width: 10.w),

              // USER INFORMATION
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => _openEditProfile(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: showProfileShimmer
                          ? _UserInfoShimmer(
                        controller: _shimmerController,
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.user.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.userName.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // NOTIFICATIONS
              Consumer<NotificationsProvider>(
                builder: (context, notificationProvider, child) {
                  return _NotificationIconButton(
                    count: notificationProvider.unreadCount,
                    onTap: () => _openNotifications(context),
                  );
                },
              ),

              SizedBox(width: 8.w),

              // CART
              _CartIconButton(
                count: cartCount,
                onTap: () => _openCart(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SHIMMER EFFECT
// ================================================================

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.controller,
    this.width,
    this.height,
    this.radius = 8,
  });

  final AnimationController controller;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value * 2 - 1;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(progress - 1, 0),
              end: Alignment(progress + 1, 0),
              colors: [
                const Color(0xFFE5E5E5),
                const Color(0xFFF8F8F8),
                const Color(0xFFE5E5E5),
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(radius.r),
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// USER INFORMATION SHIMMER
// ================================================================

class _UserInfoShimmer extends StatelessWidget {
  const _UserInfoShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShimmerBlock(
          controller: controller,
          width: 95.w,
          height: 13.h,
          radius: 4,
        ),
        SizedBox(height: 7.h),
        _ShimmerBlock(
          controller: controller,
          width: 115.w,
          height: 9.h,
          radius: 4,
        ),
      ],
    );
  }
}

// ================================================================
// USER AVATAR
// ================================================================

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.isLoading,
    required this.shimmerController,
    required this.onTap,
  });

  final bool isLoading;
  final AnimationController shimmerController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.home_header_background,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: isLoading
              ? ClipOval(
            child: _ShimmerBlock(
              controller: shimmerController,
              width: 44.w,
              height: 44.w,
              radius: 44,
            ),
          )
              : Icon(
            Iconsax.user_copy,
            size: 20.sp,
            color: AppColors.home_header,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// NOTIFICATION ICON BUTTON
// ================================================================

class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Iconsax.notification_copy,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Container(
              constraints: BoxConstraints(
                minWidth: 18.w,
                minHeight: 18.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE21B23),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.home_header_background,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================
// CART ICON BUTTON
// ================================================================

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Iconsax.shopping_cart_copy,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Container(
              constraints: BoxConstraints(
                minWidth: 17.w,
                minHeight: 17.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.home_header_background,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ================================================================
// HEADER ICON BUTTON
// ================================================================

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.home_header_background,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: SizedBox(
          width: 35.w,
          height: 35.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors.home_header,
          ),
        ),
      ),
    );
  }
}
