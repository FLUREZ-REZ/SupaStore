import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';

class AddToCartBar extends StatelessWidget {
  const AddToCartBar({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  final ProductEntity product;

  final VoidCallback? onAddToCart;

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
                      "${product.price} تومان",
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 13.sp,
                      ),
                    ),

                  SizedBox(height: 4.h),

                  Text(
                    "${product.finalPrice} تومان",
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
                onPressed: product.isAvailable
                    ? onAddToCart
                    : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  product.isAvailable
                      ? "افزودن به سبد"
                      : "ناموجود",
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