import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';

class SingleBanner extends StatelessWidget {
  const SingleBanner({
    super.key,
    required this.banner,
    this.onTap,
  });

  final BannerEntity banner;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: AspectRatio(
            aspectRatio: 2.2,
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,

              fit: BoxFit.cover,

              placeholder: (context, url) {
                return Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
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
                    size: 32.sp,
                    color: Colors.grey.shade500,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}