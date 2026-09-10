import '../../domain/entities/admin_review_entity.dart';

class AdminReviewModel extends AdminReviewEntity {
  const AdminReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.rating,
    super.title,
    required super.comment,
    required super.isApproved,
    required super.isVerifiedPurchase,
    required super.createdAt,
    required super.updatedAt,
    super.productTitle,
    super.productThumbnail,
    super.userFullName,
    super.userPhone,
    super.userAvatarUrl,
  });

  factory AdminReviewModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminReviewModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      userId: map['user_id'] as String,
      rating: (map['rating'] as num).toInt(),
      title: map['title'] as String?,
      comment: map['comment'] as String? ?? '',
      isApproved: map['is_approved'] as bool? ?? false,
      isVerifiedPurchase:
      map['is_verified_purchase'] as bool? ?? false,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      productTitle: map['product_title'] as String?,
      productThumbnail: map['product_thumbnail'] as String?,
      userFullName: map['user_full_name'] as String?,
      userPhone: map['user_phone'] as String?,
      userAvatarUrl: map['user_avatar_url'] as String?,
    );
  }
}