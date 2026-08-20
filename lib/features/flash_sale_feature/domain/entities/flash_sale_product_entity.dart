import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_entity.dart';
import 'package:supastore/features/product_feature/domain/entities/product_entity.dart';

class FlashSaleProductEntity {
  final ProductEntity product;
  final FlashSaleEntity flashSale;

  const FlashSaleProductEntity({
    required this.product,
    required this.flashSale,
  });

  int get originalPrice {
    return product.price;
  }

  int get discountPrice {
    return flashSale.discountPrice;
  }

  int get discountPercent {
    if (originalPrice <= 0) {
      return 0;
    }

    final percent =
        ((originalPrice - discountPrice) /
            originalPrice) *
            100;

    return percent.round().clamp(0, 100);
  }

  DateTime get startAt {
    return flashSale.startAt;
  }

  DateTime get endAt {
    return flashSale.endAt;
  }

  bool get isRunning {
    return flashSale.isRunning;
  }
}