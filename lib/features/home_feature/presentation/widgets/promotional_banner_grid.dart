
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/presentation/utils/banner_navigation_handler.dart';
import 'package:supastore/features/home_feature/presentation/widgets/home_content_container.dart';

// ==================================================================
// PROMOTIONAL BANNER GRID
// ==================================================================

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

    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    final int crossAxisCount = isMobile || isTablet ? 2 : 4;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
        ? 24
        : 28;

    final double spacing = isMobile
        ? 10
        : isTablet
        ? 14
        : 16;

    final double childAspectRatio = isMobile
        ? 1.2
        : isTablet
        ? 1.5
        : 1.25;

    final double borderRadius = isMobile ? 12 : 16;

    final visibleBanners = banners.take(4).toList();

    return HomeContentContainer(
      maxWidth: 1200,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleBanners.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final banner = visibleBanners[index];

            return _PromotionalBannerItem(
              banner: banner,
              borderRadius: borderRadius,
              onTap: () {
                BannerNavigationHandler.handle(
                  context: context,
                  banner: banner,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ==================================================================
// PROMOTIONAL BANNER ITEM
// ==================================================================

class _PromotionalBannerItem extends StatelessWidget {
  const _PromotionalBannerItem({
    required this.banner,
    required this.onTap,
    required this.borderRadius,
  });

  final BannerEntity banner;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: CachedNetworkImage(
          imageUrl: banner.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: 900,
          maxWidthDiskCache: 1200,
          placeholder: (context, url) {
            return const _BannerShimmer();
          },
          errorWidget: (context, url, error) {
            return const _BannerError();
          },
        ),
      ),
    );
  }
}

// ==================================================================
// BANNER SHIMMER
// ==================================================================

class _BannerShimmer extends StatefulWidget {
  const _BannerShimmer();

  @override
  State<_BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<_BannerShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSize =
        (constraints.maxWidth * 0.10).clamp(20.0, 30.0);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                gradient: LinearGradient(
                  begin: Alignment(
                    -1.5 + _controller.value * 3,
                    0,
                  ),
                  end: Alignment(
                    -0.5 + _controller.value * 3,
                    0,
                  ),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                  stops: const [0.1, 0.5, 0.9],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: iconSize,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================================================================
// BANNER ERROR
// ==================================================================

class _BannerError extends StatelessWidget {
  const _BannerError();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSize =
        (constraints.maxWidth * 0.10).clamp(22.0, 32.0);

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: iconSize,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
