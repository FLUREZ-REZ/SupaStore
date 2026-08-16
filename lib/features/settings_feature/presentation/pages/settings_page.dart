import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/settings_feature/presentation/pages/about_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/privacy_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/support_page.dart';

import 'package:supastore/features/settings_feature/presentation/providers/settings_provider.dart';

import 'package:supastore/features/settings_feature/presentation/widgets/settings_menu_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsProvider>(
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
    final settingsProvider =
    context.watch<SettingsProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        backgroundColor:
        Colors.grey.shade50,

        // ==========================================
        // APP BAR
        // ==========================================

        appBar: AppBar(
          title: const Text(
            'تنظیمات',
          ),

          centerTitle: true,

          backgroundColor:
          Colors.white,

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
                BorderRadius.circular(
                  16.r,
                ),

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

                    onTap: () {
                      settingsProvider
                          .toggleNotifications();
                    },

                    trailing: Switch(
                      value: settingsProvider
                          .notificationsEnabled,

                      onChanged:
                      settingsProvider
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

                    iconColor:
                    Colors.blue,

                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const SupportPage(),
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
                BorderRadius.circular(
                  16.r,
                ),

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

                    iconColor:
                    Colors.green,

                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const PrivacyPage(),
                        ),
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
                      Navigator.of(
                        context,
                      ).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const AboutPage(),
                        ),
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