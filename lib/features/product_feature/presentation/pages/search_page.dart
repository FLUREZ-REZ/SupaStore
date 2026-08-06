import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/product_feature/presentation/providers/search_provider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_grid.dart';


class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SearchProvider>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            "جستجوی محصولات",
            style: AppTextStyles.second_title_section,
          ),
        ),

        body: Column(
          children: [

            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(

                autofocus: true,


                onChanged: provider.search,


                onSubmitted: (value){

                  provider.addSearchHistory(value);

                },


                decoration: InputDecoration(

                  hintText: "نام محصول را وارد کنید...",


                  prefixIcon: const Icon(
                    Icons.search,
                  ),


                  border: OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(14.r),

                  ),

                ),

              )
            ),

            Expanded(
              child: Builder(
                builder: (_) {

                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Text(provider.error!),
                    );
                  }

                  if (provider.products.isEmpty) {

                    if (provider.history.isNotEmpty) {

                      return ListView(
                        children: [

                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  "جستجوهای اخیر",
                                  style: AppTextStyles.productCard,
                                ),


                                TextButton(
                                  onPressed: () {
                                    provider.clearHistory();
                                  },
                                  child: const Text(
                                    "پاک کردن",
                                  ),
                                ),

                              ],
                            ),
                          ),



                          ...provider.history.map(

                                (item) => ListTile(

                              leading: const Icon(
                                Icons.history,
                              ),

                              title: Text(item),


                              onTap: () {

                                provider.search(item);

                              },

                            ),

                          ),

                        ],
                      );

                    }


                    return const Center(
                      child: Text(
                        "محصولی یافت نشد",
                      ),
                    );

                  }



                  return ProductGrid(
                    products: provider.products,

                    onProductTap: (product) {

                      context.pushNamed(
                        "product-details",
                        extra: product,
                      );

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}