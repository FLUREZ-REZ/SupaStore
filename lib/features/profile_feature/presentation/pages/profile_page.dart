import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_header.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_menu_item.dart';
import 'package:supastore/features/settings_feature/presentation/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
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

    return _ProfileView(
      user: user,
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.user,
  });

  final User user;




  @override
  Widget build(BuildContext context) {



    final provider =
    context.watch<ProfileProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        appBar: AppBar(
          title: const Text(
            'پروفایل',
          ),
          centerTitle: true,
          backgroundColor: AppColors.profile_page_redi,
          elevation: 0,
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            await provider.refreshProfile(
              userId: user.id,
            );
          },

          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(
              parent:
              BouncingScrollPhysics(),
            ),

            padding: EdgeInsets.only(
              bottom: 30.h,
            ),

            children: [
              // ========================================
              // PROFILE HEADER
              // ========================================

              if (provider.isLoading)
                SizedBox(
                  height: 150.h,
                  child: const Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                )
              else
                ProfileHeader(
                  email: user.email ?? '',
                  userId: user.id,
                  profile: provider.profile,
                ),

              SizedBox(
                height: 8.h,
              ),

              // ========================================
              // ACCOUNT
              // ========================================

              const _SectionTitle(
                title: 'حساب کاربری',
              ),

              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16.r),
                  border: Border.all(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: Column(
                  children: [
                    // EDIT PROFILE

                    ProfileMenuItem(
                      icon:
                      Icons.edit_outlined,
                      title:
                      'ویرایش پروفایل',

                      onTap: () async {
                        await Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangeNotifierProvider
                                    .value(
                                  value: provider,
                                  child:
                                  const EditProfilePage(),
                                ),
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        await provider
                            .refreshProfile(
                          userId: user.id,
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // ORDERS

                    ProfileMenuItem(
                      icon:
                      Icons.shopping_bag_outlined,
                      title:
                      'سفارش‌های من',

                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const OrdersPage(),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // FAVORITES

                    ProfileMenuItem(
                      icon:
                      Icons.favorite_border,
                      title:
                      'علاقه‌مندی‌های من',
                      iconColor:
                      Colors.red,

                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const FavoritesPage(),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // CART

                    ProfileMenuItem(
                      icon: Icons
                          .shopping_cart_outlined,
                      title:
                      'سبد خرید',

                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const CartPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 20.h,
              ),

              // ========================================
              // SETTINGS
              // ========================================

              const _SectionTitle(
                title: 'تنظیمات',
              ),

              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16.r),
                  border: Border.all(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: Column(
                  children: [
                    // ADDRESSES

                    ProfileMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'آدرس‌های من',

                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddressesPage(),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // SETTINGS

                    ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'تنظیمات',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 20.h,
              ),

              // ========================================
              // LOGOUT
              // ========================================

              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16.r),
                  border: Border.all(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: ProfileMenuItem(
                  icon: Icons.logout,
                  title:
                  'خروج از حساب',
                  iconColor:
                  Colors.red,

                  onTap: () {
                    _showLogoutDialog(
                      context,
                    );
                  },
                ),
              ),

              SizedBox(
                height: 30.h,
              ),

              // ========================================
              // APP NAME
              // ========================================

              Center(
                child: Text(
                  'Supastore',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                    Colors.grey.shade500,
                  ),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  // LOGOUT DIALOG
  // ====================================================

  Future<void> _showLogoutDialog(
      BuildContext context,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'خروج از حساب',
          ),

          content: const Text(
            'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },

              child: const Text(
                'انصراف',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },

              child: const Text(
                'خروج',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.bold,
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

  // ====================================================
  // LOGOUT
  // ====================================================

  Future<void> _logout(
      BuildContext context,
      String userId,
      ) async {
    // ================================================
    // LOADING
    // ================================================

    showDialog<void>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return const Center(
          child:
          CircularProgressIndicator(),
        );
      },
    );

    try {
      // ==============================================
      // CLEAR PROFILE
      // ==============================================

      context
          .read<ProfileProvider>()
          .clearProfile();

      // ==============================================
      // CLEAR FAVORITES
      // ==============================================

      getIt<FavoriteProvider>()
          .clearFavorites();

      // ==============================================
      // CLEAR CART
      //
      // CartProvider فعلی تو userId می‌خواهد
      // ==============================================

      await getIt<CartProvider>()
          .clearCart(userId);

      // ==============================================
      // SIGN OUT FROM SUPABASE
      // ==============================================

      await Supabase
          .instance
          .client
          .auth
          .signOut();

      if (!context.mounted) {
        return;
      }

      // ==============================================
      // CLOSE LOADING
      // ==============================================

      Navigator.of(context).pop();

      // ==============================================
      // GO TO AUTH PAGE
      // ==============================================

      context.goNamed('auth');
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      // ==============================================
      // CLOSE LOADING
      // ==============================================

      Navigator.of(context).pop();

      // ==============================================
      // SHOW ERROR
      // ==============================================

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'خطا در خروج از حساب: $e',
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    }
  }
}

// ====================================================
// SECTION TITLE
// ====================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding: EdgeInsets.only(
        right: 20.w,
        bottom: 8.h,
      ),

      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight:
          FontWeight.bold,
          color:
          Colors.grey.shade700,
        ),
      ),
    );
  }
}