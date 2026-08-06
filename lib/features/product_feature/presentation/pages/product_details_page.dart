import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_image_provider.dart';
import '../providers/product_specification_provider.dart';
import '../widgets/add_to_cart_bar.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_image_slider.dart';

import '../widgets/product_rating_section.dart';
import '../widgets/product_specifications_section.dart';
import '../widgets/product_title_section.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageProvider =
    context.watch<ProductImageProvider>();

    final specificationProvider =
    context.watch<ProductSpecificationProvider>();

    final images = imageProvider.images.isEmpty
        ? [product.thumbnail]
        : imageProvider.images
        .map((e) => e.imageUrl)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          title: Text(
            product.title,
            style: AppTextStyles.second_title_section,
          ),
        ),

        bottomNavigationBar: AddToCartBar(
          product: product,
          onAddToCart: () {},
        ),

        body: ListView(
          children: [

            ProductImageSlider(
              images: images,
            ),

            ProductTitleSection(
              product: product,
            ),


            ProductRatingSection(
              product: product,
            ),

            ProductDescriptionSection(
              product: product,
            ),

            ProductSpecificationsSection(
              specifications:
              specificationProvider.specifications,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}