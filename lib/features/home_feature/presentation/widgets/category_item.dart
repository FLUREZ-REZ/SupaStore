
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
  });

  final CategoryEntity category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    final double itemWidth = isMobile
        ? 82
        : isTablet
        ? 84
        : 88;

    final double imageSize = isMobile
        ? 58
        : isTablet
        ? 60
        : 64;

    final double fontSize = isMobile
        ? 12
        : isTablet
        ? 11
        : 12;

    final double spacing = isMobile ? 8 : 7;

    return SizedBox(
      width: itemWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: category.imageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          size: 24,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: spacing),

                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.category.copyWith(
                    color: AppColors.black,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
