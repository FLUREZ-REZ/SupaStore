import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_address_by_id_use_case.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/presentation/pages/admin_order_details_page.dart';
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

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _provider.loadOrders();
      },
    );
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
                  Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'هیچ سفارشی ثبت نشده است.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshOrders,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                30.h,
              ),
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
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 34.sp,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'خطا در دریافت سفارش‌ها',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: provider.loadOrders,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'تلاش مجدد',
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
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
    return Container(
      margin: EdgeInsets.only(
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AdminOrderDetailsPage(
                      order: order,
                      provider: provider,
                      getAddressByIdUseCase:
                      getIt<GetAddressByIdUseCase>(),
                    ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                SizedBox(height: 16.h),

                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),

                SizedBox(height: 16.h),

                _buildInfoRow(),

                SizedBox(height: 14.h),

                _buildTotal(),

                SizedBox(height: 14.h),

                _buildDetailsHint(),

                SizedBox(height: 14.h),

                _buildStatusButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius:
            BorderRadius.circular(13.r),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 22.sp,
            color: Colors.grey.shade700,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'شماره سفارش',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '#${_shortOrderId(order.id).toUpperCase()}',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        _StatusBadge(
          status: order.status,
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoBox(
            icon: Icons.shopping_bag_outlined,
            title: 'تعداد کالا',
            value:
            '${order.items.length} کالا',
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: _InfoBox(
            icon: Icons.credit_card_outlined,
            title: 'وضعیت پرداخت',
            value: _paymentStatusText(
              order.paymentStatus,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(13.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 19.sp,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'مبلغ نهایی سفارش',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${_formatPrice(order.totalPrice)} تومان',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsHint() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app_outlined,
          size: 15.sp,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 6.w),
        Text(
          'برای مشاهده جزئیات سفارش لمس کنید',
          style: TextStyle(
            fontSize: 10.5.sp,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
      BuildContext context,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 47.h,
      child: OutlinedButton.icon(
        onPressed: provider.isUpdating
            ? null
            : () {
          _showStatusDialog(
            context,
            provider,
          );
        },
        icon: Icon(
          Icons.edit_outlined,
          size: 18.sp,
        ),
        label: Text(
          'تغییر وضعیت سفارش',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(
            color: Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12.r),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18.r),
          ),
          title: const Text(
            'وضعیت سفارش',
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
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

    if (!context.mounted) {
      return;
    }

    final success =
    await provider.updateOrderStatus(
      orderId: order.id,
      status: selectedStatus,
    );

    if (!context.mounted) {
      return;
    }

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
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onChanged: (value) {
        if (value != null) {
          Navigator.of(context).pop(
            value,
          );
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
    return price.toString().replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
          (match) => ',',
    );
  }

  String _paymentStatusText(
      String status,
      ) {
    switch (status) {
      case 'paid':
        return 'پرداخت شده';

      case 'pending':
        return 'در انتظار پرداخت';

      case 'failed':
        return 'ناموفق';

      case 'canceled':
      case 'cancelled':
        return 'لغو شده';

      case 'refunded':
        return 'بازگشت وجه';

      default:
        return status;
    }
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(13.r),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(9.r),
            ),
            child: Icon(
              icon,
              size: 17.sp,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius:
        BorderRadius.circular(10.r),
        border: Border.all(
          color: config.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: config.foregroundColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            config.title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: config.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case 'pending':
        return _StatusConfig(
          title: 'در انتظار بررسی',
          foregroundColor:
          Colors.orange.shade700,
          backgroundColor:
          Colors.orange.withOpacity(0.08),
          borderColor:
          Colors.orange.withOpacity(0.15),
        );

      case 'processing':
        return _StatusConfig(
          title: 'در حال پردازش',
          foregroundColor:
          Colors.blue.shade700,
          backgroundColor:
          Colors.blue.withOpacity(0.08),
          borderColor:
          Colors.blue.withOpacity(0.15),
        );

      case 'shipped':
        return _StatusConfig(
          title: 'ارسال شده',
          foregroundColor:
          Colors.indigo.shade700,
          backgroundColor:
          Colors.indigo.withOpacity(0.08),
          borderColor:
          Colors.indigo.withOpacity(0.15),
        );

      case 'delivered':
        return _StatusConfig(
          title: 'تحویل داده شده',
          foregroundColor:
          Colors.green.shade700,
          backgroundColor:
          Colors.green.withOpacity(0.08),
          borderColor:
          Colors.green.withOpacity(0.15),
        );

      case 'canceled':
      case 'cancelled':
        return _StatusConfig(
          title: 'لغو شده',
          foregroundColor:
          Colors.red.shade700,
          backgroundColor:
          Colors.red.withOpacity(0.08),
          borderColor:
          Colors.red.withOpacity(0.15),
        );

      default:
        return _StatusConfig(
          title: status,
          foregroundColor:
          Colors.grey.shade700,
          backgroundColor:
          Colors.grey.withOpacity(0.08),
          borderColor:
          Colors.grey.withOpacity(0.15),
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.title,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String title;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
}