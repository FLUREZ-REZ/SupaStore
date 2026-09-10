import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_review_entity.dart';
import '../../domain/repositories/admin_review_repository.dart';

class AdminReviewProvider extends ChangeNotifier {
  AdminReviewProvider({
    required AdminReviewRepository repository,
  }) : _repository = repository;

  final AdminReviewRepository _repository;

  // ==========================================================
  // CONSTANTS
  // ==========================================================

  static const int _pageSize = 20;

  // ==========================================================
  // REVIEWS
  // ==========================================================

  List<AdminReviewEntity> _reviews = [];

  List<AdminReviewEntity> get reviews => _reviews;

  // ==========================================================
  // COUNTS
  // ==========================================================

  int _allCount = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;

  int get allCount => _allCount;

  int get pendingCount => _pendingCount;

  int get approvedCount => _approvedCount;

  // ==========================================================
  // FILTERS
  // ==========================================================

  String _status = 'all';

  String get status => _status;

  int? _rating;

  int? get rating => _rating;

  String _search = '';

  String get search => _search;

  // ==========================================================
  // PAGINATION
  // ==========================================================

  int _offset = 0;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  // ==========================================================
  // STATE
  // ==========================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  bool _isActionLoading = false;

  bool get isActionLoading => _isActionLoading;

  String? _error;

  String? get error => _error;

  // ==========================================================
  // LOAD REVIEWS
  // ==========================================================

  Future<void> loadReviews() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    _offset = 0;
    _hasMore = true;

    notifyListeners();

    try {
      final results = await _repository.getReviews(
        status: _status,
        rating: _rating,
        search: _search.isEmpty ? null : _search,
        limit: _pageSize,
        offset: 0,
      );

      _reviews = List<AdminReviewEntity>.from(results);

      _offset = results.length;

      _hasMore = results.length >= _pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // LOAD MORE
  // ==========================================================

  Future<void> loadMore() async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    _isLoadingMore = true;

    notifyListeners();

    try {
      final results = await _repository.getReviews(
        status: _status,
        rating: _rating,
        search: _search.isEmpty ? null : _search,
        limit: _pageSize,
        offset: _offset,
      );

      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _reviews = [
          ..._reviews,
          ...results,
        ];

        _offset += results.length;

        if (results.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _error = null;

    notifyListeners();

    try {
      final results = await _repository.getReviews(
        status: _status,
        rating: _rating,
        search: _search.isEmpty ? null : _search,
        limit: _pageSize,
        offset: 0,
      );

      _reviews = List<AdminReviewEntity>.from(results);

      _offset = results.length;

      _hasMore = results.length >= _pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // LOAD COUNTS
  // ==========================================================

  Future<void> loadCounts() async {
    try {
      final counts = await _repository.getReviewCounts();

      _allCount = counts['all'] ?? 0;
      _pendingCount = counts['pending'] ?? 0;
      _approvedCount = counts['approved'] ?? 0;

      notifyListeners();
    } catch (e) {
      _error = e.toString();

      notifyListeners();
    }
  }

  // ==========================================================
  // LOAD PAGE
  // ==========================================================

  Future<void> loadPage() async {
    await Future.wait([
      loadReviews(),
      loadCounts(),
    ]);
  }

  // ==========================================================
  // CHANGE STATUS FILTER
  // ==========================================================

  Future<void> setStatus(
      String status,
      ) async {
    if (_status == status) {
      return;
    }

    _status = status;

    await loadReviews();
  }

  // ==========================================================
  // CHANGE RATING FILTER
  // ==========================================================

  Future<void> setRating(
      int? rating,
      ) async {
    if (_rating == rating) {
      return;
    }

    _rating = rating;

    await loadReviews();
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Future<void> searchReviews(
      String value,
      ) async {
    final searchValue = value.trim();

    if (_search == searchValue) {
      return;
    }

    _search = searchValue;

    await loadReviews();
  }

  // ==========================================================
  // APPROVE
  // ==========================================================

  // ==========================================================
// APPROVE
// ==========================================================

  Future<bool> approveReview(
      String reviewId,
      ) async {
    if (_isActionLoading) {
      return false;
    }

    _isActionLoading = true;
    _error = null;

    notifyListeners();

    try {
      await _repository.approveReview(
        reviewId,
      );

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    } finally {
      _isActionLoading = false;

      notifyListeners();
    }
  }

// ==========================================================
// REJECT / HIDE
// ==========================================================

  Future<bool> rejectReview(
      String reviewId,
      ) async {
    if (_isActionLoading) {
      return false;
    }

    _isActionLoading = true;
    _error = null;

    notifyListeners();

    try {
      await _repository.rejectReview(
        reviewId,
      );

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    } finally {
      _isActionLoading = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<bool> deleteReview(
      String reviewId,
      ) async {
    if (_isActionLoading) {
      return false;
    }

    _isActionLoading = true;
    _error = null;

    notifyListeners();

    try {
      final reviewIndex = _reviews.indexWhere(
            (review) => review.id == reviewId,
      );

      AdminReviewEntity? deletedReview;

      if (reviewIndex != -1) {
        deletedReview = _reviews[reviewIndex];
      }

      await _repository.deleteReview(
        reviewId,
      );

      // --------------------------------------------------------
      // Remove from current list.
      // --------------------------------------------------------

      _reviews.removeWhere(
            (review) => review.id == reviewId,
      );

      // --------------------------------------------------------
      // Update counts.
      // --------------------------------------------------------

      if (_allCount > 0) {
        _allCount--;
      }

      if (deletedReview != null) {
        if (deletedReview.isApproved) {
          if (_approvedCount > 0) {
            _approvedCount--;
          }
        } else {
          if (_pendingCount > 0) {
            _pendingCount--;
          }
        }
      }

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    } finally {
      _isActionLoading = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // CLEAR ERROR
  // ==========================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }

  // ==========================================================
  // RESET FILTERS
  // ==========================================================

  Future<void> resetFilters() async {
    _status = 'all';
    _rating = null;
    _search = '';

    await loadReviews();
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  void clear() {
    _reviews = [];

    _allCount = 0;
    _pendingCount = 0;
    _approvedCount = 0;

    _status = 'all';
    _rating = null;
    _search = '';

    _offset = 0;
    _hasMore = true;

    _isLoading = false;
    _isRefreshing = false;
    _isLoadingMore = false;
    _isActionLoading = false;

    _error = null;

    notifyListeners();
  }
}