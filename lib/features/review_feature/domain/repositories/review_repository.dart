import '../entities/product_review_entity.dart';

abstract class ReviewRepository {

  Future<List<ProductReviewEntity>> getProductReviews(
      String productId,
      );

  Future<ProductReviewEntity> createReview({
    required String productId,
    required int rating,
    String? title,
    required String comment,
  });

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String comment,
  });

  Future<void> deleteReview(
      String reviewId,
      );

}