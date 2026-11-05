
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/admin_feature/Users/presentation/providers/admin_user_provider.dart';
import 'package:supastore/features/admin_feature/admin_access_feature/presentation/providers/admin_access_provider.dart';
import 'package:supastore/features/admin_feature/admin_banner_feature/presentation/pages/admin_banners_page.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/pages/admin_flash_sales_page.dart';
import 'package:supastore/features/admin_feature/category/presentation/providers/admin_category_provider.dart';
import 'package:supastore/features/admin_feature/presentation/providers/admin_product_provider.dart';
import 'package:supastore/features/admin_feature/review/presentation/providers/admin_review_provider.dart';
import 'package:supastore/features/auth_feature/domain/usecases/logout.dart';

import 'package:supastore/features/notification_feature/presentation/pages/admin_announcements_page.dart';
import 'package:supastore/features/notification_feature/presentation/providers/notifications_provider.dart';

import 'admin_categories_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_reviews_page.dart';
import 'admin_settings_page.dart';
import 'admin_users_page.dart';

class AdminMainPage extends StatelessWidget {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminAccessProvider>(
      create: (_) => getIt<AdminAccessProvider>()..loadAccess(),
      child: const _AdminMainView(),
    );
  }
}

class _AdminMainView extends StatefulWidget {
  const _AdminMainView();

  @override
  State<_AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<_AdminMainView> {
  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF023E8A);
  static const Color _selectedColor = Color(0xFFCAF0F8);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  int _selectedIndex = 0;

  // null: انتخاب حالت پیش‌فرض براساس عرض صفحه
  // دسکتاپ: باز
  // تبلت: بسته
  bool? _sidebarExpanded;

