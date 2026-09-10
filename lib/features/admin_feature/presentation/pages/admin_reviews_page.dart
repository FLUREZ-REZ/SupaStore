import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/review/domain/entities/admin_review_entity.dart';
import 'package:supastore/features/admin_feature/review/presentation/providers/admin_review_provider.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({
    super.key,
  });

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  late final TextEditingController _searchController;

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AdminReviewProvider>().loadPage();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) return;

        context.read<AdminReviewProvider>().searchReviews(value);
      },
    );
  }

  Future<void> _refresh() async {
    final provider = context.read<AdminReviewProvider>();

    await Future.wait([
      provider.refresh(),
      provider.loadCounts(),
    ]);
  }

  Future<void> _approveReview(
      AdminReviewEntity review,
      ) async {
    final provider = context.read<AdminReviewProvider>();

    final success = await provider.approveReview(
      review.id,
    );

    if (!mounted) return;

    if (success) {
      await provider.loadPage();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'نظر با موفقیت تأیید شد.',
          ),
        ),
      );
    } else {
      _showError(provider.error);
    }
  }

  Future<void> _rejectReview(
      AdminReviewEntity review,
      ) async {
    final confirmed = await _showConfirmDialog(
      title: 'مخفی کردن نظر',
      message:
      'آیا مطمئن هستید که می‌خواهید این نظر را مخفی کنید؟',
      confirmText: 'مخفی کردن',
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<AdminReviewProvider>();

    final success = await provider.rejectReview(review.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'نظر مخفی شد.',
          ),
        ),
      );
    } else {
      _showError(provider.error);
    }
  }

  Future<void> _deleteReview(
      AdminReviewEntity review,
      ) async {
    final confirmed = await _showConfirmDialog(
      title: 'حذف نظر',
      message:
      'این نظر برای همیشه حذف خواهد شد. ادامه می‌دهید؟',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<AdminReviewProvider>();


    print('PAGE: APPROVE CLICKED');
    print('PAGE: REVIEW ID = ${review.id}');
    final success = await provider.deleteReview(review.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'نظر با موفقیت حذف شد.',
          ),
        ),
      );
    } else {
      _showError(provider.error);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.right,
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'انصراف',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                confirmText,
                style: TextStyle(
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showError(String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'خطایی رخ داد.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReviewProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(provider),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSearchAndFilters(provider),
                    ),
                    SliverToBoxAdapter(
                      child: _buildStatusTabs(provider),
                    ),
                    if (provider.error != null &&
                        !provider.isLoading)
                      SliverToBoxAdapter(
                        child: _buildError(provider),
                      ),
                    if (provider.isLoading)
                      SliverPadding(
                        padding: EdgeInsets.all(16.w),
                        sliver: SliverList.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return _buildLoadingCard();
                          },
                        ),
                      )
                    else if (provider.reviews.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          12.h,
                          16.w,
                          24.h,
                        ),
                        sliver: SliverList.builder(
                          itemCount:
                          provider.reviews.length +
                              (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= provider.reviews.length) {
                              return _buildLoadMore(provider);
                            }

                            final review =
                            provider.reviews[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 12.h,
                              ),
                              child: _buildReviewCard(
                                review,
                                provider,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      AdminReviewProvider provider,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        20.h,
        16.w,
        12.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نظرات کاربران',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${provider.allCount} نظر ثبت شده',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: provider.isRefreshing ? null : _refresh,
              icon: Icon(
                Icons.refresh_rounded,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
      AdminReviewProvider provider,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText:
              'جستجوی کاربر، محصول یا متن نظر...',
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {});

                  context
                      .read<AdminReviewProvider>()
                      .searchReviews('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              _onSearchChanged(value);
            },
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildRatingDropdown(provider),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildFilterButton(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDropdown(
      AdminReviewProvider provider,
      ) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: provider.rating,
          isExpanded: true,
          hint: const Text(
            'همه امتیازها',
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'همه امتیازها',
              ),
            ),
            ...List.generate(
              5,
                  (index) {
                final value = index + 1;

                return DropdownMenuItem<int?>(
                  value: value,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '$value ستاره',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          onChanged: (value) {
            provider.setRating(value);
          },
        ),
      ),
    );
  }

  Widget _buildFilterButton(
      AdminReviewProvider provider,
      ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        provider.setStatus(value);
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'all',
            child: Text(
              'همه نظرات',
            ),
          ),
          PopupMenuItem(
            value: 'pending',
            child: Text(
              'در انتظار تأیید',
            ),
          ),
          PopupMenuItem(
            value: 'approved',
            child: Text(
              'تأیید شده',
            ),
          ),
        ];
      },
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.filter_list_rounded,
            ),
            Flexible(
              child: Text(
                _statusTitle(provider.status),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
          ],
        ),
      ),
    );
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار تأیید';

      case 'approved':
        return 'تأیید شده';

      default:
        return 'همه نظرات';
    }
  }

  Widget _buildStatusTabs(
      AdminReviewProvider provider,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip(
              title: 'همه',
              count: provider.allCount,
              value: 'all',
              provider: provider,
            ),
            SizedBox(width: 8.w),
            _buildStatusChip(
              title: 'در انتظار',
              count: provider.pendingCount,
              value: 'pending',
              provider: provider,
            ),
            SizedBox(width: 8.w),
            _buildStatusChip(
              title: 'تأیید شده',
              count: provider.approvedCount,
              value: 'approved',
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String title,
    required int count,
    required String value,
    required AdminReviewProvider provider,
  }) {
    final selected = provider.status == value;

    return GestureDetector(
      onTap: () {
        provider.setStatus(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            SizedBox(width: 7.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
      AdminReviewEntity review,
      AdminReviewProvider provider,
      ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewTop(review),
          SizedBox(height: 12.h),
          _buildProductInfo(review),
          SizedBox(height: 12.h),
          if (review.title != null &&
              review.title!.trim().isNotEmpty)
            Text(
              review.title!,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (review.title != null &&
              review.title!.trim().isNotEmpty)
            SizedBox(height: 6.h),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.7,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12.h),
          _buildBadges(review),
          SizedBox(height: 14.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          _buildActions(
            review,
            provider,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTop(
      AdminReviewEntity review,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(
          review.userAvatarUrl,
          review.userFullName,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userFullName?.trim().isNotEmpty == true
                    ? review.userFullName!
                    : 'کاربر بدون نام',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (review.userPhone != null &&
                  review.userPhone!.trim().isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  review.userPhone!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              SizedBox(height: 5.h),
              _buildStars(review.rating),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildStatusBadge(review.isApproved),
      ],
    );
  }

  Widget _buildAvatar(
      String? avatarUrl,
      String? name,
      ) {
    final initial =
    name?.trim().isNotEmpty == true
        ? name!.trim()[0]
        : '؟';

    if (avatarUrl != null &&
        avatarUrl.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 24.r,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          return Icon(
            index < rating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Colors.amber,
            size: 18.sp,
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool approved) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: approved
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        approved ? 'تأیید شده' : 'در انتظار',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: approved
              ? Colors.green.shade700
              : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildProductInfo(
      AdminReviewEntity review,
      ) {
    return Container(
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildProductThumbnail(
            review.productThumbnail,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'محصول',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  review.productTitle?.trim().isNotEmpty == true
                      ? review.productTitle!
                      : 'محصول حذف شده',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductThumbnail(
      String? thumbnail,
      ) {
    if (thumbnail == null ||
        thumbnail.trim().isEmpty) {
      return Container(
        width: 54.w,
        height: 54.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
        ),
      );
    }

    final imageUrl = _getStorageImageUrl(thumbnail);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        imageUrl,
        width: 54.w,
        height: 54.w,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return Container(
            width: 54.w,
            height: 54.w,
            color: Colors.grey.shade100,
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade400,
            ),
          );
        },
      ),
    );
  }

  String _getStorageImageUrl(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    return Supabase.instance.client.storage
        .from('assets')
        .getPublicUrl(path);
  }

  Widget _buildBadges(
      AdminReviewEntity review,
      ) {
    return Wrap(
      spacing: 7.w,
      runSpacing: 7.h,
      children: [
        if (review.isVerifiedPurchase)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14.sp,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 4.w),
                Text(
                  'خرید تأیید شده',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Text(
          _formatDate(review.createdAt),
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
      AdminReviewEntity review,
      AdminReviewProvider provider,
      ) {
    return Row(
      children: [
        if (!review.isApproved)
          Expanded(
            child: _buildActionButton(
              title: 'تأیید',
              icon: Icons.check_circle_outline_rounded,
              onPressed: provider.isActionLoading
                  ? null
                  : () {
                _approveReview(review);
              },
            ),
          ),
        if (!review.isApproved)
          SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            title: review.isApproved
                ? 'مخفی کردن'
                : 'حذف',
            icon: review.isApproved
                ? Icons.visibility_off_outlined
                : Icons.delete_outline_rounded,
            isDestructive: !review.isApproved,
            onPressed: provider.isActionLoading
                ? null
                : () {
              if (review.isApproved) {
                _rejectReview(review);
              } else {
                _deleteReview(review);
              }
            },
          ),
        ),
        if (review.isApproved)
          SizedBox(width: 8.w),
        if (review.isApproved)
          Expanded(
            child: _buildActionButton(
              title: 'حذف',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onPressed: provider.isActionLoading
                  ? null
                  : () {
                _deleteReview(review);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 17.sp,
      ),
      label: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive
            ? Colors.red.shade700
            : Colors.green.shade700,
        side: BorderSide(
          color: isDestructive
              ? Colors.red.shade200
              : Colors.green.shade200,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildLoadMore(
      AdminReviewProvider provider,
      ) {
    if (provider.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4.h,
        bottom: 8.h,
      ),
      child: OutlinedButton(
        onPressed: provider.loadMore,
        child: const Text(
          'نمایش نظرات بیشتر',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'نظری پیدا نشد',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              'در حال حاضر نظری مطابق فیلترهای انتخابی وجود ندارد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
      AdminReviewProvider provider,
      ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        0,
      ),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade700,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              provider.error ??
                  'خطایی رخ داده است.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: provider.loadPage,
            child: const Text(
              'تلاش مجدد',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 190.h,
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final year = localDate.year.toString();

    final month =
    localDate.month.toString().padLeft(2, '0');

    final day =
    localDate.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }
}