import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/review_feature/domain/entities/product_review_entity.dart';
import 'package:supastore/features/review_feature/presentation/providers/review_provider.dart';
import 'package:supastore/features/review_feature/presentation/widgets/review_form.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        if (provider.isLoading &&
            provider.reviews.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 35.h,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null &&
            provider.reviews.isEmpty) {
          return _ErrorView(
            error: provider.error!,
            onRetry: () {
              provider.loadReviews(productId);
            },
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16.w,
            20.h,
            16.w,
            20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              16.r,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 22.sp,
                    color: AppColors.primary,
                  ),

                  SizedBox(width: 8.w),

                  Text(
                    'نظرات کاربران',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  if (provider.reviews.isNotEmpty)
                    Text(
                      '${provider.reviews.length} نظر',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20.h),

              // ==================================================
              // RATING SUMMARY
              // ==================================================

              if (provider.reviews.isNotEmpty)
                _RatingSummary(
                  reviews: provider.reviews,
                ),

              // ==================================================
              // DIVIDER
              // ==================================================

              if (provider.reviews.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18.h,
                  ),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ),

              // ==================================================
              // EMPTY
              // ==================================================

              if (provider.reviews.isEmpty)
                const _EmptyReviews()
              else
              // ==================================================
              // REVIEWS LIST
              // ==================================================

                ListView.separated(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: provider.reviews.length,
                  separatorBuilder: (
                      context,
                      index,
                      ) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 14.h,
                      ),
                      child: Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                    );
                  },
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    return _ReviewItem(
                      review:
                      provider.reviews[index],
                    );
                  },
                ),

              SizedBox(height: 18.h),

              // ==================================================
              // WRITE REVIEW
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<ReviewProvider>(),
                          child: ReviewForm(
                            productId: productId,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 19.sp,
                  ),
                  label: Text(
                    'ثبت نظر',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12.r,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =================================================================
// RATING SUMMARY
// =================================================================

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.reviews,
  });

  final List<ProductReviewEntity> reviews;

  double get averageRating {
    if (reviews.isEmpty) {
      return 0;
    }

    final total = reviews.fold<int>(
      0,
          (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  int _countForRating(
      int rating,
      ) {
    return reviews
        .where(
          (review) => review.rating == rating,
    )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        // ======================================================
        // AVERAGE RATING
        // ======================================================

        SizedBox(
          width: 90.w,
          child: Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 3.h),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) {
                    final isActive =
                        index <
                            averageRating.round();

                    return Icon(
                      isActive
                          ? Icons.star
                          : Icons.star_border,
                      size: 15.sp,
                      color: Colors.amber,
                    );
                  },
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                '${reviews.length} امتیاز',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 18.w),

        // ======================================================
        // RATING BARS
        // ======================================================

        Expanded(
          child: Column(
            children: [
              for (int rating = 5;
              rating >= 1;
              rating--)
                _RatingBar(
                  rating: rating,
                  count:
                  _countForRating(rating),
                  total: reviews.length,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// RATING BAR
// =================================================================

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.rating,
    required this.count,
    required this.total,
  });

  final int rating;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage =
    total == 0 ? 0.0 : count / total;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 2.5.h,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 12.w,
            child: Text(
              '$rating',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          SizedBox(width: 4.w),

          Icon(
            Icons.star,
            size: 12.sp,
            color: Colors.amber,
          ),

          SizedBox(width: 7.w),

          Expanded(
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6.h,
                backgroundColor:
                Colors.grey.shade200,
                valueColor:
                const AlwaysStoppedAnimation<Color>(
                  Colors.amber,
                ),
              ),
            ),
          ),

          SizedBox(width: 7.w),

          SizedBox(
            width: 20.w,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// REVIEW ITEM
// =================================================================

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.review,
  });

  final ProductReviewEntity review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // ======================================================
        // USER
        // ======================================================

        Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 19.sp,
                color: AppColors.primary,
              ),
            ),

            SizedBox(width: 9.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'کاربر',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  if (review.isVerifiedPurchase)
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12.sp,
                          color: Colors.green,
                        ),

                        SizedBox(width: 3.w),

                        Text(
                          'خریدار تأیید شده',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ==================================================
            // RATING
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 15.sp,
                  color: Colors.amber,
                ),

                SizedBox(width: 3.w),

                Text(
                  '${review.rating}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // ======================================================
        // TITLE
        // ======================================================

        if (review.title != null &&
            review.title!.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              bottom: 5.h,
            ),
            child: Text(
              review.title!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // ======================================================
        // COMMENT
        // ======================================================

        Text(
          review.comment,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.7,
            color: Colors.grey.shade800,
          ),
        ),

        SizedBox(height: 8.h),

        // ======================================================
        // DATE
        // ======================================================

        Text(
          _formatDate(review.createdAt),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    final localDate = date.toLocal();

    return '${localDate.year}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.day.toString().padLeft(2, '0')}';
  }
}

// =================================================================
// EMPTY REVIEWS
// =================================================================

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15.h,
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 42.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 10.h),

          Text(
            'هنوز نظری برای این محصول ثبت نشده است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ERROR
// =================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 25.h,
        horizontal: 16.w,
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 42.sp,
            color: Colors.redAccent,
          ),

          SizedBox(height: 10.h),

          Text(
            'خطا در دریافت نظرات',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            error,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 12.h),

          OutlinedButton(
            onPressed: onRetry,
            child: const Text(
              'تلاش مجدد',
            ),
          ),
        ],
      ),
    );
  }
}