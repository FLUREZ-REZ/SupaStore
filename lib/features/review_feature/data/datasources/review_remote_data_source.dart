import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_review_model.dart';

class ReviewRemoteDataSource {
  ReviewRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ==========================================================
  // GET PRODUCT REVIEWS
  // ==========================================================

  Future<List<ProductReviewModel>> getProductReviews(
      String productId,
      ) async {
    final response = await _client
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<ProductReviewModel>(
          (json) => ProductReviewModel.fromMap(json),
    )
        .toList();
  }

  // ==========================================================
  // CREATE REVIEW
  // ==========================================================

  Future<ProductReviewModel> createReview({
    required String productId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(
        'برای ثبت نظر ابتدا وارد حساب کاربری شوید.',
      );
    }

    final response = await _client
        .from('product_reviews')
        .insert({
      'product_id': productId,
      'user_id': user.id,
      'rating': rating,
      'title': title,
      'comment': comment,
    })
        .select()
        .single();

    return ProductReviewModel.fromMap(response);
  }

  // ==========================================================
  // UPDATE REVIEW
  // ==========================================================

  Future<ProductReviewModel> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    final response = await _client
        .from('product_reviews')
        .update({
      'rating': rating,
      'title': title,
      'comment': comment,
    })
        .eq('id', reviewId)
        .select()
        .single();

    return ProductReviewModel.fromMap(response);
  }

  // ==========================================================
  // DELETE REVIEW
  // ==========================================================

  Future<void> deleteReview(
      String reviewId,
      ) async {
    await _client
        .from('product_reviews')
        .delete()
        .eq('id', reviewId);
  }
}