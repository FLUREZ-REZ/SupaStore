import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/settings_feature/presentation/providers/settings_provider.dart';
import 'package:supastore/features/settings_feature/presentation/widgets/settings_menu_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      getIt<SettingsProvider>()
        ..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<SettingsProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        // ==========================================
        // APP BAR
        // ==========================================

        appBar: AppBar(
          title: const Text(
            'تنظیمات',
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        // ==========================================
        // BODY
        // ==========================================

        body: ListView(
          physics:
          const BouncingScrollPhysics(),

          padding: EdgeInsets.only(
            top: 16.h,
            bottom: 30.h,
          ),

          children: [
            // ======================================
            // APP SETTINGS
            // ======================================

            const _SectionTitle(
              title: 'تنظیمات برنامه',
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
                  // ==================================
                  // NOTIFICATIONS
                  // ==================================

                  SettingsMenuItem(
                    icon:
                    Icons.notifications_none_rounded,
                    title: 'اعلان‌ها',
                    iconColor:
                    Theme.of(context)
                        .colorScheme
                        .primary,
                    onTap: () {},
                    trailing: Switch(
                      value: provider
                          .notificationsEnabled,
                      onChanged:
                      provider
                          .setNotificationsEnabled,
                    ),
                  ),

                  const Divider(
                    height: 1,
                  ),

                  // ==================================
                  // SUPPORT
                  // ==================================

                  SettingsMenuItem(
                    icon:
                    Icons.support_agent_outlined,
                    title: 'پشتیبانی',
                    iconColor: Colors.blue,
                    onTap: () {
                      _showSupportDialog(
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20.h,
            ),

            // ======================================
            // INFORMATION
            // ======================================

            const _SectionTitle(
              title: 'اطلاعات',
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
                  // ==================================
                  // PRIVACY
                  // ==================================

                  SettingsMenuItem(
                    icon:
                    Icons.lock_outline_rounded,
                    title: 'حریم خصوصی',
                    iconColor: Colors.green,
                    onTap: () {
                      _showPrivacyDialog(
                        context,
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                  ),

                  // ==================================
                  // ABOUT
                  // ==================================

                  SettingsMenuItem(
                    icon:
                    Icons.info_outline_rounded,
                    title: 'درباره ما',
                    iconColor:
                    Colors.orange,
                    onTap: () {
                      _showAboutDialog(
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 35.h,
            ),

            // ======================================
            // APP NAME
            // ======================================

            Center(
              child: Text(
                'Supastore',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Colors.grey.shade500,
                ),
              ),
            ),

            SizedBox(
              height: 5.h,
            ),

            // ======================================
            // VERSION
            // ======================================

            Center(
              child: Text(
                'نسخه 1.0.0',
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // SUPPORT DIALOG
  // ==================================================

  void _showSupportDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'پشتیبانی',
            ),

            content: const Text(
              'در صورت وجود هرگونه مشکل یا سوال، می‌توانید با پشتیبانی فروشگاه تماس بگیرید.',
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'بستن',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================================================
  // PRIVACY DIALOG
  // ==================================================

  void _showPrivacyDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حریم خصوصی',
            ),

            content:
            const SingleChildScrollView(
              child: Text(
                'اطلاعات حساب کاربری شما فقط برای ارائه خدمات فروشگاه استفاده می‌شود و اطلاعات شخصی شما بدون مجوز در اختیار دیگران قرار نخواهد گرفت.',
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'بستن',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================================================
  // ABOUT DIALOG
  // ==================================================

  void _showAboutDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'درباره ما',
            ),

            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 50,
                ),

                SizedBox(
                  height: 16,
                ),

                Text(
                  'Supastore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 8,
                ),

                Text(
                  'فروشگاه آنلاین Supastore',
                  textAlign:
                  TextAlign.center,
                ),

                SizedBox(
                  height: 8,
                ),

                Text(
                  'نسخه 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text(
                  'بستن',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ====================================================
// SECTION TITLE
// ====================================================

class _SectionTitle extends StatelessWidget {
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