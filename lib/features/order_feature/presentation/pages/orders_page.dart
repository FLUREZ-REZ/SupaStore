
import 'package:flutter/material.dart';
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1100;
            final isTablet = width >= 650 && width < 1100;

            final horizontalPadding = isDesktop
                ? 32.0
                : isTablet
                ? 24.0
                : 12.0;

            final maxContentWidth = isDesktop ? 1100.0 : 850.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: _buildBody(
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody({
    required bool isDesktop,
    required bool isTablet,
  }) {
    if (_isLoading) {
      return _OrdersShimmer(
        isDesktop: isDesktop,
        isTablet: isTablet,
      );
    }

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        onRetry: _loadOrders,
      );
    }

    return Column(
      children: [
        _buildFilterBar(
          isDesktop: isDesktop,
          isTablet: isTablet,
        ),

        Expanded(
          child: _filteredOrders.isEmpty
              ? const _EmptyOrdersView()
              : RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 30,
              ),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];

                return _OrderCard(
                  order: order,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
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

  Widget _buildFilterBar({
    required bool isDesktop,
    required bool isTablet,
  }) {
    final verticalPadding = isDesktop ? 16.0 : 12.0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: verticalPadding,
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
              isDesktop: isDesktop,
            ),

            const SizedBox(width: 8),

            _FilterChip(
              title: 'در انتظار',
              selected: _selectedStatus == 'pending',
              color: Colors.orange,
              onTap: () => _changeFilter('pending'),
              isDesktop: isDesktop,
            ),

            const SizedBox(width: 8),

            _FilterChip(
              title: 'در حال پردازش',
              selected: _selectedStatus == 'processing',
              color: Colors.blue,
              onTap: () => _changeFilter('processing'),
              isDesktop: isDesktop,
            ),

            const SizedBox(width: 8),

            _FilterChip(
              title: 'ارسال شده',
              selected: _selectedStatus == 'shipped',
              color: Colors.indigo,
              onTap: () => _changeFilter('shipped'),
              isDesktop: isDesktop,
            ),

            const SizedBox(width: 8),

            _FilterChip(
              title: 'تحویل شده',
              selected: _selectedStatus == 'delivered',
              color: Colors.green,
              onTap: () => _changeFilter('delivered'),
              isDesktop: isDesktop,
            ),

            const SizedBox(width: 8),

            _FilterChip(
              title: 'لغو شده',
              selected: _selectedStatus == 'canceled',
              color: Colors.red,
              onTap: () => _changeFilter('canceled'),
              isDesktop: isDesktop,
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
  const _OrdersShimmer({
    required this.isDesktop,
    required this.isTablet,
  });

  final bool isDesktop;
  final bool isTablet;

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
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _ShimmerBox(
                    controller: _controller,
                    width: 58,
                    height: 34,
                    radius: 20,
                  ),

                  const SizedBox(width: 8),

                  _ShimmerBox(
                    controller: _controller,
                    width: 82,
                    height: 34,
                    radius: 20,
                  ),

                  const SizedBox(width: 8),

                  _ShimmerBox(
                    controller: _controller,
                    width: 105,
                    height: 34,
                    radius: 20,
                  ),

                  const SizedBox(width: 8),

                  _ShimmerBox(
                    controller: _controller,
                    width: 78,
                    height: 34,
                    radius: 20,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 30,
                ),
                itemCount: widget.isDesktop ? 5 : 4,
                itemBuilder: (context, index) {
                  return _OrderCardShimmer(
                    controller: _controller,
                    isDesktop: widget.isDesktop,
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
    required this.isDesktop,
  });

  final AnimationController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 8 : 4,
        vertical: 7,
      ),
      padding: EdgeInsets.all(isDesktop ? 22 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 44,
                height: 44,
                radius: 12,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      controller: controller,
                      width: 45,
                      height: 10,
                      radius: 5,
                    ),

                    const SizedBox(height: 8),

                    _ShimmerBox(
                      controller: controller,
                      width: 115,
                      height: 14,
                      radius: 5,
                    ),
                  ],
                ),
              ),

              _ShimmerBox(
                controller: controller,
                width: 78,
                height: 28,
                radius: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _ShimmerInfoItem(
                  controller: controller,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _ShimmerInfoItem(
                  controller: controller,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 16,
                height: 16,
                radius: 4,
              ),

              const SizedBox(width: 8),

              _ShimmerBox(
                controller: controller,
                width: 85,
                height: 11,
                radius: 5,
              ),

              const Spacer(),

              _ShimmerBox(
                controller: controller,
                width: 75,
                height: 11,
                radius: 5,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _ShimmerBox(
            controller: controller,
            width: double.infinity,
            height: 46,
            radius: 12,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SHIMMER INFO ITEM
// ==================================================================

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
          width: 20,
          height: 20,
          radius: 5,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                controller: controller,
                width: 55,
                height: 10,
                radius: 4,
              ),

              const SizedBox(height: 7),

              _ShimmerBox(
                controller: controller,
                width: 75,
                height: 12,
                radius: 4,
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
    required this.isDesktop,
    this.color,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool isDesktop;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 17 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 13 : 12,
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
    required this.isDesktop,
    required this.isTablet,
  });

  final OrderEntity order;
  final VoidCallback onDetails;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isDesktop ? 22.0 : 16.0;
    final iconSize = isDesktop ? 48.0 : 44.0;
    final titleFontSize = isDesktop ? 15.0 : 14.0;
    final infoFontSize = isDesktop ? 13.0 : 12.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 8 : 4,
        vertical: 7,
      ),
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER

          Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.receipt_copy,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارش',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _shortOrderId(order.id),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _StatusBadge(
                status: order.status,
                isDesktop: isDesktop,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 14),

          // ORDER INFORMATION

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Iconsax.shopping_bag_copy,
                  title: 'تعداد کالا',
                  value: '${_totalItems(order)} کالا',
                  fontSize: infoFontSize,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _InfoItem(
                  icon: Icons.payments_outlined,
                  title: 'مبلغ سفارش',
                  value: PriceFormatter.format(order.totalPrice),
                  fontSize: infoFontSize,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // DATE AND PAYMENT

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.calendar_1_copy,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: infoFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              Text(
                _paymentMethodText(order.paymentMethod ?? 'نامشخص'),
                style: TextStyle(
                  fontSize: infoFontSize,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DETAILS BUTTON

          SizedBox(
            width: double.infinity,
            height: isDesktop ? 48 : 46,
            child: OutlinedButton(
              onPressed: onDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'مشاهده جزئیات',
                style: TextStyle(
                  fontSize: infoFontSize + 1,
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
    required this.fontSize,
  });

  final IconData icon;
  final String title;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade500,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize - 1,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
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
    required this.isDesktop,
  });

  final String status;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 13 : 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: isDesktop ? 12 : 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.receipt_copy,
                size: 55,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'هنوز سفارشی ندارید',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'سفارش‌هایی که ثبت می‌کنید در این بخش نمایش داده می‌شوند.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 16),

            const Text(
              'دریافت سفارش‌ها ناموفق بود',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
