import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (
          context,
          cartProvider,
          child,
          ) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, -2),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 65.h,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'خانه',
                      index: 0,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),

                    _NavItem(
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category,
                      label: 'دسته‌بندی',
                      index: 1,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),

                    _CartNavItem(
                      count: cartProvider.totalItems,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),


                    _NavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'پروفایل',
                      index: 4,
                      currentIndex: currentIndex,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected =
        index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? activeIcon
                  : icon,
              size: 24.sp,
            ),

            SizedBox(height: 3.h),

            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  const _CartNavItem({
    required this.count,
    required this.currentIndex,
    required this.onTap,
  });

  final int count;
  final int currentIndex;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected =
        currentIndex == 2;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(2),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected
                      ? Icons.shopping_cart
                      : Icons.shopping_cart_outlined,
                  size: 24.sp,
                ),

                if (count > 0)
                  Positioned(
                    right: -8.w,
                    top: -8.h,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      decoration:
                      const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment:
                      Alignment.center,
                      child: Text(
                        count > 99
                            ? '99+'
                            : count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 3.h),

            Text(
              'سبد خرید',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}