import '../entities/admin_review_entity.dart';

abstract class AdminReviewRepository {
  Future<List<AdminReviewEntity>> getReviews({
    String status = 'all',
    int? rating,
    String? search,
    int limit = 20,
    int offset = 0,
  });

  Future<Map<String, int>> getReviewCounts();

  Future<void> approveReview(
      String reviewId,
      );

  Future<void> rejectReview(
      String reviewId,
      );

  Future<void> deleteReview(
      String reviewId,
      );
}