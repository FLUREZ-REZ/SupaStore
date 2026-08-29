class ProductReviewEntity {
  const ProductReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    required this.comment,
    required this.isApproved,
    required this.isVerifiedPurchase,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String productId;

  final String userId;

  final int rating;

  final String? title;

  final String comment;

  final bool isApproved;

  final bool isVerifiedPurchase;

  final DateTime createdAt;

  final DateTime updatedAt;
}