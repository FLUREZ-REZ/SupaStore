import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_entity.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class FlashSaleProductEntity {
  final ProductEntity product;
  final FlashSaleEntity flashSale;

  const FlashSaleProductEntity({
    required this.product,
    required this.flashSale,
  });

  // ============================================================
  // ORIGINAL PRICE
  // ============================================================

  int get originalPrice {
    return product.price;
  }

  // ============================================================
  // FLASH SALE PRICE
  // ============================================================

  int get discountPrice {
    return flashSale.discountPrice;
  }

  // ============================================================
  // VALID DISCOUNT
  // ============================================================

  bool get hasValidDiscount {
    return discountPrice > 0 &&
        discountPrice < originalPrice;
  }

  // ============================================================
  // DISCOUNT PERCENT
  // ============================================================

  int get discountPercent {
    if (!hasValidDiscount) {
      return 0;
    }

    final percent =
        ((originalPrice - discountPrice) /
            originalPrice) *
            100;

    return percent.round().clamp(0, 100);
  }

  // ============================================================
  // START
  // ============================================================

  DateTime get startAt {
    return flashSale.startAt;
  }

  // ============================================================
  // END
  // ============================================================

  DateTime get endAt {
    return flashSale.endAt;
  }

  // ============================================================
  // RUNNING
  // ============================================================

  bool get isRunning {
    return flashSale.isRunning;
  }
}