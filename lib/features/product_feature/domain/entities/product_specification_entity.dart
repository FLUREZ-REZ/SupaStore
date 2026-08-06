class ProductSpecificationEntity {
  final String id;

  final String productId;

  final String title;

  final String value;

  final int sortOrder;

  final DateTime createdAt;

  const ProductSpecificationEntity({
    required this.id,
    required this.productId,
    required this.title,
    required this.value,
    required this.sortOrder,
    required this.createdAt,
  });
}