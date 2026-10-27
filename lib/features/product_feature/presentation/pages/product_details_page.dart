
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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


// =============================================================
// PRODUCT DETAILS PAGE
// =============================================================

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  // ===========================================================
  // ADD TO CART
  // ===========================================================

  Future<void> _addToCart(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

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

    final cartProvider = context.read<CartProvider>();

    if (cartProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.error!),
        ),
      );
      return;
    }

    CartItemEntity? addedItem;

    for (final item in cartProvider.items) {
      if (item.productId == product.id) {
        addedItem = item;
        break;
      }
    }

    _showAddedToCartBottomSheet(
      context,
      addedItem: addedItem,
    );
  }

  // ===========================================================
  // ADDED TO CART BOTTOM SHEET
  // ===========================================================

  void _showAddedToCartBottomSheet(
      BuildContext context, {
        required CartItemEntity? addedItem,
      }) {
    final int quantity = addedItem?.quantity ?? 1;

    final String imageUrl =
        addedItem?.product.thumbnail ?? product.thumbnail;

    final String productTitle =
        addedItem?.product.title ?? product.title;

    final int finalPrice =
        addedItem?.product.finalPrice ?? product.finalPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 12.h,
              bottom:
              MediaQuery.of(bottomSheetContext).padding.bottom +
                  20.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(26.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE

                Container(
                  width: 42.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),

                // SUCCESS HEADER

                Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 25.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'محصول به سبد خرید اضافه شد',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'محصول با موفقیت به سبد شما اضافه شد.',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // PRODUCT CARD

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: SizedBox(
                          width: 72.w,
                          height: 72.w,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return const ShimmerBox(
                                width: double.infinity,
                                height: double.infinity,
                                radius: 0,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Iconsax.image_copy,
                                  color: Colors.grey,
                                  size: 28.sp,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Text(
                                  'تعداد:',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                    AppColors.primary.withOpacity(0.08),
                                    borderRadius:
                                    BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'عدد',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '$finalPrice تومان',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.price,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  'می‌خواهید به سبد خرید بروید؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: 14.h),

                // GO TO CART

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      context.push('/cart');
                    },
                    icon: Icon(
                      Iconsax.shopping_cart_copy,
                      size: 21.sp,
                    ),
                    label: Text(
                      'رفتن به سبد خرید',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // CONTINUE SHOPPING

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'ادامه خرید',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductImageProvider>(
          create: (_) {
            final provider = getIt<ProductImageProvider>();
            provider.loadImages(product.id);
            return provider;
          },
        ),
        ChangeNotifierProvider<ProductSpecificationProvider>(
          create: (_) {
            final provider = getIt<ProductSpecificationProvider>();
            provider.loadSpecifications(product.id);
            return provider;
          },
        ),
        ChangeNotifierProvider<RelatedProductsProvider>(
          create: (_) {
            final provider = getIt<RelatedProductsProvider>();
            provider.loadRelatedProducts(
              categoryId: product.categoryId,
              productId: product.id,
              limit: 6,
            );
            return provider;
          },
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (_) {
            final provider = getIt<ReviewProvider>();
            provider.loadReviews(product.id);
            return provider;
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),

          // APP BAR

          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
                  Iconsax.heart_copy,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Iconsax.share_copy,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // ADD TO CART BAR

          bottomNavigationBar: RepaintBoundary(
            child: AddToCartBar(
              product: product,
              onAddToCart: () {
                _addToCart(context);
              },
            ),
          ),

          // BODY

          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                  collapseMode: CollapseMode.parallax,
                  background: RepaintBoundary(
                    child: _ProductImageArea(product: product),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ProductContentCard(product: product),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 30.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// PRODUCT IMAGE AREA WITH SHIMMER
// =============================================================

class _ProductImageArea extends StatelessWidget {
  const _ProductImageArea({
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ProductImageProvider>();

    if (imageProvider.isLoading && imageProvider.images.isEmpty) {
      return const _ProductImageShimmer();
    }

    final List<String> images = imageProvider.images
        .map((image) => image.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        child: ProductImageSlider(
          images: [product.thumbnail],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: ProductImageSlider(images: images),
    );
  }
}


// =============================================================
// PRODUCT IMAGE SHIMMER
// =============================================================

class _ProductImageShimmer extends StatelessWidget {
  const _ProductImageShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
          Icon(
            Iconsax.gallery_copy,
            size: 42.sp,
            color: Colors.grey.shade400,
          ),
          Positioned(
            bottom: 24.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: ShimmerBox(
                    width: index == 0 ? 24.w : 7.w,
                    height: 7.w,
                    radius: 10.r,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// PRODUCT CONTENT CARD
// =============================================================

class _ProductContentCard extends StatelessWidget {
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
          // HANDLE

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
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),

          // TITLE

          ProductTitleSection(product: product),

          // RATING

          ProductRatingSection(product: product),

          // DESCRIPTION

          ProductDescriptionSection(product: product),

          // SPECIFICATIONS WITH SHIMMER

          Selector<ProductSpecificationProvider, List>(
            selector: (_, provider) => provider.specifications,
            builder: (context, specifications, child) {
              final provider =
              context.read<ProductSpecificationProvider>();

              if (specifications.isEmpty && provider.isLoading) {
                return const _SpecificationsShimmer();
              }

              return ProductSpecificationsSection(
                specifications: specifications.cast(),
              );
            },
          ),

          // REVIEWS

          ReviewsSection(productId: product.id),

          SizedBox(height: 16.h),

          // RELATED PRODUCTS WITH SHIMMER

          Selector<RelatedProductsProvider, List<ProductEntity>>(
            selector: (_, provider) => provider.products,
            builder: (context, products, child) {
              final provider = context.read<RelatedProductsProvider>();

              if (products.isEmpty && provider.isLoading) {
                return const _RelatedProductsShimmer();
              }

              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return RelatedProductsSection(
                products: products,
                onProductTap: (relatedProduct) {
                  context.pushNamed(
                    'product-details',
                    extra: relatedProduct,
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


// =============================================================
// SPECIFICATIONS SHIMMER
// =============================================================

class _SpecificationsShimmer extends StatelessWidget {
  const _SpecificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 18.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            width: 150,
            height: 20,
            radius: 6,
          ),
          SizedBox(height: 18.h),
          ...List.generate(
            4,
                (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      radius: 5,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  const Expanded(
                    flex: 3,
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      radius: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// RELATED PRODUCTS SHIMMER
// =============================================================

class _RelatedProductsShimmer extends StatelessWidget {
  const _RelatedProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8.h,
        bottom: 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const ShimmerBox(
              width: 150,
              height: 20,
              radius: 6,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 235.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 145.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: double.infinity,
                          height: 125.h,
                          radius: 10.r,
                        ),
                        SizedBox(height: 12.h),
                        ShimmerBox(
                          width: 115.w,
                          height: 12.h,
                          radius: 5.r,
                        ),
                        SizedBox(height: 8.h),
                        ShimmerBox(
                          width: 85.w,
                          height: 12.h,
                          radius: 5.r,
                        ),
                        const Spacer(),
                        ShimmerBox(
                          width: 95.w,
                          height: 15.h,
                          radius: 5.r,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// REUSABLE SHIMMER BOX
// No external package required
// =============================================================

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.5 + 3 * _controller.value, 0),
                  end: Alignment(-0.5 + 3 * _controller.value, 0),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                  stops: const [0.25, 0.5, 0.75],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
