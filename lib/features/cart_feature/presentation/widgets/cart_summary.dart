import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/features/cart_feature/presentation/providers/cart_provider.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    this.onCheckout,
  });

  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 16.r,
            offset: Offset(
              0,
              -4.h,
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            children: [
              Text(
                'خلاصه سفارش',
                style: AppTextStyles.second_title_section,
              ),

              const Spacer(),

              Text(
                '${cart.totalItems} کالا',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Subtotal
          _SummaryRow(
            title: 'جمع کالاها',
            value: cart.subtotal,
          ),

          SizedBox(height: 10.h),

          /// Discount
          if (cart.totalDiscount > 0) ...[
            _SummaryRow(
              title: 'تخفیف',
              value: cart.totalDiscount,
              isDiscount: true,
            ),

            SizedBox(height: 10.h),
          ],

          Divider(
            height: 20.h,
            color: Colors.grey.shade200,
          ),

          /// Final Price
          Row(
            children: [
              Text(
                'مبلغ قابل پرداخت',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                PriceFormatter.format(
                  cart.totalPrice,
                ),
                style: AppTextStyles.product_prize.copyWith(
                  color: AppColors.price,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Checkout Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed:
              cart.isUpdating
                  ? null
                  : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                foregroundColor:
                Colors.white,
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14.r,
                  ),
                ),
              ),
              child: cart.isUpdating
                  ? SizedBox(
                width: 22.w,
                height: 22.w,
                child:
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'ادامه فرایند خرید',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.isDiscount = false,
  });

  final String title;
  final int value;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
          ),
        ),

        const Spacer(),

        Text(
          PriceFormatter.format(value),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? Colors.green
                : AppColors.black,
          ),
        ),
      ],
    );
  }
}