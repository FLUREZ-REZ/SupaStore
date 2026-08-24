import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    final profileProvider =
    context.watch<ProfileProvider>();

    final profile =
        profileProvider.profile;

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

      // ==========================================================
      // BACKGROUND COLOR OF ENTIRE HEADER
      // ==========================================================

      decoration: BoxDecoration(
        color: AppColors.home_header_background,
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
              // ====================================================
              // USER AVATAR
              // ====================================================

              _UserAvatar(
                isLoading:
                profileProvider.isLoading &&
                    profile == null,

                onTap: () {
                  _openEditProfile(context);
                },
              ),

              SizedBox(
                width: 10.w,
              ),

              // ====================================================
              // USER INFO
              // ====================================================

              Expanded(
                child: Material(
                  color: Colors.transparent,

                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(12.r),

                    onTap: () {
                      _openEditProfile(context);
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
                          // ========================================
                          // NAME
                          // ========================================

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
                              Colors.white,
                            ),
                          ),

                          SizedBox(
                            height: 3.h,
                          ),

                          // ========================================
                          // PHONE
                          // ========================================

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
                              Colors.white,
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

              // ====================================================
              // NOTIFICATION
              // ====================================================

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

              // ====================================================
              // CART
              // ====================================================

              _HeaderIconButton(
                icon:
                Icons
                    .shopping_cart_outlined,

                onTap: () {
                  // TODO:
                  // CartPage
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
      color: Colors.transparent,

      shape: const CircleBorder(),

      child: InkWell(
        customBorder: const CircleBorder(),

        onTap: onTap,

        child: Container(
          width: 44.w,
          height: 44.w,

          decoration: BoxDecoration(
            color:
            AppColors.home_header,

            shape:
            BoxShape.circle,

            border: Border.all(
              color:
              AppColors.primary.withValues(
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
            Icons.person_outline_rounded,

            size: 20.sp,

            color:
            AppColors
                .home_header_background,
          ),
        ),
      ),
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
  Widget build(BuildContext context) {
    return Material(
      color:
      AppColors.home_header,

      borderRadius:
      BorderRadius.circular(13.r),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(13.r),

        onTap: onTap,

        child: SizedBox(
          width: 35.w,
          height: 35.w,

          child: Icon(
            icon,

            size: 20.sp,

            color:
            AppColors
                .home_header_background,
          ),
        ),
      ),
    );
  }
}