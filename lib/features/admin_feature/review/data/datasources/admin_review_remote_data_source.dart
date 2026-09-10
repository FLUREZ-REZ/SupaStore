import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_review_model.dart';

class AdminReviewRemoteDataSource {
  AdminReviewRemoteDataSource({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ==========================================================
  // GET REVIEWS
  // ==========================================================

  Future<List<AdminReviewModel>> getReviews({
    String status = 'all',
    int? rating,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.rpc(
      'get_admin_reviews',
      params: {
        'p_status': status,
        'p_rating': rating,
        'p_search': search,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    if (response == null) {
      return [];
    }

    if (response is! List) {
      throw Exception(
        'فرمت پاسخ نظرات نامعتبر است.',
      );
    }

    return response
        .map(
          (json) => AdminReviewModel.fromMap(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  // ==========================================================
  // GET COUNTS
  // ==========================================================

  Future<Map<String, int>> getReviewCounts() async {
    final response = await _client.rpc(
      'get_admin_review_counts',
    );

    if (response == null) {
      throw Exception(
        'آمار نظرات دریافت نشد.',
      );
    }

    if (response is! Map) {
      throw Exception(
        'فرمت آمار نظرات نامعتبر است.',
      );
    }

    final data = Map<String, dynamic>.from(
      response,
    );

    return {
      'all': (data['all'] as num?)?.toInt() ?? 0,
      'pending': (data['pending'] as num?)?.toInt() ?? 0,
      'approved': (data['approved'] as num?)?.toInt() ?? 0,
    };
  }

  // ==========================================================
  // APPROVE
  // ==========================================================

  Future<void> approveReview(String reviewId) async {
    print('DATASOURCE: approveReview CALLED');
    print('DATASOURCE: REVIEW ID = $reviewId');

    try {
      print('DATASOURCE: BEFORE RPC');

      final response = await _client
          .rpc(
        'approve_admin_review',
        params: {
          'p_review_id': reviewId,
        },
      )
          .timeout(
        const Duration(seconds: 10),
      );

      print('DATASOURCE: AFTER RPC');
      print('APPROVE RPC RESPONSE: $response');

      final check = await _client
          .from('product_reviews')
          .select('id, is_approved, updated_at')
          .eq('id', reviewId)
          .maybeSingle();

      print('APPROVE DB CHECK: $check');
    } catch (e, st) {
      print('DATASOURCE ERROR: $e');
      print('DATASOURCE STACK: $st');
      rethrow;
    }
  }

  // ==========================================================
  // REJECT / HIDE
  // ==========================================================

  Future<void> rejectReview(
      String reviewId,
      ) async {
    await _client.rpc(
      'reject_admin_review',
      params: {
        'p_review_id': reviewId,
      },
    );
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> deleteReview(
      String reviewId,
      ) async {
    await _client.rpc(
      'delete_admin_review',
      params: {
        'p_review_id': reviewId,
      },
    );
  }
}