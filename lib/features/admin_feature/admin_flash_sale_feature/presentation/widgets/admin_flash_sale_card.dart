import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/admin_flash_sale_entity.dart';
import 'flash_sale_countdown.dart';

class AdminFlashSaleCard extends StatelessWidget {
  const AdminFlashSaleCard({
    super.key,
    required this.flashSale,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final AdminFlashSaleEntity flashSale;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final ValueChanged<bool> onStatusChanged;

  String _formatPrice(int price) {
    final value = price.toString();

    return value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = flashSale.product;

    return Container(
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 90.w,
                    height: 90.w,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorWidget:
                          (context, url, error) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Iconsax.image_copy,
                            color:
                            Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                          FontWeight.w700,
                          color: const Color(
                            0xFF222222,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'قیمت اصلی: '
                            '${_formatPrice(product.price)} تومان',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'قیمت فروش ویژه: '
                            '${_formatPrice(flashSale.discountPrice)} تومان',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                          FontWeight.w700,
                          color: const Color(
                            0xFFE21B23,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch.adaptive(
                      value: flashSale.isActive,
                      activeTrackColor:
                      const Color(0xFF03045e),
                      onChanged: onStatusChanged,
                    ),
                    Text(
                      flashSale.isActive
                          ? 'فعال'
                          : 'غیرفعال',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: flashSale.isActive
                            ? const Color(
                          0xFF008000,
                        )
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (flashSale.hasValidDiscount)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE21B23,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        7.r,
                      ),
                    ),
                    child: Text(
                      '${flashSale.discountPercent}٪ تخفیف',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'اولویت: ${flashSale.sortOrder}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            FlashSaleCountdown(
              startAt: flashSale.startAt,
              endAt: flashSale.endAt,
              isActive: flashSale.isActive,
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                    ),
                    label: const Text(
                      'ویرایش',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      const Color(
                        0xFF023E8A,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24.h,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(
                      Iconsax.trash_copy,
                      size: 18.sp,
                    ),
                    label: const Text(
                      'حذف',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      const Color(
                        0xFFE21B23,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}