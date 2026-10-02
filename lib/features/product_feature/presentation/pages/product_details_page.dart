import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';
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
import 'package:supastore/features/review_feature/presentation/providers/review_provider.dart';
import 'package:supastore/features/review_feature/presentation/widgets/reviews_section.dart';

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

    // ========================================================
    // USER NOT LOGGED IN
    // ========================================================

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

    // ========================================================
    // ADD PRODUCT TO CART
    // ========================================================

    await context.read<CartProvider>().addToCart(
      userId: user.id,
      productId: product.id,
    );

    if (!context.mounted) return;

    final cartProvider =
    context.read<CartProvider>();

    // ========================================================
    // ERROR
    // ========================================================

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

    // ========================================================
    // FIND ADDED PRODUCT
    // ========================================================

    final cartItems =
        cartProvider.items;

    CartItemEntity? addedItem;

    for (final item in cartItems) {
      if (item.productId == product.id) {
        addedItem = item;
        break;
      }
    }

    // ========================================================
    // SHOW BOTTOM SHEET
    // ========================================================

    _showAddedToCartBottomSheet(
      context,
      addedItem: addedItem,
    );
  }

  // ==========================================================
  // ADDED TO CART BOTTOM SHEET
  // ==========================================================

  void _showAddedToCartBottomSheet(
      BuildContext context, {
        required CartItemEntity? addedItem,
      }) {
    final int quantity =
        addedItem?.quantity ?? 1;

    final String imageUrl =
        addedItem?.product.thumbnail ??
            product.thumbnail;

    final String productTitle =
        addedItem?.product.title ??
            product.title;

    final int finalPrice =
        addedItem?.product.finalPrice ??
            product.finalPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(
        0.45,
      ),
      builder: (
          bottomSheetContext,
          ) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 12.h,
              bottom:
              MediaQuery.of(
                bottomSheetContext,
              ).padding.bottom +
                  20.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(
                top: Radius.circular(
                  26.r,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.14,
                  ),
                  blurRadius: 24,
                  offset: const Offset(
                    0,
                    -6,
                  ),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================

                Container(
                  width: 42.w,
                  height: 4.h,
                  margin: EdgeInsets.only(
                    bottom: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(
                      20.r,
                    ),
                  ),
                ),

                // ==================================================
                // SUCCESS HEADER
                // ==================================================

                Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(
                          0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 25.sp,
                      ),
                    ),

                    SizedBox(
                      width: 12.w,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'محصول به سبد خرید اضافه شد',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Colors.black87,
                            ),
                          ),

                          SizedBox(
                            height: 4.h,
                          ),

                          Text(
                            'محصول با موفقیت به سبد شما اضافه شد.',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color:
                              Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 18.h,
                ),

                // ==================================================
                // PRODUCT CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    10.w,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFF8F8F8),
                    borderRadius:
                    BorderRadius.circular(
                      16.r,
                    ),
                    border: Border.all(
                      color:
                      Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      // ============================================
                      // PRODUCT IMAGE
                      // ============================================

                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                        child: SizedBox(
                          width: 72.w,
                          height: 72.w,
                          child:
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (
                                context,
                                url,
                                ) {
                              return Container(
                                color:
                                Colors.grey.shade100,
                                child:
                                Center(
                                  child:
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child:
                                    const CircularProgressIndicator(
                                      strokeWidth:
                                      2,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorWidget: (
                                context,
                                url,
                                error,
                                ) {
                              return Container(
                                color:
                                Colors.grey.shade100,
                                child: Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  color:
                                  Colors.grey,
                                  size: 28.sp,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 12.w,
                      ),

                      // ============================================
                      // PRODUCT INFO
                      // ============================================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style: TextStyle(
                                fontSize:
                                13.sp,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                Colors.black87,
                                height: 1.5,
                              ),
                            ),

                            SizedBox(
                              height: 8.h,
                            ),

                            Row(
                              children: [
                                Text(
                                  'تعداد:',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    11.5.sp,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),

                                SizedBox(
                                  width: 5.w,
                                ),

                                Container(
                                  padding:
                                  EdgeInsets
                                      .symmetric(
                                    horizontal:
                                    8.w,
                                    vertical:
                                    3.h,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: AppColors
                                        .primary
                                        .withOpacity(
                                      0.08,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      6.r,
                                    ),
                                  ),
                                  child: Text(
                                    quantity
                                        .toString(),
                                    style:
                                    TextStyle(
                                      fontSize:
                                      12.sp,
                                      fontWeight:
                                      FontWeight
                                          .w700,
                                      color: AppColors
                                          .primary,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 4.w,
                                ),

                                Text(
                                  'عدد',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    11.5.sp,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 5.h,
                            ),

                            Text(
                              '$finalPrice تومان',
                              style:
                              TextStyle(
                                fontSize:
                                11.5.sp,
                                fontWeight:
                                FontWeight
                                    .w600,
                                color:
                                AppColors.price,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 18.h,
                ),

                // ==================================================
                // QUESTION
                // ==================================================

                Text(
                  'می‌خواهید به سبد خرید بروید؟',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                    FontWeight.w500,
                    color:
                    Colors.grey.shade700,
                  ),
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // GO TO CART
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child:
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      context.push(
                        '/cart',
                      );
                    },
                    icon: Icon(
                      Icons
                          .shopping_cart_outlined,
                      size: 21.sp,
                    ),
                    label: Text(
                      'رفتن به سبد خرید',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor:
                      Colors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12.r,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 10.h,
                ),

                // ==================================================
                // CONTINUE SHOPPING
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();
                    },
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      Colors.black87,
                      side: BorderSide(
                        color:
                        Colors.grey.shade300,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12.r,
                        ),
                      ),
                    ),
                    child: Text(
                      'ادامه خرید',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return MultiProvider(
      providers: [
        // ====================================================
        // PRODUCT IMAGE PROVIDER
        // ====================================================

        ChangeNotifierProvider<
            ProductImageProvider>(
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
            getIt<
                ProductSpecificationProvider>();

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
            getIt<
                RelatedProductsProvider>();

            provider.loadRelatedProducts(
              categoryId:
              product.categoryId,
              productId: product.id,
              limit: 6,
            );

            return provider;
          },
        ),

        // ====================================================
        // REVIEW PROVIDER
        // ====================================================

        ChangeNotifierProvider<
            ReviewProvider>(
          create: (_) {
            final provider =
            getIt<ReviewProvider>();

            provider.loadReviews(
              product.id,
            );

            return provider;
          },
        ),
      ],
      child: Directionality(
        textDirection:
        TextDirection.rtl,
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
              AppTextStyles
                  .second_title_section,
            ),
            actions: [
              // ==============================================
              // FAVORITE
              // ==============================================

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
              ),

              // ==============================================
              // SHARE
              // ==============================================

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
                _addToCart(
                  context,
                );
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
  Widget build(
      BuildContext context,
      ) {
    final imageProvider =
    context.watch<
        ProductImageProvider>();

    // =========================================================
    // LOADING
    // =========================================================

    if (imageProvider.isLoading &&
        imageProvider.images.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    // =========================================================
    // IMAGES
    // =========================================================

    final List<String> images =
    imageProvider.images
        .map(
          (image) =>
      image.imageUrl,
    )
        .where(
          (url) =>
      url.isNotEmpty,
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
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
        const Color(0xFFF5F5F5),
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            24.r,
          ),
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
              decoration:
              BoxDecoration(
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
          // REVIEWS
          // ==================================================

          ReviewsSection(
            productId: product.id,
          ),

          SizedBox(
            height: 16.h,
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
                  Navigator.of(
                    context,
                  ).push(
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