import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/admin_feature/Users/presentation/providers/admin_user_provider.dart';
import 'package:supastore/features/admin_feature/admin_access_feature/presentation/providers/admin_access_provider.dart';
import 'package:supastore/features/admin_feature/category/presentation/providers/admin_category_provider.dart';
import 'package:supastore/features/admin_feature/presentation/providers/admin_product_provider.dart';
import 'package:supastore/features/admin_feature/review/presentation/providers/admin_review_provider.dart';
import 'package:supastore/features/auth_feature/domain/usecases/logout.dart';



import 'admin_categories_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_reviews_page.dart';
import 'admin_settings_page.dart';
import 'admin_users_page.dart';

class AdminMainPage extends StatelessWidget {
  const AdminMainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminAccessProvider>(
      create: (_) =>
      getIt<AdminAccessProvider>()..loadAccess(),
      child: const _AdminMainView(),
    );
  }
}

class _AdminMainView extends StatefulWidget {
  const _AdminMainView();

  @override
  State<_AdminMainView> createState() =>
      _AdminMainViewState();
}

class _AdminMainViewState extends State<_AdminMainView> {
  int _selectedIndex = 0;

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

    debugPrint(
      'AUTH USER ID: ${user?.id}',
    );

    debugPrint(
      'AUTH PHONE: ${user?.phone}',
    );

    if (user == null) {
      debugPrint(
        'USER IS NULL - USER IS NOT LOGGED IN',
      );

      debugPrint(
        '====================================================',
      );

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

      debugPrint(
        'PROFILE: $profile',
      );

      final role = await supabase.rpc(
        'current_admin_role',
      );

      debugPrint(
        'CURRENT ADMIN ROLE: $role',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'ADMIN ACCESS TEST ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }

    debugPrint(
      '====================================================',
    );
  }

  Future<void> _logout() async {
    try {
      await getIt<SignOut>()();

      if (!mounted) {
        return;
      }

      context.go('/auth');
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'خروج از حساب انجام نشد.',
          ),
        ),
      );
    }
  }

  void _buildMenuItems(
      AdminAccessProvider accessProvider,
      ) {
    final List<_AdminMenuItem> items = [];

    if (accessProvider.isSuperAdmin) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Icons.dashboard_rounded,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'محصولات',
          icon: Icons.inventory_2_rounded,
          page: ChangeNotifierProvider<AdminProductProvider>(
            create: (_) =>
                getIt<AdminProductProvider>(),
            child: const AdminProductsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'دسته‌بندی‌ها',
          icon: Icons.category_rounded,
          page: ChangeNotifierProvider<AdminCategoryProvider>(
            create: (_) =>
                getIt<AdminCategoryProvider>(),
            child: const AdminCategoriesPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'سفارش‌ها',
          icon: Icons.shopping_bag_rounded,
          page: const AdminOrdersPage(),
        ),
        _AdminMenuItem(
          title: 'کاربران',
          icon: Icons.people_alt_rounded,
          page: ChangeNotifierProvider<AdminUserProvider>(
            create: (_) =>
                getIt<AdminUserProvider>(),
            child: AdminUsersPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'نظرات',
          icon: Icons.rate_review_rounded,
          page: ChangeNotifierProvider<AdminReviewProvider>(
            create: (_) =>
                getIt<AdminReviewProvider>(),
            child: const AdminReviewsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'تنظیمات',
          icon: Icons.settings_rounded,
          page: const AdminSettingsPage(),
        ),
      ]);
    } else if (accessProvider.isOrderManager) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Icons.dashboard_rounded,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'سفارش‌ها',
          icon: Icons.shopping_bag_rounded,
          page: const AdminOrdersPage(),
        ),
      ]);
    } else if (accessProvider.isProductManager) {
      items.addAll([
        _AdminMenuItem(
          title: 'داشبورد',
          icon: Icons.dashboard_rounded,
          page: const AdminDashboardPage(),
        ),
        _AdminMenuItem(
          title: 'محصولات',
          icon: Icons.inventory_2_rounded,
          page: ChangeNotifierProvider<AdminProductProvider>(
            create: (_) =>
                getIt<AdminProductProvider>(),
            child: const AdminProductsPage(),
          ),
        ),
        _AdminMenuItem(
          title: 'دسته‌بندی‌ها',
          icon: Icons.category_rounded,
          page: ChangeNotifierProvider<AdminCategoryProvider>(
            create: (_) =>
                getIt<AdminCategoryProvider>(),
            child: const AdminCategoriesPage(),
          ),
        ),
      ]);
    }

    _menuItems = items;

    if (_selectedIndex >= _menuItems.length) {
      _selectedIndex = 0;
    }
  }

  void _selectPage(int index) {
    if (index < 0 || index >= _menuItems.length) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accessProvider =
    context.watch<AdminAccessProvider>();

    if (accessProvider.isLoading) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Color(0xFFF7F7F8),
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
          backgroundColor: Color(0xFFF7F7F8),
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
          backgroundColor: Color(0xFFF7F7F8),
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFE21B23),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            _menuItems[_selectedIndex].title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        drawer: _buildDrawer(),
        body: IndexedStack(
          index: _selectedIndex,
          children: _menuItems
              .map(
                (item) => item.page,
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final accessProvider =
    context.read<AdminAccessProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20.w,
                24.h,
                20.w,
                24.h,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE21B23),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 34.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'SupaStore',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getRoleTitle(
                      accessProvider.adminRole,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 12.h,
                ),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];

                  return _drawerItem(
                    index: index,
                    icon: item.icon,
                    title: item.title,
                  );
                },
              ),
            ),
            const Divider(
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'خروج از حساب',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 3.h,
      ),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFFFFE9EA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(
          icon,
          color: selected
              ? const Color(0xFFE21B23)
              : Colors.black54,
        ),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
            color: selected
                ? const Color(0xFFE21B23)
                : Colors.black87,
          ),
        ),
        onTap: () => _selectPage(index),
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