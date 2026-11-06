
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/constants/price_formatter.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';

// =============================================================
// ORDER DETAILS PAGE
// =============================================================

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
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 1100;
            final isTablet = width >= 650 && width < 1100;

            final maxWidth = isDesktop
                ? 1100.0
                : isTablet
                ? 850.0
                : double.infinity;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? 24
                          : isTablet
                          ? 20
                          : 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OrderHeader(
                          order: order,
                          isDesktop: isDesktop,
                        ),
                        const SizedBox(height: 16),

                        const _SectionTitle(
                          title: 'محصولات سفارش',
                        ),
                        _OrderItemsSection(
                          order: order,
                          isDesktop: isDesktop,
                        ),
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const _SectionTitle(
                                      title: 'آدرس ارسال',
                                    ),
                                    _ShippingAddressCard(
                                      address: order.shippingAddress,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const _SectionTitle(
                                      title: 'اطلاعات ارسال و پرداخت',
                                    ),
                                    _ShippingPaymentCard(
                                      order: order,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const _SectionTitle(
                            title: 'آدرس ارسال',
                          ),
                          _ShippingAddressCard(
                            address: order.shippingAddress,
                          ),
                          const SizedBox(height: 16),
                          const _SectionTitle(
                            title: 'اطلاعات ارسال و پرداخت',
                          ),
                          _ShippingPaymentCard(
                            order: order,
                          ),
                        ],

                        const SizedBox(height: 16),
                        const _SectionTitle(
                          title: 'خلاصه سفارش',
                        ),
                        _OrderSummary(
                          order: order,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// ORDER HEADER
// =============================================================

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
    required this.isDesktop,
  });

  final OrderEntity order;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 22 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.receipt_copy,
                  color: AppColors.primary,
                  size: 25,
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
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _shortOrderId(order.id),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                status: order.status,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            spacing: 12,
            children: [
              Text(
                'تاریخ ثبت سفارش',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 13,
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
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}...';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

// =============================================================
// SECTION TITLE
// =============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
        top: 4,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =============================================================
// ORDER ITEMS
// =============================================================

class _OrderItemsSection extends StatelessWidget {
  const _OrderItemsSection({
    required this.order,
    required this.isDesktop,
  });

  final OrderEntity order;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (order.items.isEmpty) {
      return _whiteCard(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'محصولی برای این سفارش ثبت نشده است.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return _whiteCard(
      Padding(
        padding: EdgeInsets.all(isDesktop ? 18 : 12),
        child: Column(
          children: order.items.map((item) {
            return _OrderItemRow(
              item: item,
              isDesktop: isDesktop,
            );
          }).toList(),
        ),
      ),
    );
  }
}

Widget _whiteCard(Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: child,
  );
}

// =============================================================
// ORDER ITEM ROW WITH IMAGE SHIMMER
// =============================================================

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.item,
    required this.isDesktop,
  });

  final dynamic item;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final String? thumbnail = item.productThumbnail;

    final String? imageUrl =
    thumbnail == null || thumbnail.trim().isEmpty
        ? null
        : Supabase.instance.client.storage
        .from('assets')
        .getPublicUrl(thumbnail);

    final imageSize = isDesktop ? 76.0 : 65.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: imageSize,
              height: imageSize,
              child: imageUrl == null
                  ? _buildImagePlaceholder(imageSize)
                  : Image.network(
                imageUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return ShimmerBox(
                    width: imageSize,
                    height: imageSize,
                    radius: 0,
                  );
                },
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _buildImagePlaceholder(imageSize);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.quantity} عدد',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  PriceFormatter.format(item.unitPrice),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 125,
            ),
            child: Text(
              PriceFormatter.format(item.totalPrice),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 13,
                fontWeight: FontWeight.bold,
                color: AppColors.price,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade100,
      child: const Icon(
        Iconsax.image_copy,
        color: Colors.grey,
        size: 24,
      ),
    );
  }
}

// =============================================================
// SHIPPING ADDRESS
// =============================================================

class _ShippingAddressCard extends StatelessWidget {
  const _ShippingAddressCard({
    required this.address,
  });

  final String? address;

