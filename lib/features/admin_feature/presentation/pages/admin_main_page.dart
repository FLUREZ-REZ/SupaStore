import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/category/presentation/providers/admin_category_provider.dart';
import 'package:supastore/features/admin_feature/presentation/providers/admin_product_provider.dart';

import 'admin_categories_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_reviews_page.dart';
import 'admin_settings_page.dart';
import 'admin_users_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  final List<String> _titles = const [
    'داشبورد',
    'محصولات',
    'دسته‌بندی‌ها',
    'سفارش‌ها',
    'کاربران',
    'نظرات',
    'تنظیمات',
  ];

  @override
  void initState() {
    super.initState();

    _pages = [
      const AdminDashboardPage(),

      ChangeNotifierProvider<AdminProductProvider>(
        create: (_) => getIt<AdminProductProvider>(),
        child: const AdminProductsPage(),
      ),

      ChangeNotifierProvider<AdminCategoryProvider>(
        create: (_) => getIt<AdminCategoryProvider>(),
        child: const AdminCategoriesPage(),
      ),

      const AdminOrdersPage(),
      const AdminUsersPage(),
      const AdminReviewsPage(),
      const AdminSettingsPage(),
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            _titles[_selectedIndex],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Drawer به صورت طبیعی در RTL از سمت راست باز می‌شود.
        drawer: _buildDrawer(),

        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
    );
  }

  // =====================================================
  // Drawer
  // =====================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            // =================================================
            // Header
            // =================================================

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
                    'پنل مدیریت',
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

            // =================================================
            // Menu
            // =================================================

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 12.h,
                ),
                children: [
                  _drawerItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    title: 'داشبورد',
                  ),

                  _drawerItem(
                    index: 1,
                    icon: Icons.inventory_2_rounded,
                    title: 'محصولات',
                  ),

                  _drawerItem(
                    index: 2,
                    icon: Icons.category_rounded,
                    title: 'دسته‌بندی‌ها',
                  ),

                  _drawerItem(
                    index: 3,
                    icon: Icons.shopping_bag_rounded,
                    title: 'سفارش‌ها',
                  ),

                  _drawerItem(
                    index: 4,
                    icon: Icons.people_alt_rounded,
                    title: 'کاربران',
                  ),

                  _drawerItem(
                    index: 5,
                    icon: Icons.rate_review_rounded,
                    title: 'نظرات',
                  ),

                  _drawerItem(
                    index: 6,
                    icon: Icons.settings_rounded,
                    title: 'تنظیمات',
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
            ),

            // =================================================
            // Logout
            // =================================================

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

                onTap: () {
                  // در مرحله بعد logout را
                  // به AuthRepository وصل می‌کنیم.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // Drawer Item
  // =====================================================

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

        selectedTileColor:
        const Color(0xFFFFE9EA),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),

        // در RTL leading در سمت راست قرار می‌گیرد.
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
}