class ProductEntity {
  final String id;


  final String categoryId;

  final String? brandId;

  final String title;

  final String slug;

  final String description;

  final String thumbnail;

  final int price;

  final int? discountPrice;

  final int discountPercent;

  final double rating;

  final int reviewCount;

  final bool isAvailable;

  final bool isFeatured;

  final DateTime createdAt;

  final int soldCount;

  final bool isNew;

  const ProductEntity({
    required this.id,
    required this.categoryId,
    this.brandId,
    required this.title,
    required this.slug,
    required this.description,
    required this.thumbnail,
    required this.price,
    this.discountPrice,
    required this.discountPercent,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.isFeatured,
    required this.createdAt,
    required this.soldCount,
    required this.isNew
  });

  bool get hasDiscount =>
      discountPrice != null &&
          discountPercent > 0;

  int get finalPrice =>
      discountPrice ?? price;
}