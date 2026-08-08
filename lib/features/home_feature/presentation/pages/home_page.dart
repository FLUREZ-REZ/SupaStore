import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';
import 'package:supastore/features/home_feature/presentation/widgets/banner_slider.dart';
import 'package:supastore/features/home_feature/presentation/widgets/category_horizontal_list.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_appbar.dart';
import 'package:supastore/features/home_feature/presentation/widgets/section_header.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/home_search_bar.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_horizontal_list.dart';


class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [

            /// AppBar
            SliverToBoxAdapter(
              child: const HomeAppBar(),
            ),

            /// Search
            SliverToBoxAdapter(
              child: HomeSearchBar(),
            ),

            /// Banner
            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<BannerProvider>(),
                child: const BannerSlider(),
              ),
            ),


            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'دسته‌بندی‌ها',
                onSeeAll: () {
                  debugPrint('See All Categories');
                },
              ),
            ),

            /// Categories
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

            SliverToBoxAdapter(
              child: SectionHeader(
                title: "جدیدترین محصولات",
              ),
            ),

            SliverToBoxAdapter(
              child: ChangeNotifierProvider(
                create: (_) => getIt<ProductProvider>(),
                child: const _NewestProducts(),
              ),
            ),

            /// Best Seller
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280.h,
              ),
            ),

            /// Discount
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280.h,
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.only(
                bottom: 30.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewestProducts extends StatefulWidget {
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
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(

      builder: (context, provider, child) {

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

          onProductTap: (product) {
            context.pushNamed(
              'product-details',
              extra: product,
            );
          },

          onFavoriteTap: (product) {

            debugPrint(product.brandName ?? 'بدون برند');

          },

        );
      },
    );
  }
}