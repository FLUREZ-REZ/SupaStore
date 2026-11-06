
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/admin_flash_sale_entity.dart';
import 'flash_sale_countdown.dart';

class AdminFlashSaleCard extends StatelessWidget {
  const AdminFlashSaleCard({
    super.key,
    required this.flashSale,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final AdminFlashSaleEntity flashSale;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onStatusChanged;

  static const Color primaryColor = Color(0xFF03045E);
  static const Color secondaryColor = Color(0xFF023E8A);
  static const Color dangerColor = Color(0xFFE21B23);
  static const Color textColor = Color(0xFF222222);

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool compact = width < 340;
        final bool desktop = width >= 480;

        final double padding = desktop ? 18 : 12;
        final double imageSize = desktop ? 105 : 82;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // PRODUCT INFORMATION
                // ==========================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(imageSize),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildProductInfo(
                        desktop: desktop,
                        compact: compact,
                      ),
                    ),

                    if (!compact) ...[
                      const SizedBox(width: 6),
                      _buildStatusControl(
                        compact: false,
                      ),
                    ],
                  ],
                ),

                if (compact) ...[
                  const SizedBox(height: 10),
                  _buildStatusControl(
                    compact: true,
                  ),
                ],

                const SizedBox(height: 14),

                // ==========================================
                // DISCOUNT & PRIORITY
                // ==========================================

                _buildDiscountAndPriority(
                  compact: compact,
                ),

                const SizedBox(height: 12),

                // ==========================================
                // COUNTDOWN
                // ==========================================

                FlashSaleCountdown(
                  startAt: flashSale.startAt,
                  endAt: flashSale.endAt,
                  isActive: flashSale.isActive,
                ),

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                ),

                const SizedBox(height: 6),

                // ==========================================
                // ACTIONS
                // ==========================================

                _buildActions(
                  compact: compact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========================================================
  // PRODUCT IMAGE
  // ========================================================

  Widget _buildProductImage(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: flashSale.product.thumbnail,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey.shade100,
              child: Icon(
                Iconsax.image_copy,
                size: 30,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      ),
    );
  }

  // ========================================================
  // PRODUCT INFO
  // ========================================================

  Widget _buildProductInfo({
    required bool desktop,
    required bool compact,
  }) {
    final product = flashSale.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: desktop ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: desktop ? 14 : 12,
            height: 1.7,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'قیمت اصلی: ${_formatPrice(product.price)} تومان',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: desktop ? 11 : 10,
            height: 1.6,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'قیمت فروش ویژه:',
          style: TextStyle(
            fontSize: desktop ? 11 : 10,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '${_formatPrice(flashSale.discountPrice)} تومان',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: desktop ? 14 : 12,
            height: 1.6,
            fontWeight: FontWeight.w800,
            color: dangerColor,
          ),
        ),
      ],
    );
  }

  // ========================================================
  // STATUS CONTROL
  // ========================================================

  Widget _buildStatusControl({
    required bool compact,
  }) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              flashSale.isActive
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              size: 17,
              color: flashSale.isActive
                  ? Colors.green.shade700
                  : Colors.grey,
            ),

            const SizedBox(width: 7),

            Text(
              flashSale.isActive ? 'فروش ویژه فعال' : 'فروش ویژه غیرفعال',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: flashSale.isActive
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
              ),
            ),

            const Spacer(),

            Switch.adaptive(
              value: flashSale.isActive,
              activeTrackColor: primaryColor,
              onChanged: onStatusChanged,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch.adaptive(
          value: flashSale.isActive,
          activeTrackColor: primaryColor,
          onChanged: onStatusChanged,
        ),

        const SizedBox(height: 3),

        Text(
          flashSale.isActive ? 'فعال' : 'غیرفعال',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: flashSale.isActive
                ? Colors.green.shade700
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ========================================================
  // DISCOUNT & PRIORITY
  // ========================================================

  Widget _buildDiscountAndPriority({
    required bool compact,
  }) {
    return Row(
      children: [
        if (flashSale.hasValidDiscount)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: dangerColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '${flashSale.discountPercent}٪ تخفیف',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        const Spacer(),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            'اولویت: ${flashSale.sortOrder}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // ACTION BUTTONS
  // ========================================================

  Widget _buildActions({
    required bool compact,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 17,
            ),
            label: const Text(
              'ویرایش',
              maxLines: 1,
            ),
            style: TextButton.styleFrom(
              foregroundColor: secondaryColor,
              padding: EdgeInsets.symmetric(
                vertical: compact ? 8 : 10,
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        Container(
          width: 1,
          height: 24,
          color: Colors.grey.shade200,
        ),

        Expanded(
          child: TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(
              Iconsax.trash_copy,
              size: 17,
            ),
            label: const Text(
              'حذف',
              maxLines: 1,
            ),
            style: TextButton.styleFrom(
              foregroundColor: dangerColor,
              padding: EdgeInsets.symmetric(
                vertical: compact ? 8 : 10,
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
