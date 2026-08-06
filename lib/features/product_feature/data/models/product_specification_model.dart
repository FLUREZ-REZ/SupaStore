import '../../domain/entities/product_specification_entity.dart';

class ProductSpecificationModel extends ProductSpecificationEntity {
  const ProductSpecificationModel({
    required super.id,
    required super.productId,
    required super.title,
    required super.value,
    required super.sortOrder,
    required super.createdAt,
  });

  factory ProductSpecificationModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ProductSpecificationModel(
      id: map['id'] as String,

      productId: map['product_id'] as String,

      title: map['title'] as String,

      value: map['value'] as String,

      sortOrder: map['sort_order'] as int,

      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'product_id': productId,

      'title': title,

      'value': value,

      'sort_order': sortOrder,

      'created_at': createdAt.toIso8601String(),
    };
  }
}