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

import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/home_search_bar.dart';
import 'package:supastore/features/product_feature/presentation/widgets/popular_products_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_horizontal_list.dart';

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
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    await context
        .read<FavoriteProvider>()
        .loadFavorites(
      userId: user.id,
    );
  }

  // ============================================================
  // LOAD CART
  // ============================================================

  Future<void> _loadCart() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    await context
        .read<CartProvider>()
        .loadCart(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<CartProvider>(),

      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics:
            const BouncingScrollPhysics(),

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
              // BANNER
              // ==================================================

              SliverToBoxAdapter(
                child: ChangeNotifierProvider(
                  create: (_) =>
                      getIt<BannerProvider>(),

                  child:
                  const BannerSlider(),
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
                  create: (_) =>
                      getIt<CategoryProvider>(),

                  child:
                  CategoryHorizontalList(
                    onCategoryTap:
                        (category) {
                      context.pushNamed(
                        'category',
                        extra: category,
                      );
                    },
                  ),
                ),
              ),

              // ==================================================
              // NEWEST PRODUCTS HEADER
              // ==================================================

              SliverToBoxAdapter(
                child: SectionHeader(
                  title:
                  'جدیدترین محصولات',
                ),
              ),

              // ==================================================
              // NEWEST PRODUCTS
              // ==================================================

              SliverToBoxAdapter(
                child: ChangeNotifierProvider(
                  create: (_) =>
                      getIt<ProductProvider>(),

                  child:
                  const _NewestProducts(),
                ),
              ),

              // ==================================================
              // FLASH SALE
              // ==================================================

              SliverToBoxAdapter(
                child: ChangeNotifierProvider(
                  create: (_) =>
                      getIt<FlashSaleProvider>(),

                  child:
                  FlashSaleSection(
                    onProductTap:
                        (product) {
                      context.pushNamed(
                        'product-details',
                        extra: product,
                      );
                    },

                    onSeeAll: () {
                      debugPrint(
                        'See All Flash Sales',
                      );
                    },
                  ),
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
                  create: (_) =>
                  getIt<BannerProvider>()
                    ..loadPromotionalBanners(),

                  child:
                  const _PromotionalBanners(),
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
                  title:
                  'پرفروش ترین ها',

                  onSeeAll: () {
                    debugPrint(
                      'See All Categories',
                    );
                  },
                ),
              ),

              // ==================================================
              // POPULAR PRODUCTS
              // ==================================================

              SliverToBoxAdapter(
                child:
                const PopularProductsSection(),
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
              // FOOTER
              // ==================================================

              SliverToBoxAdapter(
                child:
                const HomeFooter(),
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
      ),
    );
  }
}

// ==================================================================
// PROMOTIONAL BANNERS
// ==================================================================

class _PromotionalBanners
    extends StatelessWidget {
  const _PromotionalBanners();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Consumer<BannerProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        if (provider.isPromotionalLoading) {
          return SizedBox(
            height: 180.h,
            child: const Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        if (provider.promotionalError != null) {
          return const SizedBox.shrink();
        }

        if (provider.promotionalBanners.isEmpty) {
          return const SizedBox.shrink();
        }

        return PromotionalBannerGrid(
          banners:
          provider.promotionalBanners,
        );
      },
    );
  }
}

// ==================================================================
// NEWEST PRODUCTS
// ==================================================================

class _NewestProducts
    extends StatefulWidget {
  const _NewestProducts();

  @override
  State<_NewestProducts> createState() =>
      _NewestProductsState();
}

class _NewestProductsState
    extends State<_NewestProducts> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ProductProvider>()
          .loadNewestProducts();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Consumer<ProductProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        if (provider.isLoading) {
          return SizedBox(
            height: 300.h,
            child: const Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

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

        return ProductHorizontalList(
          products:
          provider.products,

          onProductTap: (
              product,
              ) {
            context.pushNamed(
              'product-details',
              extra: product,
            );
          },

          onFavoriteTap: (
              product,
              ) {
            debugPrint(
              'Favorite: ${product.id}',
            );
          },
        );
      },
    );
  }
}