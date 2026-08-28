import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  // ============================================================
  // OPEN EDIT PROFILE
  // ============================================================

  Future<void> _openEditProfile(
      BuildContext context,
      ) async {
    final provider = context.read<ProfileProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const EditProfilePage(),
        ),
      ),
    );
  }

  // ============================================================
  // OPEN CART
  // ============================================================

  Future<void> _openCart(
      BuildContext context,
      ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CartPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    // ============================================================
    // PROFILE PROVIDER
    // ============================================================

    final profileProvider =
    context.watch<ProfileProvider>();

    final profile =
        profileProvider.profile;

    // ============================================================
    // CART PROVIDER
    // ============================================================

    final cartProvider =
    context.watch<CartProvider>();

    final cartCount =
        cartProvider.totalItems;

    // ============================================================
    // USER INFO
    // ============================================================

    String title;
    String subtitle;

    if (profileProvider.isLoading &&
        profile == null) {
      title = 'کاربر';
      subtitle = 'در حال دریافت اطلاعات...';
    } else {
      final fullName =
      profile?.fullName?.trim();

      final phone =
          profile?.phone?.trim() ??
              user?.phone?.trim();

      if (fullName != null &&
          fullName.isNotEmpty) {
        title = fullName;

        subtitle =
        phone?.isNotEmpty == true
            ? phone!
            : 'ویرایش پروفایل';
      } else {
        title = 'کاربر';

        subtitle =
        phone?.isNotEmpty == true
            ? phone!
            : 'ویرایش پروفایل';
      }
    }

    // ============================================================
    // HEADER
    // ============================================================

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color:
        AppColors.home_header,

        borderRadius:
        BorderRadius.only(
          bottomLeft:
          Radius.circular(24.r),
          bottomRight:
          Radius.circular(24.r),
        ),
      ),

      child: Padding(
        padding:
        EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          10.h,
        ),

        child: Directionality(
          textDirection:
          TextDirection.rtl,

          child: Row(
            children: [
              // ==================================================
              // USER AVATAR
              // ==================================================

              _UserAvatar(
                isLoading:
                profileProvider.isLoading &&
                    profile == null,

                onTap: () {
                  _openEditProfile(
                    context,
                  );
                },
              ),

              SizedBox(
                width: 10.w,
              ),

              // ==================================================
              // USER INFO
              // ==================================================

              Expanded(
                child: Material(
                  color:
                  Colors.transparent,

                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      12.r,
                    ),

                    onTap: () {
                      _openEditProfile(
                        context,
                      );
                    },

                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(
                        vertical: 4.h,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        mainAxisSize:
                        MainAxisSize.min,

                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            AppTextStyles.user
                                .copyWith(
                              fontSize: 15.sp,
                              fontWeight:
                              FontWeight.w500,
                              color:
                              Colors.black,
                            ),
                          ),

                          SizedBox(
                            height: 3.h,
                          ),

                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            AppTextStyles.userName
                                .copyWith(
                              fontSize: 10.sp,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 12.w,
              ),

              // ==================================================
              // NOTIFICATION
              // ==================================================

              _HeaderIconButton(
                icon:
                Icons
                    .notifications_none_rounded,
                onTap: () {
                  // TODO:
                  // NotificationsPage
                },
              ),

              SizedBox(
                width: 8.w,
              ),

              // ==================================================
              // CART
              // ==================================================

              _CartIconButton(
                count: cartCount,
                onTap: () {
                  _openCart(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// USER AVATAR
// ==================================================================

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
      Colors.transparent,

      shape:
      const CircleBorder(),

      child: InkWell(
        customBorder:
        const CircleBorder(),

        onTap: onTap,

        child: Container(
          width: 44.w,
          height: 44.w,

          decoration: BoxDecoration(
            color:
            AppColors.home_header_background,

            shape:
            BoxShape.circle,

            border: Border.all(
              color:
              AppColors.primary
                  .withValues(
                alpha: 0.08,
              ),
            ),
          ),

          child: isLoading
              ? Padding(
            padding:
            EdgeInsets.all(12.w),
            child:
            const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : Icon(
            Icons
                .person_outline_rounded,
            size: 20.sp,
            color: AppColors
                .home_header,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CART ICON BUTTON
// ==================================================================

class _CartIconButton
    extends StatelessWidget {
  const _CartIconButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Stack(
      clipBehavior:
      Clip.none,

      children: [
        _HeaderIconButton(
          icon:
          Icons.shopping_cart_outlined,
          onTap: onTap,
        ),

        // فقط وقتی سبد خالی نیست عدد را نمایش بده
        if (count > 0)
          Positioned(
            top: -6.h,
            right: -6.w,

            child: Container(
              constraints:
              BoxConstraints(
                minWidth: 17.w,
                minHeight: 17.w,
              ),

              padding:
              EdgeInsets.symmetric(
                horizontal: 4.w,
              ),

              decoration:
              BoxDecoration(
                color:
                AppColors.white,

                shape:
                BoxShape.circle,

                border:
                Border.all(
                  color: AppColors
                      .home_header_background,
                  width: 1.5,
                ),
              ),

              child: Center(
                child: Text(
                  count > 99
                      ? '99+'
                      : count.toString(),

                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Colors.red,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================================================================
// HEADER ICON BUTTON
// ==================================================================

class _HeaderIconButton
    extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      AppColors.home_header_background,

      borderRadius:
      BorderRadius.circular(
        13.r,
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          13.r,
        ),

        onTap: onTap,

        child: SizedBox(
          width: 35.w,
          height: 35.w,

          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors
                .home_header,
          ),
        ),
      ),
    );
  }
}