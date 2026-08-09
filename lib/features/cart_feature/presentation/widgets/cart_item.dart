import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/cart_feature/domain/entities/cart_item_entity.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemEntity item;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;


    debugPrint(
      'IMAGE URL: ${product.thumbnail}',
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 6.h,
      ),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          /// Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 90.w,
              height: 90.w,
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                },
                errorWidget: (_, __, ___) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 28.sp,
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          /// Product Information
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productCard,
                ),

                SizedBox(height: 8.h),

                Text(
                  PriceFormatter.format(
                    product.finalPrice,
                  ),
                  style: AppTextStyles.product_prize.copyWith(
                    color: AppColors.price,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.h),

                Row(
                  children: [
                    /// Decrease
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: onDecrease,
                    ),

                    SizedBox(width: 10.w),

                    Text(
                      item.quantity.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    /// Increase
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: onIncrease,
                    ),

                    const Spacer(),

                    /// Delete
                    InkWell(
                      onTap: onRemove,
                      borderRadius:
                      BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Icon(
            icon,
            size: 17.sp,
          ),
        ),
      ),
    );
  }
}