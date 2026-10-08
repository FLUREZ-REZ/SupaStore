import 'package:supastore/features/product_feature/data/models/product_model.dart';

import '../../domain/entities/admin_flash_sale_entity.dart';

class AdminFlashSaleModel {
  const AdminFlashSaleModel({
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
  final ProductModel product;

  factory AdminFlashSaleModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final productData = map['products'];

    if (productData == null) {
      throw Exception(
        'Product data is missing for flash sale.',
      );
    }

    final productMap =
    Map<String, dynamic>.from(productData as Map);

    return AdminFlashSaleModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      discountPrice:
      (map['discount_price'] as num).toInt(),
      startAt: DateTime.parse(
        map['start_at'] as String,
      ).toLocal(),
      endAt: DateTime.parse(
        map['end_at'] as String,
      ).toLocal(),
      isActive:
      map['is_active'] as bool? ?? false,
      sortOrder:
      (map['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ).toLocal(),
      product: ProductModel.fromMap(
        productMap,
      ),
    );
  }

  AdminFlashSaleEntity toEntity() {
    return AdminFlashSaleEntity(
      id: id,
      productId: productId,
      discountPrice: discountPrice,
      startAt: startAt,
      endAt: endAt,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      product: product,
    );
  }
}