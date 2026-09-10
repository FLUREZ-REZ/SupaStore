class AdminReviewEntity {
  const AdminReviewEntity({
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
    this.productTitle,
    this.productThumbnail,
    this.userFullName,
    this.userPhone,
    this.userAvatarUrl,
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

  final String? productTitle;

  final String? productThumbnail;

  final String? userFullName;

  final String? userPhone;

  final String? userAvatarUrl;
}