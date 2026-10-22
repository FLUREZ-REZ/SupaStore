
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';
import 'package:supastore/features/favorite_feature/presentation/providers/favorite_provider.dart';
import 'package:supastore/features/flash_sale_feature/presentation/providers/flash_sale_provider.dart';

import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';

import 'package:supastore/features/home_feature/presentation/widgets/banner_slider.dart';
import 'package:supastore/features/home_feature/presentation/widgets/category_horizontal_list.dart';
import 'package:supastore/features/home_feature/presentation/widgets/flash_sale_section.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_appbar.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_footer.dart';
import 'package:supastore/features/home_feature/presentation/widgets/promotional_banner_grid.dart';
import 'package:supastore/features/home_feature/presentation/widgets/section_header.dart';
import 'package:supastore/features/home_feature/presentation/widgets/single_banner.dart';

import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/home_search_bar.dart';
import 'package:supastore/features/product_feature/presentation/widgets/popular_products_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_horizontal_list.dart';

import 'package:supastore/features/notification_feature/presentation/providers/notifications_provider.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/presentation/providers/order_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
      _loadCart();
    });
  }

  // ============================================================
  // LOAD FAVORITES
  // ============================================================

  Future<void> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null || !mounted) {
      return;
    }

    await context.read<FavoriteProvider>().loadFavorites(
      userId: user.id,
    );
  }

  // ============================================================
  // LOAD CART
  // ============================================================

  Future<void> _loadCart() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null || !mounted) {
      return;
    }

    await getIt<CartProvider>().loadCart(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(
          value: getIt<CartProvider>(),
        ),
        ChangeNotifierProvider<NotificationsProvider>.value(
          value: getIt<NotificationsProvider>(),
        ),
      ],
      child: const _HomeNotificationListener(
        child: _HomePageContent(),
      ),
    );
  }
}

