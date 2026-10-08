import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class AdminFlashSaleEntity {
  const AdminFlashSaleEntity({
    required this.id,
    required this.productId,
    required this.discountPrice,
    required this.startAt,
    required this.endAt,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.product,
  });

  final String id;
  final String productId;
  final int discountPrice;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final ProductEntity product;

  bool get isStarted {
    return !DateTime.now().isBefore(startAt);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endAt);
  }

  bool get isRunning {
    final now = DateTime.now();

    return isActive &&
        !now.isBefore(startAt) &&
        !now.isAfter(endAt);
  }

  bool get isScheduled {
    return isActive && DateTime.now().isBefore(startAt);
  }

  bool get hasValidDiscount {
    return discountPrice > 0 &&
        discountPrice < product.price;
  }

  int get discountPercent {
    if (!hasValidDiscount || product.price <= 0) {
      return 0;
    }

    final percent =
        ((product.price - discountPrice) /
            product.price) *
            100;

    return percent.round().clamp(0, 100);
  }

  Duration get remainingTime {
    final now = DateTime.now();

    if (now.isBefore(startAt)) {
      return startAt.difference(now);
    }

    if (now.isBefore(endAt)) {
      return endAt.difference(now);
    }

    return Duration.zero;
  }
}