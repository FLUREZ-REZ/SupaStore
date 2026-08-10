import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/cart_feature/presentation/pages/cart_page.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/category_feature/presentation/pages/category_list_page.dart';
import 'package:supastore/features/home_feature/presentation/pages/favorite_page.dart';
import 'package:supastore/features/home_feature/presentation/pages/home_page.dart';

import 'package:supastore/features/home_feature/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:supastore/features/profile_feature/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomePage(),
      CategoryListPage(),
      CartPage(),
      FavoritePage(),
      ProfilePage(),
    ];
  }

  void _changeTab(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<CartProvider>(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),

        bottomNavigationBar:
        CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
        ),
      ),
    );
  }
}