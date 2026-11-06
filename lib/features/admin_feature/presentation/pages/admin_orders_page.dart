
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_address_by_id_use_case.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/presentation/pages/admin_order_details_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/admin_order_provider.dart';

// ============================================================
// COLORS
// ============================================================

const Color _primaryColor = Color(0xFFE21B23);
const Color _backgroundColor = Color(0xFFF7F7F8);
const Color _textColor = Color(0xFF222222);
const Color _secondaryTextColor = Color(0xFF777777);

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 3
            : width >= 700
            ? 2
            : 1;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(width < 600 ? 12 : 20),
            children: [
              const SizedBox(height: 8),
              _ShimmerBox(
                animation: _controller,
                width: 165,
                height: 22,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _ShimmerBox(
                      animation: _controller,
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ShimmerBox(
                        animation: _controller,
                        width: double.infinity,
                        height: 17,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: columns * 2,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  return _OrderCardShimmer(
                    animation: _controller,
                  );
                },
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                width: 42,
                height: 42,
                radius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      animation: animation,
                      width: 115,
                      height: 14,
                    ),
                    const SizedBox(height: 7),
                    _ShimmerBox(
                      animation: animation,
                      width: 145,
                      height: 10,
                    ),
                  ],
                ),
              ),
              _ShimmerBox(
                animation: animation,
                width: 65,
                height: 27,
                radius: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          ...List.generate(
            4,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _ShimmerBox(
                    animation: animation,
                    width: 17,
                    height: 17,
                  ),
                  const SizedBox(width: 8),
                  _ShimmerBox(
                    animation: animation,
                    width: 75,
                    height: 12,
                  ),
                  const Spacer(),
                  _ShimmerBox(
                    animation: animation,
                    width: index == 1 ? 100 : 75,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _ShimmerBox(
            animation: animation,
            width: double.infinity,
            height: 43,
            radius: 10,
          ),
          const SizedBox(height: 12),
          _ShimmerBox(
            animation: animation,
            width: double.infinity,
            height: 38,
            radius: 10,
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

    if (query.isEmpty) return orders;

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

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: _backgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  'مدیریت سفارش‌ها',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
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
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
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
              hintStyle: const TextStyle(
                fontSize: 12,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildOrdersContent({
    required BuildContext context,
    required AdminOrderProvider provider,
    required List<OrderEntity> orders,
  }) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const _OrdersShimmer();
    }

    if (provider.error != null && provider.orders.isEmpty) {
      return _buildErrorState(provider);
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1250
            ? 3
            : width >= 750
            ? 2
            : 1;

        final horizontalPadding = width < 600 ? 12.0 : 20.0;

        return RefreshIndicator(
          color: _primaryColor,
          onRefresh: () => provider.loadOrders(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                itemCount: orders.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 390,
                ),
                itemBuilder: (context, index) {
                  return _AdminOrderCard(
                    order: orders[index],
                    provider: provider,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(AdminOrderProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: _primaryColor,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.shopping_bag_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'سفارشی با این کد یا شناسه پیدا نشد.'
                  : 'هنوز سفارشی ثبت نشده است.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _secondaryTextColor,
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.receipt_long_outlined,
              title: 'شناسه سفارش',
              value: _shortOrderId(order.id),
              direction: TextDirection.ltr,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.local_shipping_outlined,
              title: 'کد رهگیری',
              value: _trackingCode,
              direction: TextDirection.ltr,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.shopping_bag_outlined,
              title: 'تعداد اقلام',
              value: '${order.items.length} مورد',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.payment_outlined,
              title: 'وضعیت پرداخت',
              value: _paymentStatusLabel(order.paymentStatus),
            ),
            const SizedBox(height: 14),
            _buildTotal(),
            const Spacer(),
            _buildDetailsHint(context),
            const SizedBox(height: 10),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: _primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سفارش ${_shortOrderId(order.id)}',
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _trackingCode,
                textDirection: TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'کپی کد رهگیری',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 34,
          ),
          padding: EdgeInsets.zero,
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
            size: 19,
          ),
        ),
        const SizedBox(width: 4),
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
          size: 17,
          color: _secondaryTextColor,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: _secondaryTextColor,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textDirection: direction,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text(
            'مبلغ کل',
            style: TextStyle(
              fontSize: 13,
              color: _secondaryTextColor,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              '${_formatPrice(order.totalPrice)} تومان',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsHint(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openDetails(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مشاهده جزئیات سفارش',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.arrow_back_ios_new,
              size: 13,
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
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('تغییر وضعیت سفارش'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS DIALOG
  // ============================================================

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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text(
                  'تغییر وضعیت سفارش',
                  textAlign: TextAlign.right,
                ),
                content: SingleChildScrollView(
                  child: Column(
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
          ),
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

  // ============================================================
  // HELPERS
  // ============================================================

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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        maxLines: 1,
        style: TextStyle(
          color: config.textColor,
          fontSize: 10,
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
