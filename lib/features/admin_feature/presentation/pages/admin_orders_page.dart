import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/presentation/providers/admin_order_provider.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({
    super.key,
  });

  @override
  State<AdminOrdersPage> createState() =>
      _AdminOrdersPageState();
}

class _AdminOrdersPageState
    extends State<AdminOrdersPage> {
  late final AdminOrderProvider _provider;

  @override
  void initState() {
    super.initState();

    _provider = getIt<AdminOrderProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<AdminOrderProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoading &&
              provider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null &&
              provider.orders.isEmpty) {
            return _buildError(
              context,
              provider,
            );
          }

          if (provider.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.refreshOrders,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 300.h,
                  ),
                  const Center(
                    child: Text(
                      'هیچ سفارشی ثبت نشده است.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshOrders,
            child: ListView.builder(
              padding: EdgeInsets.all(20.w),
              physics:
              const AlwaysScrollableScrollPhysics(),
              itemCount: provider.orders.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final order =
                provider.orders[index];

                return _AdminOrderCard(
                  order: order,
                  provider: provider,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      AdminOrderProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: provider.loadOrders,
              child: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({
    required this.order,
    required this.provider,
  });

  final OrderEntity order;
  final AdminOrderProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'سفارش #${_shortOrderId(order.id)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(
                  status: order.status,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Text(
              'تعداد کالا: ${order.items.length}',
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              'مبلغ: ${_formatPrice(order.totalPrice)} تومان',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              'پرداخت: ${_paymentStatusText(order.paymentStatus)}',
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),

            SizedBox(height: 14.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: provider.isUpdating
                    ? null
                    : () {
                  _showStatusDialog(
                    context,
                    provider,
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                label: const Text(
                  'تغییر وضعیت سفارش',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(
      BuildContext context,
      AdminOrderProvider provider,
      ) async {
    final selectedStatus =
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'وضعیت سفارش',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusOption(
                context,
                'pending',
                'در انتظار بررسی',
              ),
              _statusOption(
                context,
                'processing',
                'در حال پردازش',
              ),
              _statusOption(
                context,
                'shipped',
                'ارسال شده',
              ),
              _statusOption(
                context,
                'delivered',
                'تحویل داده شده',
              ),
              _statusOption(
                context,
                'canceled',
                'لغو شده',
              ),
            ],
          ),
        );
      },
    );

    if (selectedStatus == null ||
        selectedStatus == order.status) {
      return;
    }

    if (!context.mounted) return;

    final success =
    await provider.updateOrderStatus(
      orderId: order.id,
      status: selectedStatus,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'وضعیت سفارش با موفقیت تغییر کرد.',
          ),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
      );
    }
  }

  Widget _statusOption(
      BuildContext context,
      String value,
      String title,
      ) {
    return RadioListTile<String>(
      value: value,
      groupValue: order.status,
      title: Text(title),
      onChanged: (value) {
        if (value != null) {
          Navigator.of(context).pop(value);
        }
      },
    );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return id.substring(0, 8);
  }

  String _formatPrice(int price) {
    return price
        .toString()
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  String _paymentStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'پرداخت شده';

      case 'pending':
        return 'در انتظار پرداخت';

      case 'failed':
        return 'ناموفق';

      case 'canceled':
        return 'لغو شده';

      case 'refunded':
        return 'مبلغ بازگشت داده شده';

      default:
        return status;
    }
  }
}

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
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
      case 'cancelled':
        return 'لغو شده';

      default:
        return status;
    }
  }
}