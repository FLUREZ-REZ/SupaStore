import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_entity.dart';
import 'package:supastore/features/flash_sale_feature/domain/entities/flash_sale_product_entity.dart';
import 'package:supastore/features/product_feature/data/models/product_model.dart';

class FlashSaleProductModel {
  final FlashSaleEntity flashSale;
  final ProductModel product;

  const FlashSaleProductModel({
    required this.flashSale,
    required this.product,
  });

  factory FlashSaleProductModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final productMap = Map<String, dynamic>.from(
      map['products'] as Map,
    );

    return FlashSaleProductModel(
      flashSale: FlashSaleEntity(
        id: map['id'] as String,
        productId: map['product_id'] as String,
        discountPrice: (map['discount_price'] as num).toInt(),
        startAt: DateTime.parse(
          map['start_at'] as String,
        ),
        endAt: DateTime.parse(
          map['end_at'] as String,
        ),
        isActive: map['is_active'] as bool? ?? false,
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(
          map['created_at'] as String,
        ),
      ),
      product: ProductModel.fromMap(productMap),
    );
  }

  FlashSaleProductEntity toEntity() {
    return FlashSaleProductEntity(
      product: product,
      flashSale: flashSale,
    );
  }
}