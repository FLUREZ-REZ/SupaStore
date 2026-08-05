class ProductImageEntity {
  const ProductImageEntity({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.sortOrder,
    required this.isPrimary,
    required this.createdAt,
  });

  final String id;

  final String productId;

  final String imageUrl;

  final int sortOrder;

  final bool isPrimary;

  final DateTime createdAt;
}