// ==================================================================
// HOME PAGE CONTENT
// ==================================================================

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ==================================================
            // APP BAR
            // ==================================================

            const SliverToBoxAdapter(
              child: HomeAppBar(),
            ),

            // ==================================================
            // SEARCH
            // ==================================================

            SliverToBoxAdapter(
              child: HomeSearchBar(),
            ),

            // ==================================================
            // HERO BANNER
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<BannerProvider>()
                  ..loadHeroBanners(),
                child: const BannerSlider(),
              ),
            ),

            // ==================================================
            // CATEGORIES HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'دسته‌بندی‌ها',
                onSeeAll: () {
                  context.pushNamed('categories');
                },
              ),
            ),

            // ==================================================
            // CATEGORIES
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<CategoryProvider>(),
                child: CategoryHorizontalList(
                  onCategoryTap: (category) {
                    context.pushNamed(
                      'category',
                      extra: category,
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // FLASH SALE
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<FlashSaleProvider>()
                  ..fetchFlashSales(),
                child: FlashSaleSection(
                  onProductTap: (product) {
                    context.pushNamed(
                      'product-details',
                      extra: product,
                    );
                  },
                  onSeeAll: () {
                    context.pushNamed('flash-sale');
                  },
                ),
              ),
            ),

            // ==================================================
            // NEWEST PRODUCTS HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'جدیدترین محصولات',
                onSeeAll: () {
                  context.pushNamed('latest-products');
                },
              ),
            ),

            // ==================================================
            // NEWEST PRODUCTS
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<ProductProvider>(),
                child: const _NewestProducts(),
              ),
            ),

            // ==================================================
            // SPACE
            // ==================================================

            SliverToBoxAdapter(
              child: SizedBox(
                height: 25.h,
              ),
            ),

            // ==================================================
            // PROMOTIONAL BANNERS
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<BannerProvider>()
                  ..loadPromotionalBanners(),
                child: const _PromotionalBanners(),
              ),
            ),

            // ==================================================
            // SPACE
            // ==================================================

            SliverToBoxAdapter(
              child: SizedBox(
                height: 25.h,
              ),
            ),

            // ==================================================
            // POPULAR PRODUCTS HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'پرفروش‌ترین محصولات',
                onSeeAll: () {
                  context.pushNamed('popular-products');
                },
              ),
            ),

            // ==================================================
            // POPULAR PRODUCTS
            // ==================================================

            const SliverToBoxAdapter(
              child: PopularProductsSection(),
            ),

            // ==================================================
            // SPACE
            // ==================================================

            SliverToBoxAdapter(
              child: SizedBox(
                height: 20.h,
              ),
            ),

            // ==================================================
            // SINGLE BANNER
            // ==================================================

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<BannerProvider>()
                  ..loadSingleBanners(),
                child: const _SingleBannerSection(),
              ),
            ),

            // ==================================================
            // SPACE
            // ==================================================

            SliverToBoxAdapter(
              child: SizedBox(
                height: 24.h,
              ),
            ),

            // ==================================================
            // FOOTER
            // ==================================================

            const SliverToBoxAdapter(
              child: HomeFooter(),
            ),

            // ==================================================
            // BOTTOM SPACE
            // ==================================================

            SliverToBoxAdapter(
              child: SizedBox(
                height: 20.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// HOME ORDER NOTIFICATION POPUP
// ==================================================================

class _HomeNotificationListener extends StatefulWidget {
  final Widget child;

  const _HomeNotificationListener({
    required this.child,
  });

  @override
  State<_HomeNotificationListener> createState() =>
      _HomeNotificationListenerState();
}

class _HomeNotificationListenerState
    extends State<_HomeNotificationListener> {
  bool _checkingNotifications = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrderNotifications();
    });
  }

  // ============================================================
  // CHECK UNREAD ORDER NOTIFICATIONS
  // ============================================================

  Future<void> _checkOrderNotifications() async {
    if (!mounted || _checkingNotifications || _dialogShown) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    _checkingNotifications = true;

    try {
      final notificationProvider =
      context.read<NotificationsProvider>();

      await notificationProvider.loadNotifications();

      if (!mounted) {
        return;
      }

      final pendingNotifications =
      notificationProvider.notifications.where(
            (notification) =>
        notification.type == 'order_status' &&
            !notification.isRead,
      );

      if (pendingNotifications.isEmpty) {
        return;
      }

      // نمایش یک اعلان در هر بار ورود به صفحه اصلی
      final notification = pendingNotifications.first;

      _dialogShown = true;

      // اگر کاربر سفارش را انتخاب کند، شیء کامل سفارش برگردانده می‌شود.
      // اگر «متوجه شدم» را بزند، مقدار برگشتی null خواهد بود.
      final OrderEntity? selectedOrder =
      await showDialog<OrderEntity?>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              icon: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFFE21B23),
                  size: 34,
                ),
              ),
              title: Text(
                notification.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              content: Text(
                notification.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.8,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================
                    // VIEW ORDER BUTTON
                    // ==========================================

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE21B23),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 13.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () async {
                        final orderId = notification.orderId;

                        if (orderId == null || orderId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'شناسه سفارش در این اعلان موجود نیست.',
                              ),
                            ),
                          );
                          return;
                        }

                        final currentUser =
                            Supabase.instance.client.auth.currentUser;

                        if (currentUser == null) {
                          return;
                        }

                        try {
                          final orderProvider = getIt<OrderProvider>();

                          final order =
                          await orderProvider.findOrderById(
                            currentUser.id,
                            orderId,
                          );

                          if (!mounted) {
                            return;
                          }

                          if (order == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'سفارش موردنظر پیدا نشد. دوباره تلاش کنید.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(order);
                          }
                        } catch (e, stackTrace) {
                          debugPrint(
                            'Failed to load order from notification: $e',
                          );
                          debugPrintStack(stackTrace: stackTrace);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'دریافت اطلاعات سفارش با خطا مواجه شد.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'مشاهده سفارش',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // ==========================================
                    // ACKNOWLEDGE BUTTON
                    // ==========================================

                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'متوجه شدم',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      if (!mounted) {
        return;
      }

      // ثبت خوانده‌شدن پس از انتخاب یکی از دکمه‌ها
      final success =
      await notificationProvider.markNotificationAsRead(
        notification.id,
      );

      if (!success) {
        debugPrint(
          'Failed to mark notification as read: ${notification.id}',
        );
      }

      if (!mounted) {
        return;
      }

      // اگر سفارش انتخاب شده باشد، جزئیات همان سفارش باز می‌شود.
      if (selectedOrder != null) {
        context.pushNamed(
          'order-details',
          extra: selectedOrder,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Order notification popup error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _checkingNotifications = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ==================================================================
// PROMOTIONAL BANNERS
// ==================================================================

class _PromotionalBanners extends StatelessWidget {
  const _PromotionalBanners();

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // LOADING
        if (provider.isPromotionalLoading &&
            provider.promotionalBanners.isEmpty) {
          return SizedBox(
            height: 180.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ERROR
        if (provider.promotionalError != null &&
            provider.promotionalBanners.isEmpty) {
          debugPrint(
            'Promotional Banner Error: '
                '${provider.promotionalError}',
          );

          return const SizedBox.shrink();
        }

        // EMPTY
        if (provider.promotionalBanners.isEmpty) {
          return const SizedBox.shrink();
        }

        // GRID
        return PromotionalBannerGrid(
          banners: provider.promotionalBanners,
        );
      },
    );
  }
}

// ==================================================================
// SINGLE BANNER
// ==================================================================

class _SingleBannerSection extends StatelessWidget {
  const _SingleBannerSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // LOADING
        if (provider.isSingleLoading &&
            provider.singleBanners.isEmpty) {
          return SizedBox(
            height: 180.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ERROR
        if (provider.singleError != null &&
            provider.singleBanners.isEmpty) {
          debugPrint(
            'Single Banner Error: '
                '${provider.singleError}',
          );

          return const SizedBox.shrink();
        }

        // EMPTY
        if (provider.singleBanners.isEmpty) {
          return const SizedBox.shrink();
        }

        // GET FIRST SINGLE BANNER
        final banner = provider.singleBanners.first;

        // SINGLE BANNER WIDGET
        return SingleBanner(
          banner: banner,
          onTap: () {
            debugPrint(
              'Single Banner: ${banner.title}',
            );
          },
        );
      },
    );
  }
}

// ==================================================================
// NEWEST PRODUCTS
// ==================================================================

class _NewestProducts extends StatefulWidget {
  const _NewestProducts();

  @override
  State<_NewestProducts> createState() => _NewestProductsState();
}

class _NewestProductsState extends State<_NewestProducts> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ProductProvider>().loadNewestProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        // LOADING
        if (provider.isLoading) {
          return SizedBox(
            height: 300.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ERROR
        if (provider.error != null) {
          return SizedBox(
            height: 300.h,
            child: Center(
              child: Text(
                provider.error!,
              ),
            ),
          );
        }

        // EMPTY
        if (provider.products.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: Text(
                'محصولی یافت نشد',
              ),
            ),
          );
        }

        // PRODUCT LIST
        return ProductHorizontalList(
          products: provider.products,
          onProductTap: (product) {
            context.pushNamed(
              'product-details',
              extra: product,
            );
          },
          onFavoriteTap: (product) {
            debugPrint(
              'Favorite: ${product.id}',
            );
          },
        );
      },
    );
  }
}
