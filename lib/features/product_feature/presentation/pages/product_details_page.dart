import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

import 'package:supastore/features/product_feature/presentation/providers/product_image_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_specification_provider.dart';
import 'package:supastore/features/product_feature/presentation/providers/related_products_provider.dart';

import 'package:supastore/features/product_feature/presentation/widgets/add_to_cart_bar.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_description_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_image_slider.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_rating_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_specifications_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/product_title_section.dart';
import 'package:supastore/features/product_feature/presentation/widgets/related_products_section.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  // ==========================================================
  // ADD TO CART
  // ==========================================================

  Future<void> _addToCart(
      BuildContext context,
      ) async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'برای افزودن محصول ابتدا وارد حساب کاربری شوید.',
          ),
        ),
      );

      return;
    }

    await context.read<CartProvider>().addToCart(
      userId: user.id,
      productId: product.id,
    );

    if (!context.mounted) return;

    final cartProvider =
    context.read<CartProvider>();

    if (cartProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cartProvider.error!,
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'محصول به سبد خرید اضافه شد',
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        // ====================================================
        // PRODUCT IMAGE PROVIDER
        // ====================================================

        ChangeNotifierProvider<ProductImageProvider>(
          create: (_) {
            final provider =
            getIt<ProductImageProvider>();

            provider.loadImages(
              product.id,
            );

            return provider;
          },
        ),

        // ====================================================
        // PRODUCT SPECIFICATION PROVIDER
        // ====================================================

        ChangeNotifierProvider<
            ProductSpecificationProvider>(
          create: (_) {
            final provider =
            getIt<ProductSpecificationProvider>();

            provider.loadSpecifications(
              product.id,
            );

            return provider;
          },
        ),

        // ====================================================
        // RELATED PRODUCTS PROVIDER
        // ====================================================

        ChangeNotifierProvider<
            RelatedProductsProvider>(
          create: (_) {
            final provider =
            getIt<RelatedProductsProvider>();

            provider.loadRelatedProducts(
              categoryId: product.categoryId,
              productId: product.id,
              limit: 6,
            );

            return provider;
          },
        ),
      ],

      child: Directionality(
        textDirection: TextDirection.rtl,

        child: Scaffold(
          backgroundColor:
          const Color(0xFFF5F5F5),

          // ==================================================
          // APP BAR
          // ==================================================

          appBar: AppBar(
            backgroundColor:
            AppColors.primary,

            elevation: 0,

            centerTitle: true,

            title: Text(
              'جزئیات محصول',
              style:
              AppTextStyles.second_title_section,
            ),

            actions: [

              IconButton(
                onPressed: () {},

                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
              ),

              IconButton(
                onPressed: () {},

                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // ==================================================
          // ADD TO CART BAR
          // ==================================================

          bottomNavigationBar:
          RepaintBoundary(
            child: AddToCartBar(
              product: product,
              onAddToCart: () {
                _addToCart(context);
              },
            ),
          ),

          // ==================================================
          // BODY
          // ==================================================

          body: CustomScrollView(
            physics:
            const BouncingScrollPhysics(),

            slivers: [

              // =================================================
              // PRODUCT IMAGE
              // =================================================

              SliverAppBar(
                automaticallyImplyLeading:
                false,

                pinned: false,

                floating: false,

                snap: false,

                stretch: false,

                elevation: 0,

                backgroundColor:
                Colors.white,

                expandedHeight: 420.h,

                toolbarHeight: 0,

                collapsedHeight: 0,

                flexibleSpace:
                FlexibleSpaceBar(
                  collapseMode:
                  CollapseMode.parallax,

                  background:
                  RepaintBoundary(
                    child:
                    _ProductImageArea(
                      product: product,
                    ),
                  ),
                ),
              ),

              // =================================================
              // PRODUCT CONTENT
              // =================================================

              SliverToBoxAdapter(
                child:
                _ProductContentCard(
                  product: product,
                ),
              ),

              // =================================================
              // BOTTOM SPACE
              // =================================================

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 30.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// PRODUCT IMAGE AREA
// =============================================================

class _ProductImageArea
    extends StatelessWidget {

  const _ProductImageArea({
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageProvider =
    context.watch<ProductImageProvider>();

    // =========================================================
    // LOADING
    // =========================================================

    if (imageProvider.isLoading &&
        imageProvider.images.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,

        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // =========================================================
    // IMAGES
    // =========================================================

    final List<String> images =
    imageProvider.images
        .map(
          (image) => image.imageUrl,
    )
        .where(
          (url) => url.isNotEmpty,
    )
        .toList();

    // =========================================================
    // FALLBACK
    // =========================================================

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,

        child: ProductImageSlider(
          images: [
            product.thumbnail,
          ],
        ),
      );
    }

    // =========================================================
    // REAL PRODUCT IMAGES
    // =========================================================

    return Container(
      width: double.infinity,
      color: Colors.white,

      child: ProductImageSlider(
        images: images,
      ),
    );
  }
}


// =============================================================
// PRODUCT CONTENT CARD
// =============================================================

class _ProductContentCard
    extends StatelessWidget {

  const _ProductContentCard({
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color:
        const Color(0xFFF5F5F5),

        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),

      clipBehavior:
      Clip.antiAlias,

      child: Column(
        children: [

          // ==================================================
          // HANDLE
          // ==================================================

          Padding(
            padding: EdgeInsets.only(
              top: 10.h,
              bottom: 4.h,
            ),

            child: Container(
              width: 42.w,
              height: 4.h,

              decoration: BoxDecoration(
                color:
                Colors.grey.shade400,

                borderRadius:
                BorderRadius.circular(
                  20.r,
                ),
              ),
            ),
          ),

          // ==================================================
          // TITLE
          // ==================================================

          ProductTitleSection(
            product: product,
          ),

          // ==================================================
          // RATING
          // ==================================================

          ProductRatingSection(
            product: product,
          ),

          // ==================================================
          // DESCRIPTION
          // ==================================================

          ProductDescriptionSection(
            product: product,
          ),

          // ==================================================
          // SPECIFICATIONS
          // ==================================================

          Selector<
              ProductSpecificationProvider,
              List>(
            selector: (
                _,
                provider,
                ) =>
            provider.specifications,

            builder: (
                context,
                specifications,
                child,
                ) {
              return ProductSpecificationsSection(
                specifications:
                specifications.cast(),
              );
            },
          ),

          // ==================================================
          // RELATED PRODUCTS
          // ==================================================

          Selector<
              RelatedProductsProvider,
              List<ProductEntity>>(
            selector: (
                _,
                provider,
                ) =>
            provider.products,

            builder: (
                context,
                products,
                child,
                ) {

              // ==============================================
              // LOADING
              // ==============================================

              if (products.isEmpty) {
                final provider =
                context.read<
                    RelatedProductsProvider>();

                if (provider.isLoading) {
                  return Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 25.h,
                    ),

                    child:
                    const Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  );
                }

                return const SizedBox.shrink();
              }

              // ==============================================
              // RELATED PRODUCTS
              // ==============================================

              return RelatedProductsSection(
                products: products,

                onProductTap: (
                    relatedProduct,
                    ) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsPage(
                            product:
                            relatedProduct,
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}