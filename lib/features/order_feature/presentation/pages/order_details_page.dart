import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,

        appBar: AppBar(
          backgroundColor: AppColors.orders_page_redi,
          title: const Text(
            'جزئیات سفارش',
          ),
          centerTitle: true,
        ),

        body: ListView(
          padding: EdgeInsets.only(
            top: 12.h,
            bottom: 24.h,
          ),
          children: [
            /// Order Header
            _OrderHeader(
              order: order,
            ),

            SizedBox(height: 12.h),

            /// Products
            const _SectionTitle(
              title: 'محصولات سفارش',
            ),

            _OrderItemsSection(
              order: order,
            ),

            SizedBox(height: 12.h),

            /// Shipping Address
            const _SectionTitle(
              title: 'آدرس ارسال',
            ),

            _ShippingAddressCard(
              address: order.shippingAddress,
            ),

            SizedBox(height: 12.h),

            /// Payment & Shipping
            const _SectionTitle(
              title: 'اطلاعات ارسال و پرداخت',
            ),

            _ShippingPaymentCard(
              order: order,
            ),

            SizedBox(height: 12.h),

            /// Summary
            const _SectionTitle(
              title: 'خلاصه سفارش',
            ),

            _OrderSummary(
              order: order,
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

///
/// Order Header
///

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
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
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color:
                  AppColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 25.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارش',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      _shortOrderId(order.id),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              _StatusBadge(
                status: order.status,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Text(
                'تاریخ ثبت سفارش',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              const Spacer(),

              Text(
                _formatDate(order.createdAt),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return '${id.substring(0, 8)}...';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

///
/// Section Title
///

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

///
/// Order Items
///

class _OrderItemsSection
    extends StatelessWidget {
  const _OrderItemsSection({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: order.items.map(
              (item) {
            return _OrderItemRow(
              item: item,
            );
          },
        ).toList(),
      ),
    );
  }
}

///
/// Single Order Item
///

class _OrderItemRow
    extends StatelessWidget {
  const _OrderItemRow({
    required this.item,
  });

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(10.r),
            child: Image.network(
              item.productThumbnail,
              width: 65.w,
              height: 65.w,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 65.w,
                  height: 65.w,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons
                        .image_not_supported_outlined,
                    color:
                    Colors.grey.shade400,
                    size: 24.sp,
                  ),
                );
              },
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  '${item.quantity} عدد',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 5.h),

                Text(
                  PriceFormatter.format(
                    item.unitPrice,
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                    Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          Text(
            PriceFormatter.format(
              item.totalPrice,
            ),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.price,
            ),
          ),
        ],
      ),
    );
  }
}

///
/// Shipping Address
///

class _ShippingAddressCard
    extends StatelessWidget {
  const _ShippingAddressCard({
    required this.address,
  });

  final String? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 24.sp,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              address?.isNotEmpty == true
                  ? address!
                  : 'آدرس ثبت نشده است',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///
/// Shipping + Payment
///

class _ShippingPaymentCard
    extends StatelessWidget {
  const _ShippingPaymentCard({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
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
            icon: Icons.local_shipping_outlined,
            title: 'روش ارسال',
            value: 'ارسال معمولی',
          ),

          SizedBox(height: 14.h),

          _InfoRow(
            icon: Icons.payment_outlined,
            title: 'روش پرداخت',
            value: _paymentText(
              order.paymentMethod ?? '',
            ),
          ),

          SizedBox(height: 14.h),

          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'وضعیت پرداخت',
            value: _paymentStatusText(
              order.paymentStatus ?? '',
            ),
          ),
        ],
      ),
    );
  }

  String _paymentText(
      String method,
      ) {
    switch (method) {
      case 'online':
        return 'پرداخت آنلاین';

      case 'cash':
        return 'پرداخت در محل';

      default:
        return method;
    }
  }

  String _paymentStatusText(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return 'در انتظار پرداخت';

      case 'paid':
        return 'پرداخت شده';

      case 'failed':
        return 'پرداخت ناموفق';

      case 'refunded':
        return 'مبلغ بازگشت داده شده';

      default:
        return status;
    }
  }
}

///
/// Order Summary
///

class _OrderSummary
    extends StatelessWidget {
  const _OrderSummary({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
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
          _SummaryRow(
            title: 'جمع کالاها',
            value: order.subtotal,
          ),

          SizedBox(height: 10.h),

          _SummaryRow(
            title: 'تخفیف',
            value: order.discount,
            isDiscount: true,
          ),

          SizedBox(height: 10.h),

          _SummaryRow(
            title: 'هزینه ارسال',
            value: order.shippingCost,
          ),

          Divider(
            height: 24.h,
          ),

          _SummaryRow(
            title: 'مبلغ کل',
            value: order.totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

///
/// Summary Row
///

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String title;
  final int value;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:
            isTotal ? 15.sp : 13.sp,
            fontWeight:
            isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color:
            isDiscount
                ? Colors.green
                : Colors.black87,
          ),
        ),

        const Spacer(),

        Text(
          PriceFormatter.format(
            value,
          ),
          style: TextStyle(
            fontSize:
            isTotal ? 16.sp : 13.sp,
            fontWeight:
            FontWeight.bold,
            color:
            isDiscount
                ? Colors.green
                : isTotal
                ? AppColors.price
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}

///
/// Info Row
///

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21.sp,
          color: AppColors.primary,
        ),

        SizedBox(width: 10.w),

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
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

///
/// Status Badge
///

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.1,
        ),
        borderRadius:
        BorderRadius.circular(20.r),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return Colors.orange;

      case 'processing':
        return Colors.blue;

      case 'shipped':
        return Colors.indigo;

      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
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