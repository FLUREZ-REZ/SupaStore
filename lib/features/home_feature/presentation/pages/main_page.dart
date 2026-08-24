import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/category_feature/presentation/pages/category_list_page.dart';

import 'package:supastore/features/home_feature/presentation/pages/home_page.dart';
import 'package:supastore/features/home_feature/presentation/widgets/custom_bottom_navigation_bar.dart';

import 'package:supastore/features/profile_feature/presentation/pages/profile_page.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ============================================================
  // CURRENT TAB
  // ============================================================

  int _currentIndex = 0;

  // ============================================================
  // PAGES
  // ============================================================

  late final List<Widget> _pages;

  // ============================================================
  // PROVIDERS
  // ============================================================

  late final CartProvider _cartProvider;

  late final ProfileProvider _profileProvider;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // Get providers
    // ------------------------------------------------------------

    _cartProvider = getIt<CartProvider>();

    _profileProvider = getIt<ProfileProvider>();

    // ------------------------------------------------------------
    // Pages
    // ------------------------------------------------------------

    _pages = const [
      HomePage(),
      CategoryListPage(),
      CartPage(),
      ProfilePage(),
    ];

    // ------------------------------------------------------------
    // Load profile
    // ------------------------------------------------------------

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user != null) {
      _profileProvider.loadProfile(
        userId: user.id,
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    // ------------------------------------------------------------
    // IMPORTANT:
    //
    // این Providerها از getIt گرفته شده‌اند.
    // بنابراین اینجا dispose نمی‌کنیم.
    // مدیریت lifecycle آنها با getIt است.
    // ------------------------------------------------------------

    super.dispose();
  }

  // ============================================================
  // CHANGE TAB
  // ============================================================

  void _changeTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    // ============================================================
    // USER CHECK
    // ============================================================

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید.',
          ),
        ),
      );
    }

    // ============================================================
    // PROVIDERS
    // ============================================================

    return MultiProvider(
      providers: [
        // --------------------------------------------------------
        // CART PROVIDER
        // --------------------------------------------------------

        ChangeNotifierProvider<CartProvider>.value(
          value: _cartProvider,
        ),

        // --------------------------------------------------------
        // PROFILE PROVIDER
        // --------------------------------------------------------

        ChangeNotifierProvider<ProfileProvider>.value(
          value: _profileProvider,
        ),
      ],

      // ==========================================================
      // APP
      // ==========================================================

      child: Scaffold(
        // --------------------------------------------------------
        // BODY
        // --------------------------------------------------------

        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),

        // --------------------------------------------------------
        // BOTTOM NAVIGATION
        // --------------------------------------------------------

        bottomNavigationBar:
        CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}