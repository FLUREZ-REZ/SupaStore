import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';
import 'package:supastore/features/auth_feature/data/services/auth_role_service.dart';
import 'package:supastore/features/splash_feature/presentation/providers/splash_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
  });

  @override
  State<SplashPage> createState() =>
      _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final splashProvider =
    context.read<SplashProvider>();

    await splashProvider.initialize();

    if (!mounted) return;

    if (!splashProvider.hasInternet) {
      return;
    }

    // ============================================================
    // LOAD STORE SETTINGS
    // ============================================================

    final storeSettingsProvider =
    context.read<StoreSettingsProvider>();

    if (storeSettingsProvider.settings == null) {
      await storeSettingsProvider.loadSettings();
    }

    if (!mounted) return;

    // ============================================================
    // SPLASH DELAY
    // ============================================================

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // ============================================================
    // LOGGED IN USER
    // ============================================================

    if (splashProvider.isLoggedIn) {
      final authRoleService =
      getIt<AuthRoleService>();

      final isAdmin =
      await authRoleService.isCurrentUserAdmin();

      if (!mounted) return;

      if (isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }

      return;
    }

    // ============================================================
    // INTRO
    // ============================================================

    final prefs =
    await SharedPreferences.getInstance();

    final seenIntro =
        prefs.getBool(
          'show_intro',
        ) ??
            false;

    if (!mounted) return;

    if (seenIntro) {
      context.go('/auth');
    } else {
      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.splash_background,

      body: Consumer2<
          SplashProvider,
          StoreSettingsProvider>(
        builder: (
            context,
            splashProvider,
            storeSettingsProvider,
            child,
            ) {
          // ==========================================================
          // INTERNET ERROR
          // ==========================================================

          if (!splashProvider.isLoading &&
              !splashProvider.hasInternet) {
            return SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 40.h,
                    child: Column(
                      children: [
                        Text(
                          'اتصال اینترنت برقرار نیست',
                          style: AppTextStyles
                              .splash_no_internet
                              .copyWith(
                            color: AppColors
                                .splash_no_internet,
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        GestureDetector(
                          onTap: _initialize,
                          child: Text(
                            'تلاش مجدد',
                            style: AppTextStyles
                                .splash_try_again
                                .copyWith(
                              color: AppColors
                                  .splash_try_again,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // ==========================================================
          // STORE SETTINGS NOT READY
          // ==========================================================

          final settings =
              storeSettingsProvider.settings;

          if (settings == null) {
            return SafeArea(
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          // ==========================================================
          // STORE SETTINGS READY
          // ==========================================================

          final storeName =
              storeSettingsProvider.storeName;

          final logoUrl =
              storeSettingsProvider.logoUrl;

          return SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            24.r,
                          ),
                        ),
                        clipBehavior:
                        Clip.antiAlias,
                        child: logoUrl != null &&
                            logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: logoUrl,
                          width: 120.w,
                          height: 120.w,
                          fit: BoxFit.contain,
                          placeholder: (
                              context,
                              url,
                              ) {
                            return const SizedBox.shrink();
                          },
                          errorWidget: (
                              context,
                              url,
                              error,
                              ) {
                            return const SizedBox.shrink();
                          },
                        )
                            :  const SizedBox.shrink(),
                      ),

                      SizedBox(
                        height: 20.h,
                      ),

                      Text(
                        storeName,
                        textAlign:
                        TextAlign.center,
                        style: AppTextStyles
                            .splashTitle
                            .copyWith(
                          color: AppColors
                              .splash_logo_text,
                        ),
                      ),

                      SizedBox(
                        height: 40.h,
                      ),

                      if (splashProvider.isLoading ||
                          storeSettingsProvider.isLoading)
                        SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}