import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_image_provider.dart';
import '../widgets/add_to_cart_bar.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_price_section.dart';
import '../widgets/product_rating_section.dart';
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProductImageProvider>()
          .loadImages(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductImageProvider>(
      builder: (context, provider, child) {

        final images = provider.images.isEmpty
            ? [widget.product.thumbnail]
            : provider.images
            .map((e) => e.imageUrl)
            .toList();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.product.title),
              centerTitle: true,
            ),

            bottomNavigationBar: AddToCartBar(
              product: widget.product,
              onAddToCart: () {},
            ),

            body: ListView(
              children: [

                ProductImageSlider(
                  images: images,
                ),

                ProductTitleSection(
                  product: widget.product,
                ),

                ProductPriceSection(
                  product: widget.product,
                ),

                ProductRatingSection(
                  product: widget.product,
                ),

                ProductDescriptionSection(
                  product: widget.product,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}