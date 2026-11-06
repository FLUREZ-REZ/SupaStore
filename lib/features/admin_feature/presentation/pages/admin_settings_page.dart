
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/presentation/pages/admin_general_settings_page.dart';
import 'package:supastore/features/admin_feature/admin_managers_feature/presentation/pages/admin_managers_page.dart';
import 'package:supastore/features/admin_feature/admin_payments_settings_feature/presentation/pages/admin_payment_settings_page.dart';
import 'package:supastore/features/admin_feature/settings/presentation/pages/admin_store_infopage.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/pages/admin_shipping_page.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/providers/admin_shipping_provider.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF023E8A);
  static const Color _accentColor = Color(0xFF0096C7);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width >= 1200
                ? 32.0
                : width >= 700
                ? 24.0
                : 16.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1250,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(width),

                      const SizedBox(height: 26),

                      _buildStoreInfoTile(context, width),

                      const SizedBox(height: 28),

                      _buildSectionTitle('ارسال'),
                      const SizedBox(height: 12),

                      _buildSettingsGrid(
                        width: width,
                        children: [
                          _buildSettingTile(
                            icon: Iconsax.truck_fast_copy,
                            iconColor: const Color(0xFF3949AB),
                            title: 'تنظیمات ارسال',
                            subtitle:
                            'روش‌های ارسال، هزینه، ارسال رایگان، محدوده و زمان ارسال',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) {
                                    return ChangeNotifierProvider<
                                        AdminShippingProvider>(
                                      create: (_) =>
                                          getIt<AdminShippingProvider>(),
                                      child: const AdminShippingPage(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle('پرداخت'),
                      const SizedBox(height: 12),

                      _buildSettingsGrid(
                        width: width,
                        children: [
                          _buildSettingTile(
                            icon: Iconsax.card_copy,
                            iconColor: const Color(0xFF2E7D32),
                            title: 'تنظیمات پرداخت',
                            subtitle:
                            'درگاه پرداخت، پرداخت آنلاین، پرداخت در محل و حالت تست',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AdminPaymentSettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle('مدیران و امنیت'),
                      const SizedBox(height: 12),

                      _buildSettingsGrid(
                        width: width,
                        children: [
                          _buildSettingTile(
                            icon: Iconsax.ship_copy,
                            iconColor: const Color(0xFF00897B),
                            title: 'مدیران و امنیت',
                            subtitle:
                            'مدیران، نقش‌ها، سطح دسترسی و وضعیت دسترسی مدیران',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AdminManagersPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle('تنظیمات عمومی'),
                      const SizedBox(height: 12),

                      _buildSettingsGrid(
                        width: width,
                        children: [
                          _buildSettingTile(
                            icon: Iconsax.setting_2_copy,
                            iconColor: const Color(0xFF546E7A),
                            title: 'تنظیمات عمومی سیستم',
                            subtitle:
                            'زبان، واحد پول، منطقه زمانی، تاریخ، تعمیرات و اطلاعات نسخه',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AdminGeneralSettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      _buildBottomInfo(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Store info tile
  // ---------------------------------------------------------------------------

  Widget _buildStoreInfoTile(
      BuildContext context,
      double width,
      ) {
    return _buildSettingTile(
      icon: Iconsax.shop_copy,
      iconColor: _secondaryColor,
      title: 'اطلاعات فروشگاه',
      subtitle:
      'نام، لوگو، اطلاعات تماس، آدرس، شبکه‌های اجتماعی و اطلاعات حقوقی',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AdminStoreInfoPage(),
          ),
        );
      },
      featured: true,
      compact: width < 500,
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(double width) {
    final isMobile = width < 500;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: _cardDecoration(radius: 20),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 58,
            height: isMobile ? 48 : 58,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.setting_2_copy,
              size: 28,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظیمات فروشگاه',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مدیریت کامل تنظیمات فروشگاه و پنل مدیریت',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    height: 1.7,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section title
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Responsive settings grid
  // ---------------------------------------------------------------------------

  Widget _buildSettingsGrid({
    required double width,
    required List<Widget> children,
  }) {
    final isDesktop = width >= 850;

    if (!isDesktop) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Setting tile
  // ---------------------------------------------------------------------------

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool featured = false,
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(featured ? 20 : 18),
        border: Border.all(
          color: featured
              ? _secondaryColor.withValues(alpha: 0.18)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: featured ? 0.035 : 0.025,
            ),
            blurRadius: featured ? 10 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(featured ? 20 : 18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 13 : 17,
              vertical: featured ? 19 : 16,
            ),
            child: Row(
              children: [
                Container(
                  width: featured ? 52 : 46,
                  height: featured ? 52 : 46,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: featured ? 25 : 23,
                    color: iconColor,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: featured ? 15 : 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 11,
                          height: 1.7,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card decoration
  // ---------------------------------------------------------------------------

  BoxDecoration _cardDecoration({
    double radius = 18,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildBottomInfo() {
    return Column(
      children: [
        Divider(
          color: Colors.grey.shade200,
          height: 1,
        ),
        const SizedBox(height: 20),
        Text(
          'SupaStore Admin Panel',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'نسخه 1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
