import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/home_feature/presentation/providers/banner_provider.dart';
import 'package:supastore/features/home_feature/presentation/widgets/banner_slider.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_appbar.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_search_bar.dart';

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

            /// Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120.h,
              ),
            ),

            /// Best Seller
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280.h,
              ),
            ),

            /// New Products
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