  @override
  Widget build(BuildContext context) {
    if (address == null || address!.trim().isEmpty) {
      return _buildCard(
        const Text(
          'آدرس ثبت نشده است',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      );
    }

    try {
      final decoded = jsonDecode(address!);

      if (decoded is Map<String, dynamic>) {
        final receiverName =
        decoded['receiver_name']?.toString().trim();
        final phone = decoded['phone']?.toString().trim();
        final province = decoded['province']?.toString().trim();
        final city = decoded['city']?.toString().trim();
        final actualAddress =
        decoded['address']?.toString().trim();
        final postalCode =
        decoded['postal_code']?.toString().trim();

        return _buildCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (receiverName != null && receiverName.isNotEmpty)
                _AddressInfoRow(
                  icon: Iconsax.user_copy,
                  title: 'تحویل گیرنده',
                  value: receiverName,
                ),
              if (phone != null && phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AddressInfoRow(
                  icon: Iconsax.call_copy,
                  title: 'شماره تماس',
                  value: phone,
                ),
              ],
              if ((province != null && province.isNotEmpty) ||
                  (city != null && city.isNotEmpty)) ...[
                const SizedBox(height: 12),
                _AddressInfoRow(
                  icon: Iconsax.house_copy,
                  title: 'استان / شهر',
                  value: [
                    if (province != null && province.isNotEmpty)
                      province,
                    if (city != null && city.isNotEmpty) city,
                  ].join(' - '),
                ),
              ],
              if (actualAddress != null &&
                  actualAddress.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AddressInfoRow(
                  icon: Iconsax.house_2_copy,
                  title: 'آدرس',
                  value: actualAddress,
                ),
              ],
              if (postalCode != null && postalCode.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AddressInfoRow(
                  icon: Iconsax.code_copy,
                  title: 'کد پستی',
                  value: postalCode,
                ),
              ],
            ],
          ),
        );
      }

      return _buildInvalidAddressCard();
    } catch (_) {
      return _buildInvalidAddressCard();
    }
  }

  Widget _buildInvalidAddressCard() {
    return _buildCard(
      const Text(
        'اطلاعات آدرس نامعتبر است',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.location_copy,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// =============================================================
// ADDRESS INFO ROW
// =============================================================

class _AddressInfoRow extends StatelessWidget {
  const _AddressInfoRow({
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
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// SHIPPING AND PAYMENT
// =============================================================

class _ShippingPaymentCard extends StatelessWidget {
  const _ShippingPaymentCard({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final trackingCode = order.trackingCode?.trim() ?? '';
    final hasTrackingCode = trackingCode.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Iconsax.truck_fast_copy,
            title: 'روش ارسال',
            value: 'ارسال معمولی',
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Iconsax.receipt_copy,
                size: 21,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'کد رهگیری',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasTrackingCode
                    ? Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    SelectableText(
                      trackingCode,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: trackingCode,
                          ),
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'کد رهگیری کپی شد.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                      },
                      icon: const Icon(
                        Iconsax.copy_copy,
                        size: 16,
                      ),
                      label: const Text('کپی کد'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        visualDensity:
                        VisualDensity.compact,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'هنوز ثبت نشده است',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.card_copy,
            title: 'روش پرداخت',
            value: _paymentText(order.paymentMethod ?? ''),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Iconsax.wallet_3_copy,
            title: 'وضعیت پرداخت',
            value: _paymentStatusText(order.paymentStatus),
          ),
        ],
      ),
    );
  }

  String _paymentText(String method) {
    switch (method) {
      case 'online':
        return 'پرداخت آنلاین';
      case 'cash':
        return 'پرداخت در محل';
      default:
        return method;
    }
  }

  String _paymentStatusText(String status) {
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

// =============================================================
// ORDER SUMMARY
// =============================================================

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 10),
          _SummaryRow(
            title: 'تخفیف',
            value: order.discount,
            isDiscount: true,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            title: 'هزینه ارسال',
            value: order.shippingCost,
          ),
          const Divider(height: 24),
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

// =============================================================
// SUMMARY ROW
// =============================================================

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
            fontSize: isTotal ? 15 : 13,
            fontWeight:
            isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            PriceFormatter.format(value),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.bold,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? AppColors.price
                  : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// INFO ROW
// =============================================================

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
          size: 21,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// ORDER STATUS BADGE
// =============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: 11,
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

// =============================================================
// REUSABLE SHIMMER BOX
// =============================================================

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    -1.5 + 3 * _controller.value,
                    0,
                  ),
                  end: Alignment(
                    -0.5 + 3 * _controller.value,
                    0,
                  ),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                  stops: const [
                    0.25,
                    0.5,
                    0.75,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
