import '../../domain/entities/flash_sale_entity.dart';

class FlashSaleModel {
  final String id;
  final String productId;
  final int discountPrice;
  final DateTime startAt;
  final DateTime endAt;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  const FlashSaleModel({
    required this.id,
    required this.productId,
    required this.discountPrice,
    required this.startAt,
    required this.endAt,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });

  factory FlashSaleModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return FlashSaleModel(
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'discount_price': discountPrice,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FlashSaleEntity toEntity() {
    return FlashSaleEntity(
      id: id,
      productId: productId,
      discountPrice: discountPrice,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  factory FlashSaleModel.fromEntity(
      FlashSaleEntity entity,
      ) {
    return FlashSaleModel(
      id: entity.id,
      productId: entity.productId,
      discountPrice: entity.discountPrice,
      startAt: entity.startAt,
      endAt: entity.endAt,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }
}