import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/product_entity.dart';

class AddToCartBar extends StatelessWidget {
  const AddToCartBar({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  final ProductEntity product;
  final VoidCallback? onAddToCart;

  String _formatPersianPrice(num price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '٬',
    );

    const englishDigits = '0123456789';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    return formatted.split('').map((char) {
      final index = englishDigits.indexOf(char);
      return index == -1 ? char : persianDigits[index];
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 14.h,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product.hasDiscount)
                    Text(
                      '${_formatPersianPrice(product.price)} تومان',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 13.sp,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_formatPersianPrice(product.finalPrice)} تومان',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              width: 160.w,
              height: 52.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFd90429), // رنگ پس‌زمینه دکمه
                  foregroundColor: Colors.white, // رنگ متن و آیکون
                ),
                onPressed: product.isAvailable ? onAddToCart : null,
                icon: const Icon(Iconsax.truck_copy),
                label: Text(
                  product.isAvailable ? 'افزودن به سبد' : 'ناموجود',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}