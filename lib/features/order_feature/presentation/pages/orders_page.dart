
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
    this.initialStatus,
  });

  final String? initialStatus;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrderRepository _repository;

  List<OrderEntity> _orders = [];

  bool _isLoading = true;
  String? _error;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();

    _repository = getIt<OrderRepository>();
    _selectedStatus = widget.initialStatus;

    _loadOrders();
  }

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'لطفاً ابتدا وارد حساب کاربری شوید';
      });

      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final orders = await _repository.getUserOrders(user.id);

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // OPEN ORDER DETAILS
  // ============================================================

  void _openOrderDetails(OrderEntity order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(order: order),
      ),
    );
  }

  // ============================================================
  // FILTER ORDERS
  // ============================================================

  List<OrderEntity> get _filteredOrders {
    if (_selectedStatus == null) {
      return _orders;
    }

    return _orders
        .where((order) => order.status == _selectedStatus)
        .toList();
  }

  void _changeFilter(String? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('سفارش‌های من'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.orders_page_redi,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadOrders,
              icon: const Icon(Iconsax.refresh_copy),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const _OrdersShimmer();
    }

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        onRetry: _loadOrders,
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _filteredOrders.isEmpty
              ? const _EmptyOrdersView()
              : RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: 12.h,
                bottom: 30.h,
              ),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];

                return _OrderCard(
                  order: order,
                  onDetails: () {
                    _openOrderDetails(order);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _FilterChip(
              title: 'همه',
              selected: _selectedStatus == null,
              onTap: () => _changeFilter(null),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              title: 'در انتظار',
              selected: _selectedStatus == 'pending',
              color: Colors.orange,
              onTap: () => _changeFilter('pending'),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              title: 'در حال پردازش',
              selected: _selectedStatus == 'processing',
              color: Colors.blue,
              onTap: () => _changeFilter('processing'),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              title: 'ارسال شده',
              selected: _selectedStatus == 'shipped',
              color: Colors.indigo,
              onTap: () => _changeFilter('shipped'),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              title: 'تحویل شده',
              selected: _selectedStatus == 'delivered',
              color: Colors.green,
              onTap: () => _changeFilter('delivered'),
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              title: 'لغو شده',
              selected: _selectedStatus == 'canceled',
              color: Colors.red,
              onTap: () => _changeFilter('canceled'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ORDERS SHIMMER
// ==================================================================

class _OrdersShimmer extends StatefulWidget {
  const _OrdersShimmer();

  @override
  State<_OrdersShimmer> createState() => _OrdersShimmerState();
}

class _OrdersShimmerState extends State<_OrdersShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // فیلترهای نمایشی هنگام بارگذاری
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  _ShimmerBox(
                    controller: _controller,
                    width: 58.w,
                    height: 34.h,
                    radius: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  _ShimmerBox(
                    controller: _controller,
                    width: 82.w,
                    height: 34.h,
                    radius: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  _ShimmerBox(
                    controller: _controller,
                    width: 105.w,
                    height: 34.h,
                    radius: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  _ShimmerBox(
                    controller: _controller,
                    width: 78.w,
                    height: 34.h,
                    radius: 20.r,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 12.h,
                  bottom: 30.h,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _OrderCardShimmer(
                    controller: _controller,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==================================================================
// ORDER CARD SHIMMER
// ==================================================================

class _OrderCardShimmer extends StatelessWidget {
  const _OrderCardShimmer({
    required this.controller,
  });

  final AnimationController controller;

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
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 44.w,
                height: 44.w,
                radius: 12.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      controller: controller,
                      width: 45.w,
                      height: 10.h,
                      radius: 5.r,
                    ),
                    SizedBox(height: 8.h),
                    _ShimmerBox(
                      controller: controller,
                      width: 115.w,
                      height: 14.h,
                      radius: 5.r,
                    ),
                  ],
                ),
              ),
              _ShimmerBox(
                controller: controller,
                width: 78.w,
                height: 28.h,
                radius: 20.r,
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
              Expanded(
                child: _ShimmerInfoItem(
                  controller: controller,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ShimmerInfoItem(
                  controller: controller,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 16.w,
                height: 16.w,
                radius: 4.r,
              ),
              SizedBox(width: 8.w),
              _ShimmerBox(
                controller: controller,
                width: 85.w,
                height: 11.h,
                radius: 5.r,
              ),
              const Spacer(),
              _ShimmerBox(
                controller: controller,
                width: 75.w,
                height: 11.h,
                radius: 5.r,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          _ShimmerBox(
            controller: controller,
            width: double.infinity,
            height: 46.h,
            radius: 12.r,
          ),
        ],
      ),
    );
  }
}

class _ShimmerInfoItem extends StatelessWidget {
  const _ShimmerInfoItem({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ShimmerBox(
          controller: controller,
          width: 20.w,
          height: 20.w,
          radius: 5.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                controller: controller,
                width: 55.w,
                height: 10.h,
                radius: 4.r,
              ),
              SizedBox(height: 7.h),
              _ShimmerBox(
                controller: controller,
                width: 75.w,
                height: 12.h,
                radius: 4.r,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// REUSABLE SHIMMER BOX
// ==================================================================

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final position = -1.0 + (controller.value * 3.0);

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(position, 0),
                  end: Alignment(position + 1, 0),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                  stops: const [0.25, 0.5, 0.75],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================================================================
// FILTER CHIP
// ==================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? chipColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
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
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.receipt_copy,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارش',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _shortOrderId(order.id),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
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
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.shopping_bag_copy,
                  title: 'تعداد کالا',
                  value: '${_totalItems(order)} کالا',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.payments_outlined,
                  title: 'مبلغ سفارش',
                  value: PriceFormatter.format(order.totalPrice),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Icon(
                Iconsax.calendar_1_copy,
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
                _paymentMethodText(order.paymentMethod ?? 'نامشخص'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton(
              onPressed: onDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'مشاهده جزئیات',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) return id;
    return '#${id.substring(0, 8)}';
  }

  int _totalItems(OrderEntity order) {
    return order.items.fold<int>(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }

  String _paymentMethodText(String method) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
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
    final color = _statusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار بررسی';
      case 'processing':
        return 'در حال پردازش';
      case 'shipped':
        return 'ارسال شده';
      case 'delivered':
        return 'تحویل داده شده';
      case 'canceled':
        return 'لغو شده';
      default:
        return status;
    }
  }
}

// ==================================================================
// EMPTY ORDERS
// ==================================================================

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.receipt_copy,
                size: 55.sp,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'هنوز سفارشی ندارید',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
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

class _ErrorView extends StatelessWidget {
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
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 46.h,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('تلاش مجدد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
