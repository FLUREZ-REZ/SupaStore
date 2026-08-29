import 'package:flutter/foundation.dart';
import 'package:supastore/features/review_feature/domain/entities/product_review_entity.dart';
import 'package:supastore/features/review_feature/domain/repositories/blocked_word_repository.dart';
import 'package:supastore/features/review_feature/domain/repositories/review_repository.dart';


class ReviewProvider extends ChangeNotifier {
  ReviewProvider({
    required ReviewRepository repository,
    required BlockedWordRepository blockedWordRepository,
  })  : _repository = repository,
        _blockedWordRepository = blockedWordRepository;

  final ReviewRepository _repository;

  final BlockedWordRepository _blockedWordRepository;

  // ==========================================================
  // STATE
  // ==========================================================

  List<ProductReviewEntity> _reviews = [];

  List<ProductReviewEntity> get reviews => _reviews;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  String? _error;

  String? get error => _error;

  // ==========================================================
  // LOAD REVIEWS
  // ==========================================================

  Future<void> loadReviews(
      String productId,
      ) async {
    try {
      _isLoading = true;
      _error = null;

      notifyListeners();

      _reviews = await _repository.getProductReviews(
        productId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // NORMALIZE TEXT
  // ==========================================================

  String _normalizeText(String text) {
    var result = text.toLowerCase();

    // Arabic Yeh → Persian Yeh
    result = result.replaceAll('ي', 'ی');

    // Arabic Kaf → Persian Kaf
    result = result.replaceAll('ك', 'ک');

    // Remove Tatweel
    result = result.replaceAll('ـ', '');

    // Remove Arabic diacritics
    result = result.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    );

    // Remove zero-width characters
    result = result.replaceAll(
      RegExp(r'[\u200B\u200C\u200D]'),
      '',
    );

    // Normalize multiple spaces
    result = result.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return result.trim();
  }

  // ==========================================================
  // COMPACT TEXT
  //
  // این قسمت باعث می‌شود:
  //
  // احمق
  // ا ح م ق
  // ا‌ح‌م‌ق
  //
  // همگی قابل تشخیص باشند.
  // ==========================================================

  String _compactText(String text) {
    return text.replaceAll(
      RegExp(r'[^a-zA-Z0-9آ-ی]'),
      '',
    );
  }

  // ==========================================================
  // CHECK BLOCKED WORD
  // ==========================================================

  Future<String?> _findBlockedWord({
    String? title,
    required String comment,
  }) async {
    try {
      final blockedWords =
      await _blockedWordRepository.getBlockedWords();

      if (blockedWords.isEmpty) {
        return null;
      }

      final normalizedTitle =
      _normalizeText(title ?? '');

      final normalizedComment =
      _normalizeText(comment);

      final compactTitle =
      _compactText(normalizedTitle);

      final compactComment =
      _compactText(normalizedComment);

      for (final blockedWord in blockedWords) {
        final normalizedWord =
        _normalizeText(blockedWord);

        if (normalizedWord.isEmpty) {
          continue;
        }

        final compactWord =
        _compactText(normalizedWord);

        if (compactWord.isEmpty) {
          continue;
        }

        // ====================================================
        // SHORT WORDS
        //
        // برای کلمات خیلی کوتاه substring خطرناک است.
        // ====================================================

        if (compactWord.length <= 2) {
          final escapedWord =
          RegExp.escape(normalizedWord);

          final pattern = RegExp(
            r'(^|[^a-zA-Z0-9آ-ی])'
            '$escapedWord'
            r'([^a-zA-Z0-9آ-ی]|$)',
            caseSensitive: false,
          );

          if (pattern.hasMatch(normalizedTitle) ||
              pattern.hasMatch(normalizedComment)) {
            return blockedWord;
          }

          continue;
        }

        // ====================================================
        // LONG WORDS
        //
        // Substring check
        //
        // مثال:
        //
        // احمق
        // احمقی
        // xاحمق
        // احمقx
        // ا ح م ق
        //
        // همگی تشخیص داده می‌شوند.
        // ====================================================

        if (compactTitle.contains(compactWord)) {
          return blockedWord;
        }

        if (compactComment.contains(compactWord)) {
          return blockedWord;
        }
      }

      return null;
    } catch (e) {
      debugPrint(
        '❌ Blocked word check error: $e',
      );

      // اگر سرویس فیلتر کلمات موقتاً مشکل داشت،
      // ثبت نظر را متوقف نمی‌کنیم.
      //
      // امنیت نهایی همچنان با Trigger دیتابیس است.

      return null;
    }
  }

  // ==========================================================
  // CREATE REVIEW
  // ==========================================================

  Future<bool> createReview({
    required String productId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    // ========================================================
    // VALIDATION
    // ========================================================

    final cleanComment = comment.trim();

    final cleanTitle =
    title?.trim();

    if (cleanComment.isEmpty) {
      _error = 'متن نظر نمی‌تواند خالی باشد.';

      notifyListeners();

      return false;
    }

    // ========================================================
    // CHECK BLOCKED WORDS
    // ========================================================

    final blockedWord =
    await _findBlockedWord(
      title: cleanTitle,
      comment: cleanComment,
    );

    if (blockedWord != null) {
      _error =
      'متن نظر شامل کلمه غیرمجاز است.';

      notifyListeners();

      debugPrint(
        '🚫 Blocked word detected: $blockedWord',
      );

      return false;
    }

    // ========================================================
    // SUBMIT
    // ========================================================

    try {
      _isSubmitting = true;
      _error = null;

      notifyListeners();

      final review =
      await _repository.createReview(
        productId: productId,
        rating: rating,
        title: cleanTitle,
        comment: cleanComment,
      );

      _reviews = [
        review,
        ..._reviews,
      ];

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // UPDATE REVIEW
  // ==========================================================

  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String comment,
  }) async {
    final cleanComment = comment.trim();

    final cleanTitle =
    title?.trim();

    if (cleanComment.isEmpty) {
      _error =
      'متن نظر نمی‌تواند خالی باشد.';

      notifyListeners();

      return false;
    }

    // ========================================================
    // CHECK BLOCKED WORDS
    // ========================================================

    final blockedWord =
    await _findBlockedWord(
      title: cleanTitle,
      comment: cleanComment,
    );

    if (blockedWord != null) {
      _error =
      'متن نظر شامل کلمه غیرمجاز است.';

      notifyListeners();

      debugPrint(
        '🚫 Blocked word detected: $blockedWord',
      );

      return false;
    }

    // ========================================================
    // UPDATE
    // ========================================================

    try {
      _isSubmitting = true;
      _error = null;

      notifyListeners();

      await _repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        title: cleanTitle,
        comment: cleanComment,
      );

      final index =
      _reviews.indexWhere(
            (review) =>
        review.id == reviewId,
      );

      if (index != -1) {
        final oldReview =
        _reviews[index];

        _reviews[index] =
            ProductReviewEntity(
              id: oldReview.id,
              productId: oldReview.productId,
              userId: oldReview.userId,
              rating: rating,
              title: cleanTitle,
              comment: cleanComment,
              isApproved: oldReview.isApproved,
              isVerifiedPurchase:
              oldReview.isVerifiedPurchase,
              createdAt: oldReview.createdAt,
              updatedAt: DateTime.now(),
            );
      }

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _isSubmitting = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // DELETE REVIEW
  // ==========================================================

  Future<bool> deleteReview(
      String reviewId,
      ) async {
    try {
      _error = null;

      notifyListeners();

      await _repository.deleteReview(
        reviewId,
      );

      _reviews.removeWhere(
            (review) =>
        review.id == reviewId,
      );

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      notifyListeners();
    }
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  void clear() {
    _reviews = [];

    _error = null;

    _isLoading = false;

    _isSubmitting = false;

    notifyListeners();
  }
}