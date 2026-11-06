
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

class SingleBanner extends StatelessWidget {
  const SingleBanner({
    super.key,
    required this.banner,
    this.onTap,
  });

  final BannerEntity banner;
  final VoidCallback? onTap;

  static const double _aspectRatio = 1920 / 950;
  static const double _maxDesktopWidth = 1400;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final double horizontalPadding;

    if (screenWidth < 600) {
      horizontalPadding = 16;
    } else if (screenWidth < 1024) {
      horizontalPadding = 24;
    } else {
      horizontalPadding = 32;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _maxDesktopWidth,
          ),
          child: SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                    alignment: Alignment.center,

                    placeholder: (context, url) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },

                    errorWidget: (context, url, error) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: Colors.grey.shade500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
