
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

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

  String _shortOrderId(String id) {
    return id.length > 8
        ? id.substring(0, 8).toUpperCase()
        : id.toUpperCase();
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
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                title: const Text(
                  'تغییر وضعیت سفارش',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: statuses.map((status) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: status,
                      groupValue: selected,
                      title: Text(
                        _statusTitle(status),
                        style: const TextStyle(fontSize: 13),
                      ),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
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
              ),
            );
          },
        );
      },
    );

    if (selectedStatus == null ||
        selectedStatus == widget.order.status) {
      return;
    }

    final success = await widget.provider.updateOrderStatus(
      orderId: widget.order.id,
      status: selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('وضعیت سفارش با موفقیت تغییر کرد.'),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF03045e),
          foregroundColor: Colors.white,
          centerTitle: false,

        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 600 ? 14 : 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderHeader(order),

                        const SizedBox(height: 18),

                        if (isDesktop)
                          _buildDesktopLayout(order)
                        else
                          _buildMobileLayout(order),

                        const SizedBox(height: 24),

                        _buildChangeStatusButton(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(OrderEntity order) {
    return Column(
      children: [
        _buildStatusCard(order),
        const SizedBox(height: 16),
        _buildCustomerCard(order),
        const SizedBox(height: 16),
        _buildAddressCard(),
        const SizedBox(height: 16),
        _buildPaymentCard(order),
        const SizedBox(height: 16),
        _buildProductsCard(order),
        const SizedBox(height: 16),
        _buildPriceSummary(order),
      ],
    );
  }

  Widget _buildDesktopLayout(OrderEntity order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatusCard(order),
              const SizedBox(height: 16),
              _buildCustomerCard(order),
              const SizedBox(height: 16),
              _buildAddressCard(),
              const SizedBox(height: 16),
              _buildPaymentCard(order),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            children: [
              _buildProductsCard(order),
              const SizedBox(height: 16),
              _buildPriceSummary(order),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(OrderEntity order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0077b6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.receipt_copy,
                  color: Color(0xFFcaf0f8),
                  size: 25,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سفارش',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${_shortOrderId(order.id)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              _StatusBadge(
                status: order.status,
                title: _statusTitle(order.status),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth < 500
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 2;

              return Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _HeaderInfo(
                      icon: Iconsax.calendar_2_copy,
                      title: 'تاریخ ثبت',
                      value: _formatDate(order.createdAt),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _HeaderInfo(
                      icon: Iconsax.shopping_bag_copy,
                      title: 'تعداد کالا',
                      value: '${order.items.length} کالا',
                    ),
                  ),
                ],
              );
            },
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

    final currentIndex = statuses.indexOf(order.status);
    final isCanceled = order.status == 'canceled';

    return _SectionCard(
      title: 'وضعیت سفارش',
      icon: Iconsax.truck_copy,
      child: Column(
        children: [
          if (isCanceled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'این سفارش لغو شده است.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
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
                  final completed = currentIndex >= index;
                  final active = currentIndex == index;

                  return _StatusTimelineItem(
                    title: _statusTitle(status),
                    active: active,
                    completed: completed,
                    isLast: index == statuses.length - 1,
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
      icon: Iconsax.user_copy,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.fingerprint_rounded,
            title: 'شناسه کاربر',
            value: order.userId,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.clock_copy,
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
      icon: Iconsax.location_copy,
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
            icon: Iconsax.subtitle_copy,
            title: 'عنوان',
            value: _address!.title,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.user_copy,
            title: 'تحویل گیرنده',
            value: _address!.receiverName,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.call_copy,
            title: 'شماره تماس',
            value: _address!.phone,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.map_copy,
            title: 'استان / شهر',
            value: '${_address!.province} - ${_address!.city}',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.house_2_copy,
            title: 'آدرس',
            value: _address!.address,
          ),
          if (_address!.postalCode != null &&
              _address!.postalCode!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Iconsax.code_copy,
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
    final shippingAddress = widget.order.shippingAddress;

    if (shippingAddress == null || shippingAddress.isEmpty) {
      return const _EmptyInfo(
        text: 'اطلاعات آدرس موجود نیست.',
      );
    }

    return _InfoRow(
      icon: Iconsax.card_copy,
      title: 'آدرس',
      value: shippingAddress,
    );
  }

  Widget _buildPaymentCard(OrderEntity order) {
    final isPaid = order.paymentStatus == 'paid';

    return _SectionCard(
      title: 'اطلاعات پرداخت',
      icon: Iconsax.card_copy,
      child: Column(
        children: [
          _InfoRow(
            icon: Iconsax.card_copy,
            title: 'روش پرداخت',
            value: _paymentMethodTitle(order.paymentMethod),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'وضعیت پرداخت:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.09)
                      : Colors.orange.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 17,
                      color: isPaid
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _paymentStatusTitle(order.paymentStatus),
                      style: TextStyle(
                        fontSize: 12,
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
      icon: Iconsax.box_1_copy,
      trailing: Text(
        '${order.items.length} کالا',
        style: TextStyle(
          fontSize: 12,
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
                padding: const EdgeInsets.symmetric(vertical: 14),
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
      icon: Iconsax.wallet_1_copy,
      child: Column(
        children: [
          _PriceRow(
            title: 'جمع کالاها',
            value: '${_formatPrice(order.subtotal)} تومان',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            title: 'تخفیف',
            value: '${_formatPrice(order.discount)} تومان',
            valueColor: Colors.green.shade700,
            prefix: '-',
          ),
          const SizedBox(height: 12),
          _PriceRow(
            title: 'هزینه ارسال',
            value: '${_formatPrice(order.shippingCost)} تومان',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              const Text(
                'مبلغ نهایی',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_formatPrice(order.totalPrice)} تومان',
                style: TextStyle(
                  fontSize: 17,
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
      height: 54,
      child: ElevatedButton.icon(
        onPressed: widget.provider.isUpdating
            ? null
            : _showChangeStatusDialog,
        icon: widget.provider.isUpdating
            ? const SizedBox(
          width: 19,
          height: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.edit_outlined),
        label: Text(
          widget.provider.isUpdating
              ? 'در حال بروزرسانی...'
              : 'تغییر وضعیت سفارش',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION CARD
// -----------------------------------------------------------------------------

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INFO ROW
// -----------------------------------------------------------------------------

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PRICE ROW
// -----------------------------------------------------------------------------

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
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            '${prefix ?? ''}$value',
            textAlign: TextAlign.left,
            softWrap: true,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HEADER INFO
// -----------------------------------------------------------------------------

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
          size: 18,
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
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 12,
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

// -----------------------------------------------------------------------------
// STATUS TIMELINE
// -----------------------------------------------------------------------------

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
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
                  size: 14,
                  color: Colors.white,
                )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: color,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 3,
              bottom: isLast ? 0 : 20,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
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

// -----------------------------------------------------------------------------
// ORDER PRODUCT ITEM
// -----------------------------------------------------------------------------

class _OrderProductItem extends StatelessWidget {
  const _OrderProductItem({
    required this.item,
    required this.formatPrice,
  });

  final OrderItemEntity item;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        final image = Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.productThumbnail != null &&
              item.productThumbnail!.isNotEmpty
              ? Image.network(
            item.productThumbnail!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Icon(
                Iconsax.image_copy,
                color: Colors.grey.shade400,
                size: 28,
              );
            },
          )
              : Icon(
            Iconsax.image_copy,
            color: Colors.grey.shade400,
            size: 28,
          ),
        );

        final productDetails = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'تعداد: ${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${formatPrice(item.unitPrice)} تومان',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );

        final totalPrice = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(item.totalPrice),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تومان',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  const SizedBox(width: 12),
                  productDetails,
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: totalPrice,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            const SizedBox(width: 12),
            productDetails,
            const SizedBox(width: 8),
            totalPrice,
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// STATUS BADGE
// -----------------------------------------------------------------------------

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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EMPTY INFO
// -----------------------------------------------------------------------------

class _EmptyInfo extends StatelessWidget {
  const _EmptyInfo({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
