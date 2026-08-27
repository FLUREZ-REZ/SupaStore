import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/presentation/utils/banner_navigation_handler.dart';
import 'package:supastore/features/product_feature/presentation/providers/product_provider.dart';

class PromotionalBannerGrid extends StatelessWidget {
  const PromotionalBannerGrid({
    super.key,
    required this.banners,
  });

  final List<BannerEntity> banners;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleBanners = banners.take(4).toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount: visibleBanners.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final banner = visibleBanners[index];

          return _PromotionalBannerItem(
            banner: banner,
            onTap: () {
              BannerNavigationHandler.handle(
                context: context,
                banner: banner,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleBannerTap(
      BuildContext context,
      BannerEntity banner,
      ) async {
    if (!banner.hasAction) {
      return;
    }

    switch (banner.actionType) {
      case 'product':
        await _openProduct(
          context,
          banner.actionValue!,
        );
        break;

      case 'category':

        break;

      default:
        break;
    }
  }

  Future<void> _openProduct(
      BuildContext context,
      String productId,
      ) async {
    final productProvider =
    getIt<ProductProvider>();

    final product =
    await productProvider.getProductById(
      productId,
    );

    if (!context.mounted) {
      return;
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'محصول مورد نظر پیدا نشد',
          ),
        ),
      );

      return;
    }

    context.pushNamed(
      'product-details',
      extra: product,
    );
  }
}

class _PromotionalBannerItem
    extends StatelessWidget {
  const _PromotionalBannerItem({
    required this.banner,
    required this.onTap,
  });

  final BannerEntity banner;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 700,
          maxWidthDiskCache: 1000,
          placeholder: (
              context,
              url,
              ) {
            return const _BannerPlaceholder();
          },
          errorWidget: (
              context,
              url,
              error,
              ) {
            return const _BannerError();
          },
        ),
      ),
    );
  }
}

class _BannerPlaceholder
    extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: SizedBox(
        width: 20.w,
        height: 20.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _BannerError
    extends StatelessWidget {
  const _BannerError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 26.sp,
        color: Colors.grey,
      ),
    );
  }
}