  late List<_AdminMenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = [];
    _testAdminAccess();
  }

  Future<void> _testAdminAccess() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    debugPrint(
      '================ ADMIN ACCESS TEST ================',
    );
    debugPrint('AUTH USER ID: ${user?.id}');
    debugPrint('AUTH PHONE: ${user?.phone}');

    if (user == null) {
      debugPrint('USER IS NULL - USER IS NOT LOGGED IN');
      debugPrint('====================================================');
      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('''
            id,
            phone,
            is_admin,
            admin_role,
            is_active
          ''')
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('PROFILE: $profile');

      final role = await supabase.rpc('current_admin_role');

      debugPrint('CURRENT ADMIN ROLE: $role');
    } catch (e, stackTrace) {
      debugPrint('ADMIN ACCESS TEST ERROR: $e');
      debugPrint('$stackTrace');
    }

    debugPrint('====================================================');
  }

  Future<void> _logout() async {
    try {
      await getIt<SignOut>()();

      if (!mounted) return;

      context.go('/auth');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خروج از حساب انجام نشد.'),
        ),
      );
    }
  }

  void _buildMenuItems(AdminAccessProvider accessProvider) {
    final List<_AdminMenuItem> items = [];

    if (accessProvider.isSuperAdmin) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Iconsax.home_1,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'محصولات',
          icon: Iconsax.box_1_copy,
          page: ChangeNotifierProvider<AdminProductProvider>(
            create: (_) => getIt<AdminProductProvider>(),
            child: const AdminProductsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'دسته‌بندی‌ها',
          icon: Iconsax.category_copy,
          page: ChangeNotifierProvider<AdminCategoryProvider>(
            create: (_) => getIt<AdminCategoryProvider>(),
            child: const AdminCategoriesPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'فروش ویژه',
          icon: Icons.local_offer_outlined,
          page: const AdminFlashSalesPage(),
        ),
        _AdminMenuItem(
          title: 'بنرها',
          icon: Iconsax.picture_frame_copy,
          page: const AdminBannersPage(),
        ),
        _AdminMenuItem(
          title: 'سفارش‌ها',
          icon: Iconsax.box_copy,
          page: const AdminOrdersPage(),
        ),
        _AdminMenuItem(
          title: 'کاربران',
          icon: Iconsax.people_copy,
          page: ChangeNotifierProvider<AdminUserProvider>(
            create: (_) => getIt<AdminUserProvider>(),
            child: AdminUsersPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'نظرات',
          icon: Iconsax.message_copy,
          page: ChangeNotifierProvider<AdminReviewProvider>(
            create: (_) => getIt<AdminReviewProvider>(),
            child: const AdminReviewsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'تنظیمات',
          icon: Iconsax.setting_2_copy,
          page: const AdminSettingsPage(),
        ),
      ]);
    } else if (accessProvider.isOrderManager) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Iconsax.home_1_copy,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'سفارش‌ها',
          icon: Iconsax.box_1_copy,
          page: const AdminOrdersPage(),
        ),
      ]);
    } else if (accessProvider.isProductManager) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Iconsax.home_1_copy,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'محصولات',
          icon: Iconsax.box_1_copy,
          page: ChangeNotifierProvider<AdminProductProvider>(
            create: (_) => getIt<AdminProductProvider>(),
            child: const AdminProductsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'دسته‌بندی‌ها',
          icon: Iconsax.category_copy,
          page: ChangeNotifierProvider<AdminCategoryProvider>(
            create: (_) => getIt<AdminCategoryProvider>(),
            child: const AdminCategoriesPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'فروش ویژه',
          icon: Icons.local_offer_outlined,
          page: const AdminFlashSalesPage(),
        ),
      ]);
    }

    // اطلاعیه‌ها برای ادمین اصلی و ادمین محصولات
    if (accessProvider.isSuperAdmin ||
        accessProvider.isProductManager) {
      items.add(
        _AdminMenuItem(
          title: 'اطلاعیه‌ها',
          icon: Iconsax.notification_copy,
          page: ChangeNotifierProvider<NotificationsProvider>(
            create: (_) => getIt<NotificationsProvider>(),
            child: const AdminAnnouncementsPage(),
          ),
        ),
      );
    }

    _menuItems = items;

    if (_selectedIndex >= _menuItems.length) {
      _selectedIndex = 0;
    }
  }

  void _selectPage(int index, {bool closeDrawer = false}) {
    if (index < 0 || index >= _menuItems.length) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (closeDrawer) {
      Navigator.of(context).pop();
    }
  }

  void _toggleSidebar(double width) {
    setState(() {
      final bool currentExpanded =
          _sidebarExpanded ?? width >= 1100;

      _sidebarExpanded = !currentExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessProvider = context.watch<AdminAccessProvider>();

    if (accessProvider.isLoading) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE21B23),
            ),
          ),
        ),
      );
    }

    if (!accessProvider.canAccessAdmin) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'شما دسترسی لازم برای ورود به پنل مدیریت را ندارید.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    _buildMenuItems(accessProvider);

    if (_menuItems.isEmpty) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: Text(
              'دسترسی مدیریتی برای حساب شما فعال نیست.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          final bool isMobile = width < 768;
          final bool isTablet = width >= 768 && width < 1100;

          final bool sidebarExpanded =
              _sidebarExpanded ?? !isTablet;

          return Scaffold(
            backgroundColor: _backgroundColor,

            appBar: AppBar(
              elevation: 0,
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              centerTitle: isMobile,
              automaticallyImplyLeading: isMobile,
              title: Text(
                _menuItems[_selectedIndex].title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 17.sp : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                if (!isMobile)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20,
                    ),
                    child: Center(
                      child: Text(
                        isTablet ? 'پنل مدیریت' : 'SupaStore Admin',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            drawer: isMobile ? _buildDrawer() : null,

            body: isMobile
                ? IndexedStack(
              index: _selectedIndex,
              children: _menuItems
                  .map((item) => item.page)
                  .toList(),
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(
                  expanded: sidebarExpanded,
                  accessProvider: accessProvider,
                  screenWidth: width,
                ),

                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _menuItems
                        .map((item) => item.page)
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP / TABLET SIDEBAR WITH FLOATING TOGGLE
  // ============================================================

  Widget _buildSidebar({
    required bool expanded,
    required AdminAccessProvider accessProvider,
    required double screenWidth,
  }) {
    final double sidebarWidth = expanded ? 250 : 76;

    return SizedBox(
      width: sidebarWidth,

      // Stack اجازه می‌دهد دکمه فلش از لبه سایدبار بیرون بیاید.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // خود سایدبار
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: sidebarWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(
                    color: Color(0xFFEAEAEA),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildSidebarHeader(
                    expanded: expanded,
                    accessProvider: accessProvider,
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFEAEAEA),
                  ),

                  if (expanded)
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        18,
                        20,
                        18,
                        10,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'منوی اصلی',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 14),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? 12 : 8,
                        vertical: 5,
                      ),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];

                        return _sidebarItem(
                          index: index,
                          icon: item.icon,
                          title: item.title,
                          expanded: expanded,
                        );
                      },
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFEAEAEA),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: expanded ? 12 : 8,
                      vertical: 12,
                    ),
                    child: _sidebarLogout(
                      expanded: expanded,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // دکمه فلش متصل به لبه سایدبار
          Positioned(
            left: -16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _sidebarToggleButton(
                expanded: expanded,
                screenWidth: screenWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR HEADER
  // ============================================================

  Widget _buildSidebarHeader({
    required bool expanded,
    required AdminAccessProvider accessProvider,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 105,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 18 : 8,
      ),
      decoration: const BoxDecoration(
        color: _primaryColor,
      ),
      child: expanded
          ? Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.shield_tick_copy,
              color: _primaryColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مدیریت فروشگاه',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _getRoleTitle(accessProvider.adminRole),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : const Center(
        child: Icon(
          Iconsax.shield_tick_copy,
          color: Colors.white,
          size: 29,
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING ARROW BUTTON
  // ============================================================

  Widget _sidebarToggleButton({
    required bool expanded,
    required double screenWidth,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSidebar(screenWidth),
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE1E5EA),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(-2, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                expanded
                    ? Icons.chevron_right
                    : Icons.chevron_left,
                key: ValueKey<bool>(expanded),
                color: _primaryColor,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SIDEBAR MENU ITEM
  // ============================================================

  Widget _sidebarItem({
    required int index,
    required IconData icon,
    required String title,
    required bool expanded,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: expanded ? '' : title,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: selected ? _selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _selectPage(index),
            child: SizedBox(
              height: 49,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 12 : 0,
                ),
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 21,
                      color: selected
                          ? _primaryColor
                          : Colors.black54,
                    ),

                    if (expanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? _primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 4,
                          height: 25,
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SIDEBAR LOGOUT
  // ============================================================

  Widget _sidebarLogout({required bool expanded}) {
    return Tooltip(
      message: expanded ? '' : 'خروج از حساب',
      child: Material(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _logout,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 12 : 0,
              ),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.logout_copy,
                    color: Colors.red,
                    size: 20,
                  ),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'خروج از حساب',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE DRAWER
  // ============================================================

  Widget _buildDrawer() {
    final accessProvider = context.read<AdminAccessProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;
            final bool compact = availableHeight < 650;

            final double headerHeight = compact ? 82.h : 104.h;
            final double footerHeight = compact ? 54.h : 64.h;

            final double menuHeight = (
                availableHeight -
                    headerHeight -
                    footerHeight -
                    2
            ).clamp(0.0, availableHeight);

            final double itemHeight = _menuItems.isEmpty
                ? 0
                : (menuHeight / _menuItems.length)
                .clamp(0.0, 64.0);

            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Container(
                          width: compact ? 42.w : 48.w,
                          height: compact ? 42.w : 48.w,
                          decoration: const BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.shield_tick_copy,
                            color: Colors.white,
                            size: compact ? 23.sp : 26.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مدیریت فروشگاه',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: compact ? 15.sp : 17.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getRoleTitle(accessProvider.adminRole),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 10.sp : 11.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: _menuItems.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                    ),
                    child: Column(
                      children: List.generate(
                        _menuItems.length,
                            (index) {
                          final item = _menuItems[index];

                          return SizedBox(
                            height: itemHeight,
                            width: double.infinity,
                            child: _drawerItem(
                              index: index,
                              icon: item.icon,
                              title: item.title,
                              compact: compact,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                SizedBox(
                  height: footerHeight,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: _logout,
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Icon(
                            Iconsax.logout_copy,
                            color: Colors.red,
                            size: compact ? 19.sp : 21.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'خروج از حساب',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: compact ? 12.sp : 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _drawerItem({
    required int index,
    required IconData icon,
    required String title,
    bool compact = false,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Material(
        color: selected ? _selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selectPage(index, closeDrawer: true),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: compact ? 18.sp : 20.sp,
                  color: selected ? _primaryColor : Colors.black54,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11.sp : 13.sp,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected ? _primaryColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleTitle(String role) {
    switch (role) {
      case 'super_admin':
        return 'مدیر ارشد';
      case 'order_manager':
        return 'مدیر سفارش‌ها';
      case 'product_manager':
        return 'مدیر محصولات';
      default:
        return 'پنل مدیریت';
    }
  }
}

class _AdminMenuItem {
  const _AdminMenuItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}
