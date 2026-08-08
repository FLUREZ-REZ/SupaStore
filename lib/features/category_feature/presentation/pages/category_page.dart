import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/category_feature/presentation/providers/category_product_provider.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_grid.dart';



class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final CategoryEntity category;


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => getIt<CategoryProductProvider>()
        ..loadProducts(
          categoryId: category.id,
        ),

      child: _CategoryView(
        category: category,
      ),
    );
  }
}



class _CategoryView extends StatelessWidget {
  const _CategoryView({
    required this.category,
  });

  final CategoryEntity category;


  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(

        backgroundColor: Colors.grey.shade50,


        appBar: AppBar(

          backgroundColor: AppColors.primary,

          centerTitle: true,

          title: Text(
            category.name,
            style: AppTextStyles.second_title_section,
          ),

        ),



        body: Consumer<CategoryProductProvider>(

          builder: (
              context,
              provider,
              child,
              ) {

            // ==========================
            // Loading
            // ==========================

            if (provider.isLoading) {

              return const Center(
                child: CircularProgressIndicator(),
              );

            }



            // ==========================
            // Error
            // ==========================

            if (provider.error != null) {

              return Center(

                child: Padding(

                  padding:
                  EdgeInsets.all(20.w),

                  child: Column(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      const Icon(
                        Icons.error_outline,
                        size: 50,
                      ),

                      SizedBox(
                        height: 12.h,
                      ),

                      Text(
                        provider.error!,
                        textAlign:
                        TextAlign.center,
                      ),

                      SizedBox(
                        height: 16.h,
                      ),

                      ElevatedButton(
                        onPressed: () {

                          provider.loadProducts(
                            categoryId:
                            category.id,
                          );

                        },

                        child:
                        const Text(
                          'تلاش مجدد',
                        ),
                      ),

                    ],

                  ),

                ),

              );

            }



            // ==========================
            // Empty
            // ==========================

            if (provider.products.isEmpty) {

              return const Center(

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                    ),

                    SizedBox(
                      height: 12,
                    ),

                    Text(
                      'محصولی در این دسته وجود ندارد',
                    ),

                  ],

                ),

              );

            }



            // ==========================
            // Products
            // ==========================

            return RefreshIndicator(

              onRefresh:
              provider.refresh,

              child: NotificationListener<
                  ScrollNotification>(

                onNotification:
                    (notification) {

                  if (notification
                  is ScrollEndNotification) {

                    final metrics =
                        notification.metrics;


                    if (metrics.pixels >=
                        metrics.maxScrollExtent -
                            300) {

                      provider.loadMore();

                    }

                  }

                  return false;

                },

                child: ProductGrid(

                  products:
                  provider.products,

                  onProductTap:
                      (product) {

                    context.pushNamed(
                      'product-details',
                      extra: product,
                    );

                  },

                ),

              ),

            );

          },

        ),

      ),

    );

  }
}