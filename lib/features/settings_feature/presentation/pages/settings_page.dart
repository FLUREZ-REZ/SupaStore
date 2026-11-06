
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
      create: (_) => getIt<SettingsProvider>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        // APP BAR
        appBar: AppBar(
          title: const Text('تنظیمات'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        // BODY
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 600
                ? 16.0
                : width < 1000
                ? 28.0
                : 40.0;

            final contentMaxWidth =
            width >= 1000 ? 850.0 : double.infinity;

            final isMobile = width < 600;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: isMobile ? 16 : 24,
                bottom: 30,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // APP SETTINGS
                        const _SectionTitle(
                          title: 'تنظیمات برنامه',
                        ),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              // SUPPORT
                              SettingsMenuItem(
                                icon: Icons.support_agent_outlined,
                                title: 'پشتیبانی',
                                iconColor: Colors.blue,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SupportPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // INFORMATION
                        const _SectionTitle(
                          title: 'اطلاعات',
                        ),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              // PRIVACY
                              SettingsMenuItem(
                                icon: Iconsax.lock_copy,
                                title: 'حریم خصوصی',
                                iconColor: Colors.green,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const PrivacyPage(),
                                    ),
                                  );
                                },
                              ),

                              Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),

                              // ABOUT
                              SettingsMenuItem(
                                icon: Iconsax.information_copy,
                                title: 'درباره ما',
                                iconColor: Colors.orange,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AboutPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // APP NAME
                        Center(
                          child: Text(
                            'Supastore',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // VERSION
                        Center(
                          child: Text(
                            'نسخه 1.0.0',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.only(
        right: 4,
        bottom: 8,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
