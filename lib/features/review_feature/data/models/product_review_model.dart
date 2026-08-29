import '../../domain/entities/product_review_entity.dart';

class ProductReviewModel extends ProductReviewEntity {
  const ProductReviewModel({
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
  });

  factory ProductReviewModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ProductReviewModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      userId: map['user_id'] as String,
      rating: map['rating'] as int,
      title: map['title'] as String?,
      comment: map['comment'] as String,
      isApproved: map['is_approved'] as bool? ?? false,
      isVerifiedPurchase:
      map['is_verified_purchase'] as bool? ?? false,
      createdAt:
      DateTime.parse(map['created_at'] as String),
      updatedAt:
      DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'is_approved': isApproved,
      'is_verified_purchase': isVerifiedPurchase,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}