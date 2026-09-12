import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_address_by_id_use_case.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/entities/order_item_entity.dart';
import 'package:supastore/features/order_feature/presentation/providers/admin_order_provider.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  const AdminOrderDetailsPage({
    super.key,
    required this.order,
    required this.provider,
    required this.getAddressByIdUseCase,
  });

  final OrderEntity order;
  final AdminOrderProvider provider;
  final GetAddressByIdUseCase getAddressByIdUseCase;

  @override
  State<AdminOrderDetailsPage> createState() =>
      _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState
    extends State<AdminOrderDetailsPage> {
  AddressEntity? _address;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final addressId = widget.order.addressId;

    if (addressId == null || addressId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final result = await widget.getAddressByIdUseCase(
        addressId: addressId,
      );

      if (!mounted) return;

      setState(() {
        _address = result;
        _isLoadingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  String _formatPrice(int value) {
    return _addThousandsSeparator(value);
  }

  String _addThousandsSeparator(int number) {
    final value = number.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(value[i]);
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - $hour:$minute';
  }

  String _statusTitle(String status) {
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

  String _paymentStatusTitle(String status) {
    switch (status) {
      case 'paid':
        return 'پرداخت شده';

      case 'pending':
        return 'در انتظار پرداخت';

      case 'failed':
        return 'پرداخت ناموفق';

      case 'refunded':
        return 'مبلغ برگشت داده شده';

      default:
        return status;
    }
  }

  String _paymentMethodTitle(String? method) {
    if (method == null || method.isEmpty) {
      return 'نامشخص';
    }

    switch (method) {
      case 'online':
        return 'پرداخت آنلاین';

      case 'cash':
        return 'پرداخت در محل';

      case 'wallet':
        return 'کیف پول';

      default:
        return method;
    }
  }

  Future<void> _showChangeStatusDialog() async {
    const statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'canceled',
    ];

    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String selected = widget.order.status;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'تغییر وضعیت سفارش',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    value: status,
                    groupValue: selected,
                    title: Text(
                      _statusTitle(status),
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selected = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('انصراف'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selected,
                    );
                  },
                  child: const Text('تأیید'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedStatus == null ||
        selectedStatus == widget.order.status) {
      return;
    }

    final success =
    await widget.provider.updateOrderStatus(
      orderId: widget.order.id,
      status: selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'وضعیت سفارش با موفقیت تغییر کرد.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      final error = widget.provider.error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'تغییر وضعیت سفارش ناموفق بود.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.black87,
        centerTitle: false,
        title: const Text(
          'جزئیات سفارش',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),

              SizedBox(height: 16.h),

              _buildStatusCard(order),

              SizedBox(height: 16.h),

              _buildCustomerCard(order),

              SizedBox(height: 16.h),

              _buildAddressCard(),

              SizedBox(height: 16.h),

              _buildPaymentCard(order),

              SizedBox(height: 16.h),

              _buildProductsCard(order),

              SizedBox(height: 16.h),

              _buildPriceSummary(order),

              SizedBox(height: 24.h),

              _buildChangeStatusButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
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
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: order.status,
                title: _statusTitle(order.status),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _HeaderInfo(
                  icon: Icons.calendar_today_rounded,
                  title: 'تاریخ ثبت',
                  value: _formatDate(order.createdAt),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _HeaderInfo(
                  icon: Icons.shopping_bag_outlined,
                  title: 'تعداد کالا',
                  value: '${order.items.length} کالا',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderEntity order) {
    final statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
    ];

    final currentIndex =
    statuses.indexOf(order.status);

    final isCanceled =
        order.status == 'canceled';

    return _SectionCard(
      title: 'وضعیت سفارش',
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: [
          if (isCanceled)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: Colors.red.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red.shade700,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'این سفارش لغو شده است.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(
                statuses.length,
                    (index) {
                  final status = statuses[index];

                  final completed =
                      currentIndex >= index;

                  final active =
                      currentIndex == index;

                  return _StatusTimelineItem(
                    title: _statusTitle(status),
                    active: active,
                    completed: completed,
                    isLast:
                    index == statuses.length - 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderEntity order) {
    return _SectionCard(
      title: 'اطلاعات مشتری',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.fingerprint_rounded,
            title: 'شناسه کاربر',
            value: order.userId,
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.access_time_rounded,
            title: 'آخرین بروزرسانی',
            value: _formatDate(order.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return _SectionCard(
      title: 'اطلاعات ارسال',
      icon: Icons.location_on_outlined,
      child: _isLoadingAddress
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      )
          : _address != null
          ? Column(
        children: [
          _InfoRow(
            icon: Icons.label_outline_rounded,
            title: 'عنوان',
            value: _address!.title,
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.person_outline,
            title: 'تحویل گیرنده',
            value: _address!.receiverName,
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.phone_outlined,
            title: 'شماره تماس',
            value: _address!.phone,
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.map_outlined,
            title: 'استان / شهر',
            value:
            '${_address!.province} - ${_address!.city}',
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.home_outlined,
            title: 'آدرس',
            value: _address!.address,
          ),
          if (_address!.postalCode != null &&
              _address!.postalCode!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _InfoRow(
              icon: Icons.mail_outline_outlined,
              title: 'کد پستی',
              value: _address!.postalCode!,
            ),
          ],
        ],
      )
          : _buildShippingAddressFallback(),
    );
  }

  Widget _buildShippingAddressFallback() {
    final shippingAddress =
        widget.order.shippingAddress;

    if (shippingAddress == null ||
        shippingAddress.isEmpty) {
      return const _EmptyInfo(
        text: 'اطلاعات آدرس موجود نیست.',
      );
    }

    return _InfoRow(
      icon: Icons.home_outlined,
      title: 'آدرس',
      value: shippingAddress,
    );
  }

  Widget _buildPaymentCard(OrderEntity order) {
    final isPaid =
        order.paymentStatus == 'paid';

    return _SectionCard(
      title: 'اطلاعات پرداخت',
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.credit_card_outlined,
            title: 'روش پرداخت',
            value:
            _paymentMethodTitle(order.paymentMethod),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'وضعیت پرداخت',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.09)
                      : Colors.orange.withOpacity(0.09),
                  borderRadius:
                  BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 17.sp,
                      color: isPaid
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _paymentStatusTitle(
                        order.paymentStatus,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isPaid
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(OrderEntity order) {
    return _SectionCard(
      title: 'محصولات سفارش',
      icon: Icons.inventory_2_outlined,
      trailing: Text(
        '${order.items.length} کالا',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < order.items.length; i++) ...[
            _OrderProductItem(
              item: order.items[i],
              formatPrice: _formatPrice,
            ),
            if (i != order.items.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 14.h,
                ),
                child: Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSummary(OrderEntity order) {
    return _SectionCard(
      title: 'خلاصه مالی',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          _PriceRow(
            title: 'جمع کالاها',
            value:
            '${_formatPrice(order.subtotal)} تومان',
          ),
          SizedBox(height: 12.h),
          _PriceRow(
            title: 'تخفیف',
            value:
            '${_formatPrice(order.discount)} تومان',
            valueColor: Colors.green.shade700,
            prefix: '-',
          ),
          SizedBox(height: 12.h),
          _PriceRow(
            title: 'هزینه ارسال',
            value:
            '${_formatPrice(order.shippingCost)} تومان',
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16.h,
            ),
            child: Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'مبلغ نهایی',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_formatPrice(order.totalPrice)} تومان',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeStatusButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: widget.provider.isUpdating
            ? null
            : _showChangeStatusDialog,
        icon: widget.provider.isUpdating
            ? SizedBox(
          width: 19.w,
          height: 19.w,
          child:
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.edit_outlined,
        ),
        label: Text(
          widget.provider.isUpdating
              ? 'در حال بروزرسانی...'
              : 'تغییر وضعیت سفارش',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15.r),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.09),
                  borderRadius:
                  BorderRadius.circular(11.r),
                ),
                child: Icon(
                  icon,
                  size: 19.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

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
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19.sp,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 82.w,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.prefix,
  });

  final String title;
  final String value;
  final Color? valueColor;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          '${prefix ?? ''}$value',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({
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
          size: 18.sp,
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
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTimelineItem extends StatelessWidget {
  const _StatusTimelineItem({
    required this.title,
    required this.active,
    required this.completed,
    required this.isLast,
  });

  final String title;
  final bool active;
  final bool completed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.primary
        : Colors.grey.shade300;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28.w,
          child: Column(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? AppColors.primary
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: color,
                    width: 1.5,
                  ),
                ),
                child: completed
                    ? Icon(
                  active
                      ? Icons.radio_button_checked
                      : Icons.check,
                  size: 14.sp,
                  color: Colors.white,
                )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30.h,
                  color: color,
                ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 3.h,
              bottom: isLast ? 0 : 20.h,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: active
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: active
                    ? Colors.black87
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderProductItem extends StatelessWidget {
  const _OrderProductItem({
    required this.item,
    required this.formatPrice,
  });

  final OrderItemEntity item;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 82.w,
          height: 82.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius:
            BorderRadius.circular(14.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.productThumbnail != null &&
              item.productThumbnail!.isNotEmpty
              ? Image.network(
            item.productThumbnail!,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) {
              return Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade400,
                size: 28.sp,
              );
            },
          )
              : Icon(
            Icons.image_outlined,
            color: Colors.grey.shade400,
            size: 28.sp,
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
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 9.h),
              Text(
                'تعداد: ${item.quantity}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${formatPrice(item.unitPrice)} تومان',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Text(
              '${formatPrice(item.totalPrice)}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'تومان',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.title,
  });

  final String status;
  final String title;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'pending':
        color = Colors.orange.shade700;
        break;

      case 'processing':
        color = Colors.blue.shade700;
        break;

      case 'shipped':
        color = Colors.indigo.shade700;
        break;

      case 'delivered':
        color = Colors.green.shade700;
        break;

      case 'canceled':
        color = Colors.red.shade700;
        break;

      default:
        color = Colors.grey.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  const _EmptyInfo({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}