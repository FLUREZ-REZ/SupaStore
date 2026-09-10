import '../../domain/entities/admin_review_entity.dart';
import '../../domain/repositories/admin_review_repository.dart';
import '../datasources/admin_review_remote_data_source.dart';



class AdminReviewRepositoryImpl
    implements AdminReviewRepository {

  AdminReviewRepositoryImpl({
    required AdminReviewRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AdminReviewRemoteDataSource _remoteDataSource;

  // ==========================================================
  // GET REVIEWS
  // ==========================================================

  @override
  Future<List<AdminReviewEntity>> getReviews({
    String status = 'all',
    int? rating,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    return _remoteDataSource.getReviews(
      status: status,
      rating: rating,
      search: search,
      limit: limit,
      offset: offset,
    );
  }

  // ==========================================================
  // GET COUNTS
  // ==========================================================

  @override
  Future<Map<String, int>> getReviewCounts() async {
    return _remoteDataSource.getReviewCounts();
  }

  // ==========================================================
  // APPROVE
  // ==========================================================

  @override
  Future<void> approveReview(

      String reviewId,
      ) async {
    print('REPOSITORY: approveReview CALLED');
    await _remoteDataSource.approveReview(
      reviewId,
    );
  }

  // ==========================================================
  // REJECT
  // ==========================================================

  @override
  Future<void> rejectReview(
      String reviewId,
      ) async {
    await _remoteDataSource.rejectReview(
      reviewId,
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