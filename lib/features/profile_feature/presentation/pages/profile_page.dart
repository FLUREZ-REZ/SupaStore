import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/favorite_feature/presentation/pages/favorites_page.dart';
import 'package:supastore/features/order_feature/presentation/pages/orders_page.dart';

import 'package:supastore/features/profile_feature/presentation/pages/edit_profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_header.dart';
import 'package:supastore/features/profile_feature/presentation/widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    // کاربر وارد نشده
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید',
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) {
        final provider =
        getIt<ProfileProvider>();

        provider.loadProfile(
          userId: user.id,
        );

        return provider;
      },
      child: const _ProfileView(),
    );
  }
}

// ============================================================
// PROFILE VIEW
// ============================================================

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.grey.shade50,
        ),

        body: Consumer<ProfileProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            // ==================================================
            // LOADING
            // ==================================================

            if (provider.isLoading &&
                provider.profile == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (provider.error != null &&
                provider.profile == null) {
              return _ProfileError(
                error: provider.error!,
                onRetry: () {
                  final user = Supabase
                      .instance
                      .client
                      .auth
                      .currentUser;

                  if (user == null) {
                    return;
                  }

                  provider.loadProfile(
                    userId: user.id,
                  );
                },
              );
            }

            // ==================================================
            // CURRENT USER
            // ==================================================

            final user = Supabase
                .instance
                .client
                .auth
                .currentUser;

            if (user == null) {
              return const Center(
                child: Text(
                  'کاربر وارد نشده است',
                ),
              );
            }

            // ==================================================
            // PROFILE
            // ==================================================

            final profile =
                provider.profile;

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadProfile(
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

                  // ==================================================
                  // PROFILE HEADER
                  // ==================================================

                  ProfileHeader(
                    email: user.email ?? '',
                    userId: user.id,
                    profile: profile,
                  ),

                  SizedBox(
                    height: 8.h,
                  ),

                  // ==================================================
                  // ACCOUNT
                  // ==================================================

                  const _SectionTitle(
                    title: 'حساب کاربری',
                  ),

                  _MenuContainer(
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
                                  ChangeNotifierProvider.value(
                                    value: provider,
                                    child:
                                    const EditProfilePage(),
                                  ),
                            ),
                          );

                          if (!context.mounted) {
                            return;
                          }

                          final user = Supabase
                              .instance
                              .client
                              .auth
                              .currentUser;

                          if (user == null) {
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
                        icon:
                        Icons.shopping_cart_outlined,
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

                  SizedBox(
                    height: 18.h,
                  ),

                  // ==================================================
                  // SETTINGS
                  // ==================================================

                  const _SectionTitle(
                    title: 'تنظیمات',
                  ),

                  _MenuContainer(
                    children: [

                      // ADDRESSES
                      ProfileMenuItem(
                        icon:
                        Icons.location_on_outlined,
                        title:
                        'آدرس‌های من',

                        onTap: () {
                          // مرحله بعد
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // SETTINGS
                      ProfileMenuItem(
                        icon:
                        Icons.settings_outlined,
                        title:
                        'تنظیمات',

                        onTap: () {
                          // مرحله بعد
                        },
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 18.h,
                  ),

                  // ==================================================
                  // ACCOUNT ACTIONS
                  // ==================================================

                  const _SectionTitle(
                    title: 'حساب',
                  ),

                  _MenuContainer(
                    children: [

                      // LOGOUT
                      ProfileMenuItem(
                        icon:
                        Icons.logout,
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
                    ],
                  ),

                  SizedBox(
                    height: 25.h,
                  ),

                  // ==================================================
                  // APP NAME
                  // ==================================================

                  Center(
                    child: Text(
                      'SupaStore',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                        Colors.grey.shade500,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(
      BuildContext context,
      ) {
    showDialog(
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

            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },

              child: const Text(
                'انصراف',
              ),
            ),

            // LOGOUT
            TextButton(
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop();

                try {
                  await Supabase
                      .instance
                      .client
                      .auth
                      .signOut();
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'خطا در خروج از حساب: $e',
                      ),
                    ),
                  );
                }
              },

              child: const Text(
                'خروج',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 6.h,
      ),

      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight:
          FontWeight.bold,
          color:
          Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ============================================================
// MENU CONTAINER
// ============================================================

class _MenuContainer
    extends StatelessWidget {
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

        borderRadius:
        BorderRadius.circular(16.r),

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
// ERROR
// ============================================================

class _ProfileError
    extends StatelessWidget {
  const _ProfileError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              Icons.error_outline,
              size: 55.sp,
              color: Colors.red,
            ),

            SizedBox(
              height: 16.h,
            ),

            const Text(
              'خطا در دریافت اطلاعات پروفایل',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 10.h,
            ),

            Text(
              error,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                Colors.grey.shade600,
              ),
            ),

            SizedBox(
              height: 20.h,
            ),

            ElevatedButton(
              onPressed: onRetry,

              child: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      ),
    );
  }
}