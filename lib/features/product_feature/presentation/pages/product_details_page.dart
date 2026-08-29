import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import '../../domain/entities/product_entity.dart';

import '../../../cart_feature/presentation/providers/cart_provider.dart';

import '../providers/product_image_provider.dart';
import '../providers/product_specification_provider.dart';

import '../widgets/add_to_cart_bar.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_rating_section.dart';
import '../widgets/product_specifications_section.dart';
import '../widgets/product_title_section.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        // =====================================================
        // APP BAR
        // =====================================================

        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,

          title: Text(
            'جزئیات محصول',
            style: AppTextStyles.second_title_section,
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

        // =====================================================
        // ADD TO CART BAR
        // =====================================================

        bottomNavigationBar: RepaintBoundary(
          child: AddToCartBar(
            product: product,

            onAddToCart: () async {
              final user =
                  Supabase.instance.client.auth.currentUser;

              // -------------------------------------------------
              // USER NOT LOGGED IN
              // -------------------------------------------------

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

              // -------------------------------------------------
              // ADD TO CART
              // -------------------------------------------------

              await context.read<CartProvider>().addToCart(
                userId: user.id,
                productId: product.id,
              );

              if (!context.mounted) return;

              final cartProvider =
              context.read<CartProvider>();

              // -------------------------------------------------
              // ERROR
              // -------------------------------------------------

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

              // -------------------------------------------------
              // SUCCESS
              // -------------------------------------------------

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'محصول به سبد خرید اضافه شد',
                  ),
                ),
              );
            },
          ),
        ),

        // =====================================================
        // BODY
        // =====================================================

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [

            // =================================================
            // PRODUCT IMAGE GALLERY
            // =================================================

            SliverAppBar(
              automaticallyImplyLeading: false,

              pinned: false,
              floating: false,
              snap: false,

              stretch: false,

              elevation: 0,

              backgroundColor: Colors.white,

              expandedHeight: 420.h,

              toolbarHeight: 0,

              collapsedHeight: 0,

              flexibleSpace: FlexibleSpaceBar(
                collapseMode:
                CollapseMode.parallax,

                background: RepaintBoundary(
                  child: _ProductImageArea(
                    product: product,
                  ),
                ),
              ),
            ),

            // =================================================
            // PRODUCT CONTENT
            // =================================================

            SliverToBoxAdapter(
              child: _ProductContentCard(
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

    final images = imageProvider.images.isEmpty
        ? <String>[
      product.thumbnail,
    ]
        : imageProvider.images
        .map(
          (image) => image.imageUrl,
    )
        .toList();

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
        color: const Color(0xFFF5F5F5),

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [

          // ===================================================
          // TOP HANDLE
          // ===================================================

          Padding(
            padding: EdgeInsets.only(
              top: 10.h,
              bottom: 4.h,
            ),

            child: Container(
              width: 42.w,
              height: 4.h,

              decoration: BoxDecoration(
                color: Colors.grey.shade400,

                borderRadius:
                BorderRadius.circular(20.r),
              ),
            ),
          ),

          // ===================================================
          // TITLE
          // ===================================================

          ProductTitleSection(
            product: product,
          ),

          // ===================================================
          // RATING
          // ===================================================

          // ===================================================
          // RATING & REVIEWS
          // ===================================================

          ProductRatingSection(
            product: product,
            onTap: () {
              debugPrint(
                'Open reviews: ${product.id}',
              );
            },
          ),

          // ===================================================
          // DESCRIPTION
          // ===================================================

          ProductDescriptionSection(
            product: product,
          ),

          // ===================================================
          // SPECIFICATIONS
          // ===================================================

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
        ],
      ),
    );
  }
}