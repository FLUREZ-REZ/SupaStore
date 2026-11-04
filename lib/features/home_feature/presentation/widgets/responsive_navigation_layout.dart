
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

class ResponsiveNavigationLayout extends StatelessWidget {
  const ResponsiveNavigationLayout({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.child,
  });

  final int currentIndex;
  final Function(int index) onTap;
  final Widget child;

  static const Color _primaryColor = Color(0xFFE21B23);
  static const Color _backgroundColor = Colors.white;
  static const Color _textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cartCount = cartProvider.totalItems;

            // Mobile: کمتر از 600
            if (width < 600) {
              return Column(
                children: [
                  Expanded(
                    child: child,
                  ),
                  _MobileNavigation(
                    currentIndex: currentIndex,
                    onTap: onTap,
                    cartCount: cartCount,
                  ),
                ],
              );
            }

            // Tablet: از 600 تا 1023
            if (width < 1024) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    _TabletNavigation(
                      currentIndex: currentIndex,
                      onTap: onTap,
                      cartCount: cartCount,
                    ),
                    Expanded(
                      child: child,
                    ),
                  ],
                ),
              );
            }

            // Desktop: 1024 به بالا
            return Column(
              children: [
                _DesktopNavigation(
                  currentIndex: currentIndex,
                  onTap: onTap,
                  cartCount: cartCount,
                ),
                Expanded(
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================
// Navigation Data
// ============================================================

class _NavigationData {
  static const List<_NavigationItemData> items = [
    _NavigationItemData(
      icon: Iconsax.home_2_copy,
      activeIcon: Iconsax.home_2,
      label: 'خانه',
      index: 0,
    ),
    _NavigationItemData(
      icon: Iconsax.category_copy,
      activeIcon: Iconsax.category,
      label: 'دسته‌بندی',
      index: 1,
    ),
    _NavigationItemData(
      icon: Iconsax.shopping_cart_copy,
      activeIcon: Iconsax.shopping_cart,
      label: 'سبد خرید',
      index: 2,
    ),
    _NavigationItemData(
      icon: Iconsax.user_copy,
      activeIcon: Iconsax.user,
      label: 'پروفایل',
      index: 3,
    ),
  ];
}

class _NavigationItemData {
  const _NavigationItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
}

// ============================================================
// Mobile Navigation
// ============================================================

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
  });

  final int currentIndex;
  final Function(int index) onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
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
        top: false,
        child: SizedBox(
          height: 65,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: _NavigationData.items.map((item) {
                return Expanded(
                  child: _MobileNavigationItem(
                    item: item,
                    isSelected: currentIndex == item.index,
                    cartCount: item.index == 2 ? cartCount : 0,
                    onTap: () => onTap(item.index),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavigationItem extends StatelessWidget {
  const _MobileNavigationItem({
    required this.item,
    required this.isSelected,
    required this.cartCount,
    required this.onTap,
  });

  final _NavigationItemData item;
  final bool isSelected;
  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFFE21B23)
        : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavigationIcon(
            item: item,
            isSelected: isSelected,
            cartCount: cartCount,
            iconSize: 24,
            badgeSize: 18,
          ),

          const SizedBox(height: 4),

          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight:
              isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Tablet Navigation
// ============================================================

class _TabletNavigation extends StatelessWidget {
  const _TabletNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
  });

  final int currentIndex;
  final Function(int index) onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(-2, 0),
            color: Colors.black.withOpacity(0.035),
          ),
        ],
      ),
      child: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE21B23),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Iconsax.bag_2_copy,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: Column(
                  children: _NavigationData.items.map((item) {
                    return _TabletNavigationItem(
                      item: item,
                      isSelected: currentIndex == item.index,
                      cartCount:
                      item.index == 2 ? cartCount : 0,
                      onTap: () => onTap(item.index),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletNavigationItem extends StatelessWidget {
  const _TabletNavigationItem({
    required this.item,
    required this.isSelected,
    required this.cartCount,
    required this.onTap,
  });

  final _NavigationItemData item;
  final bool isSelected;
  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFE21B23);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      child: Material(
        color: isSelected
            ? primaryColor.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: double.infinity,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavigationIcon(
                  item: item,
                  isSelected: isSelected,
                  cartCount: cartCount,
                  iconSize: 23,
                  badgeSize: 17,
                ),

                const SizedBox(height: 7),

                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.shade600,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Desktop Navigation
// ============================================================

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
  });

  final int currentIndex;
  final Function(int index) onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.045),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1280,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  // Store logo
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE21B23),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.bag_2_copy,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 28),

                  // Navigation items
                  Expanded(
                    child: Row(
                      children: _NavigationData.items.map((item) {
                        return _DesktopNavigationItem(
                          item: item,
                          isSelected: currentIndex == item.index,
                          cartCount:
                          item.index == 2 ? cartCount : 0,
                          onTap: () => onTap(item.index),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNavigationItem extends StatelessWidget {
  const _DesktopNavigationItem({
    required this.item,
    required this.isSelected,
    required this.cartCount,
    required this.onTap,
  });

  final _NavigationItemData item;
  final bool isSelected;
  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFE21B23);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  item: item,
                  isSelected: isSelected,
                  cartCount: cartCount,
                  iconSize: 21,
                  badgeSize: 17,
                ),

                const SizedBox(width: 9),

                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? primaryColor
                        : const Color(0xFF444444),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Shared Navigation Icon & Cart Badge
// ============================================================

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.item,
    required this.isSelected,
    required this.cartCount,
    required this.iconSize,
    required this.badgeSize,
  });

  final _NavigationItemData item;
  final bool isSelected;
  final int cartCount;
  final double iconSize;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFFE21B23)
        : Colors.grey.shade600;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isSelected ? item.activeIcon : item.icon,
          size: iconSize,
          color: color,
        ),

        if (item.index == 2 && cartCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                cartCount > 99 ? '99+' : cartCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: badgeSize <= 17 ? 8 : 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
