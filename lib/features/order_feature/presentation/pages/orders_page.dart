import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';

import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';

import 'package:supastore/features/order_feature/presentation/pages/order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({
    super.key,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrderRepository _repository;

  List<OrderEntity> _orders = [];

  bool _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _repository = getIt<OrderRepository>();

    _loadOrders();
  }

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error =
        'لطفاً ابتدا وارد حساب کاربری شوید';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders =
      await _repository.getUserOrders(
        user.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // OPEN ORDER DETAILS
  // ============================================================

  void _openOrderDetails(
      OrderEntity order,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(
          order: order,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Colors.grey.shade50,

        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          title: const Text(
            'سفارش‌های من',
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,

          actions: [
            IconButton(
              onPressed: _isLoading
                  ? null
                  : _loadOrders,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        onRetry: _loadOrders,
      );
    }

    if (_orders.isEmpty) {
      return const _EmptyOrdersView();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: 12.h,
          bottom: 30.h,
        ),
        itemCount: _orders.length,
        itemBuilder: (
            context,
            index,
            ) {
          final order = _orders[index];

          return _OrderCard(
            order: order,
            onDetails: () {
              _openOrderDetails(order);
            },
          );
        },
      ),
    );
  }
}

// ==================================================================
// ORDER CARD
// ==================================================================

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onDetails,
  });

  final OrderEntity order;

  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 7.h,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 8.r,
            offset: Offset(
              0,
              3.h,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // ====================================================
          // TOP
          // ====================================================

          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color:
                  AppColors.primary
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12.r,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
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
                        fontSize: 12.sp,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      _shortOrderId(order.id),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
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

          // ====================================================
          // ORDER INFO
          // ====================================================

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon:
                  Icons.shopping_bag_outlined,
                  title: 'تعداد کالا',
                  value:
                  '${_totalItems(order)} کالا',
                ),
              ),

              Expanded(
                child: _InfoItem(
                  icon:
                  Icons.payments_outlined,
                  title: 'مبلغ سفارش',
                  value:
                  PriceFormatter.format(
                    order.totalPrice,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ====================================================
          // DATE
          // ====================================================

          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15.sp,
                color: Colors.grey.shade500,
              ),

              SizedBox(width: 6.w),

              Text(
                _formatDate(order.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              const Spacer(),

              Text(
                _paymentMethodText(
                  order.paymentMethod ?? 'نامشخص',
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ====================================================
          // DETAILS BUTTON
          // ====================================================

          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton(
              onPressed: onDetails,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12.r,
                  ),
                ),
              ),
              child: Text(
                'مشاهده جزئیات',
                style: TextStyle(
                  fontSize: 13.sp,
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

  // ============================================================
  // SHORT ORDER ID
  // ============================================================

  String _shortOrderId(
      String id,
      ) {
    if (id.length <= 8) {
      return id;
    }

    return '#${id.substring(0, 8)}';
  }

  // ============================================================
  // TOTAL ITEMS
  // ============================================================

  int _totalItems(
      OrderEntity order,
      ) {
    return order.items.fold<int>(
      0,
          (
          sum,
          item,
          ) =>
      sum + item.quantity,
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    final year = date.year
        .toString()
        .padLeft(4, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    final day = date.day
        .toString()
        .padLeft(2, '0');

    return '$year/$month/$day';
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  String _paymentMethodText(
      String method,
      ) {
    switch (method) {
      case 'online':
        return 'پرداخت آنلاین';

      case 'cash':
        return 'پرداخت نقدی';

      case 'cod':
        return 'پرداخت در محل';

      default:
        return method;
    }
  }
}

// ==================================================================
// INFO ITEM
// ==================================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
          size: 20.sp,
          color: Colors.grey.shade500,
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                  Colors.grey.shade500,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// STATUS BADGE
// ==================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: _statusColor(
          status,
        ).withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20.r),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: _statusColor(status),
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

// ==================================================================
// EMPTY ORDERS
// ==================================================================

class _EmptyOrdersView
    extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color:
                Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 55.sp,
                color: Colors.grey.shade400,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'هنوز سفارشی ندارید',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'سفارش‌هایی که ثبت می‌کنید در این بخش نمایش داده می‌شوند.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR VIEW
// ==================================================================

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 70.sp,
              color: Colors.red.shade300,
            ),

            SizedBox(height: 16.h),

            Text(
              'دریافت سفارش‌ها ناموفق بود',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color:
                Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 20.h),

            SizedBox(
              height: 46.h,
              child: ElevatedButton(
                onPressed: onRetry,
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
                      12.r,
                    ),
                  ),
                ),
                child: const Text(
                  'تلاش مجدد',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}