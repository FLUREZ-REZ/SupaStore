
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_address_by_id_use_case.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/presentation/pages/admin_order_details_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/admin_order_provider.dart';

// ============================================================
// ORDERS SHIMMER
// ============================================================

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(12.w),
        children: [
          SizedBox(height: 8.h),

          _ShimmerBox(
            animation: _controller,
            width: 165.w,
            height: 22.h,
          ),

          SizedBox(height: 18.h),

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                _ShimmerBox(
                  animation: _controller,
                  width: 22.w,
                  height: 22.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ShimmerBox(
                    animation: _controller,
                    width: double.infinity,
                    height: 17.h,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          ...List.generate(
            4,
                (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _OrderCardShimmer(
                animation: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCardShimmer extends StatelessWidget {
  const _OrderCardShimmer({
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ShimmerBox(
                animation: animation,
                width: 42.w,
                height: 42.w,
                radius: 12.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      animation: animation,
                      width: 115.w,
                      height: 14.h,
                    ),
                    SizedBox(height: 7.h),
                    _ShimmerBox(
                      animation: animation,
                      width: 145.w,
                      height: 10.h,
                    ),
                  ],
                ),
              ),
              _ShimmerBox(
                animation: animation,
                width: 65.w,
                height: 27.h,
                radius: 20.r,
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 14.h),

          ...List.generate(
            4,
                (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  _ShimmerBox(
                    animation: animation,
                    width: 17.w,
                    height: 17.w,
                  ),
                  SizedBox(width: 8.w),
                  _ShimmerBox(
                    animation: animation,
                    width: 75.w,
                    height: 12.h,
                  ),
                  const Spacer(),
                  _ShimmerBox(
                    animation: animation,
                    width: index == 1 ? 100.w : 75.w,
                    height: 12.h,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          _ShimmerBox(
            animation: animation,
            width: double.infinity,
            height: 43.h,
            radius: 10.r,
          ),

          SizedBox(height: 12.h),

          _ShimmerBox(
            animation: animation,
            width: double.infinity,
            height: 38.h,
            radius: 10.r,
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animation,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final start = -1.5 + animation.value * 3;

          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(start, 0),
                end: Alignment(start + 1, 0),
                colors: const [
                  Color(0xFFE7EAF0),
                  Color(0xFFF8FAFC),
                  Color(0xFFE7EAF0),
                ],
                stops: const [0, 0.5, 1],
              ).createShader(bounds);
            },
            child: Container(
              width: width,
              height: height,
              color: const Color(0xFFE7EAF0),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ADMIN ORDERS PAGE
// ============================================================

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final AdminOrderProvider _provider;

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  static const Color _primaryColor = Color(0xFFE21B23);
  static const Color _backgroundColor = Color(0xFFF7F7F8);
  static const Color _textColor = Color(0xFF222222);
  static const Color _secondaryTextColor = Color(0xFF777777);

  @override
  void initState() {
    super.initState();

    _provider = getIt<AdminOrderProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return orders;
    }

    return orders.where((order) {
      final trackingCode = order.trackingCode?.toLowerCase() ?? '';
      final orderId = order.id.toLowerCase();

      return trackingCode.contains(query) ||
          orderId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminOrderProvider>.value(
      value: _provider,
      child: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          final orders = _filterOrders(provider.orders);

          return Scaffold(
            backgroundColor: _backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'مدیریت سفارش‌ها',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(
                color: _textColor,
              ),
            ),
            body: Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: _buildOrdersContent(
                    context: context,
                    provider: provider,
                    orders: orders,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'جست‌وجو با کد رهگیری یا شناسه سفارش',
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: _secondaryTextColor,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _secondaryTextColor,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            tooltip: 'پاک کردن جست‌وجو',
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: _backgroundColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 14.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: _primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersContent({
    required BuildContext context,
    required AdminOrderProvider provider,
    required List<OrderEntity> orders,
  }) {
    // شیمر فقط هنگام بارگذاری اولیه نمایش داده می‌شود.
    // هنگام Refresh، اگر سفارش‌های قبلی وجود داشته باشند،
    // لیست آن‌ها از صفحه حذف نمی‌شود.
    if (provider.isLoading && provider.orders.isEmpty) {
      return const _OrdersShimmer();
    }

    if (provider.error != null && provider.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: _primaryColor,
                size: 42.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => provider.loadOrders(),
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.shopping_bag_outlined,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                _searchQuery.isNotEmpty
                    ? 'سفارشی با این کد یا شناسه پیدا نشد.'
                    : 'هنوز سفارشی ثبت نشده است.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: () => provider.loadOrders(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(12.w),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return _AdminOrderCard(
            order: order,
            provider: provider,
          );
        },
      ),
    );
  }
}

// ============================================================
// ADMIN ORDER CARD
// ============================================================

class _AdminOrderCard extends StatelessWidget {
  final OrderEntity order;
  final AdminOrderProvider provider;

  const _AdminOrderCard({
    required this.order,
    required this.provider,
  });

  static const Color _primaryColor = Color(0xFFE21B23);
  static const Color _textColor = Color(0xFF222222);
  static const Color _secondaryTextColor = Color(0xFF777777);

  String get _trackingCode {
    final code = order.trackingCode?.trim();

    if (code == null || code.isEmpty) {
      return 'ثبت نشده';
    }

    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            SizedBox(height: 14.h),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.receipt_long_outlined,
              title: 'شناسه سفارش',
              value: _shortOrderId(order.id),
              direction: TextDirection.ltr,
            ),
            SizedBox(height: 10.h),
            _buildInfoRow(
              icon: Icons.local_shipping_outlined,
              title: 'کد رهگیری',
              value: _trackingCode,
              direction: TextDirection.ltr,
            ),
            SizedBox(height: 10.h),
            _buildInfoRow(
              icon: Icons.shopping_bag_outlined,
              title: 'تعداد اقلام',
              value: '${order.items.length} مورد',
            ),
            SizedBox(height: 10.h),
            _buildInfoRow(
              icon: Icons.payment_outlined,
              title: 'وضعیت پرداخت',
              value: _paymentStatusLabel(order.paymentStatus),
            ),
            SizedBox(height: 14.h),
            _buildTotal(),
            SizedBox(height: 12.h),
            _buildDetailsHint(context),
            SizedBox(height: 12.h),
            _buildStatusButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: _primaryColor,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سفارش ${_shortOrderId(order.id)}',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                _trackingCode,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          tooltip: 'کپی کد رهگیری',
          visualDensity: VisualDensity.compact,
          onPressed: order.trackingCode == null ||
              order.trackingCode!.trim().isEmpty
              ? null
              : () async {
            final code = order.trackingCode!.trim();

            await Clipboard.setData(
              ClipboardData(text: code),
            );

            if (!context.mounted) return;

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('کد رهگیری کپی شد.'),
                  duration: Duration(seconds: 2),
                ),
              );
          },
          icon: const Icon(
            Icons.copy_outlined,
            color: _primaryColor,
          ),
        ),
        _StatusBadge(status: order.status),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    TextDirection direction = TextDirection.rtl,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17.sp,
          color: _secondaryTextColor,
        ),
        SizedBox(width: 7.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: _secondaryTextColor,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textDirection: direction,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Text(
            'مبلغ کل',
            style: TextStyle(
              fontSize: 13.sp,
              color: _secondaryTextColor,
            ),
          ),
          const Spacer(),
          Text(
            '${_formatPrice(order.totalPrice)} تومان',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsHint(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => _openDetails(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مشاهده جزئیات سفارش',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.arrow_back_ios_new,
              size: 13.sp,
              color: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminOrderDetailsPage(
          order: order,
          provider: provider,
          getAddressByIdUseCase: getIt<GetAddressByIdUseCase>(),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showStatusDialog(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('تغییر وضعیت سفارش'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          padding: EdgeInsets.symmetric(vertical: 11.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(BuildContext context) async {
    const statuses = <String, String>{
      'pending': 'در انتظار',
      'processing': 'در حال پردازش',
      'shipped': 'ارسال شده',
      'delivered': 'تحویل شده',
      'canceled': 'لغو شده',
    };

    String selectedStatus =
    statuses.containsKey(order.status) ? order.status : 'pending';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'تغییر وضعیت سفارش',
                textAlign: TextAlign.right,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.entries.map((entry) {
                  return RadioListTile<String>(
                    value: entry.key,
                    groupValue: selectedStatus,
                    title: Text(
                      entry.value,
                      textAlign: TextAlign.right,
                    ),
                    activeColor: _primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    selectedStatus,
                  ),
                  child: const Text('ثبت وضعیت'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result == order.status) return;

    final success = await provider.updateOrderStatus(
      orderId: order.id,
      status: result,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'وضعیت سفارش به «${statuses[result]}» تغییر کرد.'
                : 'تغییر وضعیت سفارش انجام نشد.',
          ),
        ),
      );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  String _formatPrice(num price) {
    final value = price.round().toString();

    return value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  String _paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'پرداخت شده';
      case 'pending':
        return 'در انتظار پرداخت';
      case 'failed':
        return 'ناموفق';
      case 'refunded':
        return 'مسترد شده';
      case 'unpaid':
        return 'پرداخت نشده';
      default:
        return status;
    }
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const _StatusConfig(
          label: 'در انتظار',
          backgroundColor: Color(0xFFFFF3CD),
          textColor: Color(0xFF856404),
        );

      case 'processing':
        return const _StatusConfig(
          label: 'در حال پردازش',
          backgroundColor: Color(0xFFDDEBFF),
          textColor: Color(0xFF1556A6),
        );

      case 'shipped':
        return const _StatusConfig(
          label: 'ارسال شده',
          backgroundColor: Color(0xFFE5DDFB),
          textColor: Color(0xFF5936A8),
        );

      case 'delivered':
        return const _StatusConfig(
          label: 'تحویل شده',
          backgroundColor: Color(0xFFD4EDDA),
          textColor: Color(0xFF155724),
        );

      case 'canceled':
      case 'cancelled':
        return const _StatusConfig(
          label: 'لغو شده',
          backgroundColor: Color(0xFFF8D7DA),
          textColor: Color(0xFF721C24),
        );

      default:
        return _StatusConfig(
          label: status,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
