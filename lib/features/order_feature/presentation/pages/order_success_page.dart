import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'ثبت سفارش',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Success Icon
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 70.sp,
                    color: Colors.green,
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'سفارش شما با موفقیت ثبت شد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  'از خرید شما متشکریم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 30.h),

                // Order Information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        title: 'شماره سفارش',
                        value: order.id,
                      ),

                      SizedBox(height: 14.h),

                      _InfoRow(
                        title: 'تعداد کالا',
                        value:
                        '${order.items.fold<int>(
                          0,
                              (
                              sum,
                              item,
                              ) =>
                          sum +
                              item.quantity,
                        )} کالا',
                      ),

                      SizedBox(height: 14.h),

                      _InfoRow(
                        title: 'مبلغ سفارش',
                        value:
                        PriceFormatter.format(
                          order.totalPrice,
                        ),
                        valueColor:
                        AppColors.price,
                      ),

                      SizedBox(height: 14.h),

                      _InfoRow(
                        title: 'وضعیت سفارش',
                        value:
                        _statusText(
                          order.status,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Order Details
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: () {
                      // مرحله بعد:
                      // OrderDetailsPage
                    },
                    style:
                    OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14.r,
                        ),
                      ),
                    ),
                    child: const Text(
                      'مشاهده سفارش',
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Home
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil(
                            (route) =>
                        route.isFirst,
                      );
                    },
                    style:
                    ElevatedButton.styleFrom(
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
                    child: const Text(
                      'بازگشت به فروشگاه',
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusText(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return 'در انتظار بررسی';

      case 'processing':
        return 'در حال پردازش';

      case 'shipped':
        return 'ارسال شده';

      case 'delivered':
        return 'تحویل داده شده';

      case 'cancelled':
        return 'لغو شده';

      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color:
              valueColor ??
                  Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}