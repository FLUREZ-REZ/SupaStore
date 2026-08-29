import '../../domain/entities/product_review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({
    required ReviewRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ReviewRemoteDataSource _remoteDataSource;

  // ==========================================================
  // GET
  // ==========================================================

  @override
  Future<List<ProductReviewEntity>> getProductReviews(
      String productId,
      ) async {
    return _remoteDataSource.getProductReviews(
      productId,
    );
  }

  // ==========================================================
  // CREATE
  // ==========================================================

  @override
  Future<ProductReviewEntity> createReview({
    required String productId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    return _remoteDataSource.createReview(
      productId: productId,
      rating: rating,
      title: title,
      comment: comment,
    );
  }

  // ==========================================================
  // UPDATE
  // ==========================================================

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    await _remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      title: title,
      comment: comment,
    );
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  @override
  Future<void> deleteReview(
      String reviewId,
      ) async {
    await _remoteDataSource.deleteReview(
      reviewId,
    );
  }
}