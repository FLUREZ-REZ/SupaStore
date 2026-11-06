
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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

  static const double _maxContentWidth = 1180;

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

  Future<void> _approveReview(AdminReviewEntity review) async {
    final provider = context.read<AdminReviewProvider>();

    final success = await provider.approveReview(review.id);

    if (!mounted) return;

    if (success) {
      await provider.loadPage();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نظر با موفقیت تأیید شد.'),
        ),
      );
    } else {
      _showError(provider.error);
    }
  }

  Future<void> _rejectReview(AdminReviewEntity review) async {
    final confirmed = await _showConfirmDialog(
      title: 'مخفی کردن نظر',
      message: 'آیا مطمئن هستید که می‌خواهید این نظر را مخفی کنید؟',
      confirmText: 'مخفی کردن',
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<AdminReviewProvider>();

    final success = await provider.rejectReview(review.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نظر مخفی شد.'),
        ),
      );
    } else {
      _showError(provider.error);
    }
  }

  Future<void> _deleteReview(AdminReviewEntity review) async {
    final confirmed = await _showConfirmDialog(
      title: 'حذف نظر',
      message: 'این نظر برای همیشه حذف خواهد شد. ادامه می‌دهید؟',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<AdminReviewProvider>();

    final success = await provider.deleteReview(review.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نظر با موفقیت حذف شد.'),
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
              child: const Text('انصراف'),
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
        content: Text(error ?? 'خطایی رخ داد.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReviewProvider>(
      builder: (context, provider, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _maxContentWidth,
                  ),
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            padding: const EdgeInsets.all(16),
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
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              24,
                            ),
                            sliver: SliverList.builder(
                              itemCount: provider.reviews.length +
                                  (provider.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= provider.reviews.length) {
                                  return _buildLoadMore(provider);
                                }

                                final review = provider.reviews[index];

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
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
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(AdminReviewProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نظرات کاربران',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.allCount} نظر ثبت شده',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: provider.isRefreshing ? null : _refresh,
              tooltip: 'بروزرسانی',
              icon: const Icon(
                Iconsax.refresh_copy,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH AND FILTERS
  // ------------------------------------------------------------

  Widget _buildSearchAndFilters(AdminReviewProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 650;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRatingDropdown(provider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterButton(provider),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildRatingDropdown(provider),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterButton(provider),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'جستجوی کاربر، محصول یا متن نظر...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {});

            context.read<AdminReviewProvider>().searchReviews('');
          },
          icon: const Icon(Icons.close_rounded),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        _onSearchChanged(value);
      },
    );
  }

  Widget _buildRatingDropdown(AdminReviewProvider provider) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: provider.rating,
          isExpanded: true,
          hint: const Text(
            'همه امتیازها',
            overflow: TextOverflow.ellipsis,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('همه امتیازها'),
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
                        Iconsax.star_copy,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text('$value ستاره'),
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

  Widget _buildFilterButton(AdminReviewProvider provider) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        provider.setStatus(value);
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'all',
            child: Text('همه نظرات'),
          ),
          PopupMenuItem(
            value: 'pending',
            child: Text('در انتظار تأیید'),
          ),
          PopupMenuItem(
            value: 'approved',
            child: Text('تأیید شده'),
          ),
        ];
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.filter_list_rounded),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _statusTitle(provider.status),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
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

  // ------------------------------------------------------------
  // STATUS TABS
  // ------------------------------------------------------------

  Widget _buildStatusTabs(AdminReviewProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
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
            const SizedBox(width: 8),
            _buildStatusChip(
              title: 'در انتظار',
              count: provider.pendingCount,
              value: 'pending',
              provider: provider,
            ),
            const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // REVIEW CARD
  // ------------------------------------------------------------

  Widget _buildReviewCard(
      AdminReviewEntity review,
      AdminReviewProvider provider,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewTop(review),
          const SizedBox(height: 12),
          _buildProductInfo(review),
          const SizedBox(height: 12),
          if (review.title != null &&
              review.title!.trim().isNotEmpty)
            Text(
              review.title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (review.title != null &&
              review.title!.trim().isNotEmpty)
            const SizedBox(height: 6),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildBadges(review),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildActions(review, provider),
        ],
      ),
    );
  }

  Widget _buildReviewTop(AdminReviewEntity review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(
          review.userAvatarUrl,
          review.userFullName,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userFullName?.trim().isNotEmpty == true
                    ? review.userFullName!
                    : 'کاربر بدون نام',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (review.userPhone != null &&
                  review.userPhone!.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  review.userPhone!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              _buildStars(review.rating),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(review.isApproved),
      ],
    );
  }

  Widget _buildAvatar(
      String? avatarUrl,
      String? name,
      ) {
    final initial = name?.trim().isNotEmpty == true
        ? name!.trim()[0]
        : '؟';

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return _defaultUserAvatar(initial);
          },
          errorWidget: (context, url, error) {
            return _defaultUserAvatar(initial);
          },
        ),
      );
    }

    return _defaultUserAvatar(initial);
  }

  Widget _defaultUserAvatar(String initial) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
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
                ? Iconsax.star
                : Iconsax.star_1_copy,
            color: Colors.amber,
            size: 18,
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool approved) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: approved
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        approved ? 'تأیید شده' : 'در انتظار',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: approved
              ? Colors.green.shade700
              : Colors.orange.shade700,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT INFORMATION
  // ------------------------------------------------------------

  Widget _buildProductInfo(AdminReviewEntity review) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildProductThumbnail(review.productThumbnail),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محصول',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  review.productTitle?.trim().isNotEmpty == true
                      ? review.productTitle!
                      : 'محصول حذف شده',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildProductThumbnail(String? thumbnail) {
    if (thumbnail == null || thumbnail.trim().isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Iconsax.image_copy,
          color: Colors.grey.shade400,
        ),
      );
    }

    final imageUrl = _getStorageImageUrl(thumbnail);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return _productImagePlaceholder();
        },
        errorWidget: (context, url, error) {
          return _productImagePlaceholder();
        },
      ),
    );
  }

  Widget _productImagePlaceholder() {
    return Container(
      width: 54,
      height: 54,
      color: Colors.grey.shade100,
      child: Icon(
        Iconsax.image_copy,
        color: Colors.grey.shade400,
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

  // ------------------------------------------------------------
  // REVIEW BADGES
  // ------------------------------------------------------------

  Widget _buildBadges(AdminReviewEntity review) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (review.isVerifiedPurchase)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'خرید تأیید شده',
                  style: TextStyle(
                    fontSize: 11,
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
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // REVIEW ACTIONS
  // ------------------------------------------------------------

  Widget _buildActions(
      AdminReviewEntity review,
      AdminReviewProvider provider,
      ) {
    final List<Widget> buttons = [];

    if (!review.isApproved) {
      buttons.add(
        _buildActionButton(
          title: 'تأیید',
          icon: Icons.check_circle_outline_rounded,
          onPressed: provider.isActionLoading
              ? null
              : () => _approveReview(review),
        ),
      );

      buttons.add(
        _buildActionButton(
          title: 'حذف',
          icon: Iconsax.trash_copy,
          isDestructive: true,
          onPressed: provider.isActionLoading
              ? null
              : () => _deleteReview(review),
        ),
      );
    } else {
      buttons.add(
        _buildActionButton(
          title: 'مخفی کردن',
          icon: Iconsax.eye_slash_copy,
          onPressed: provider.isActionLoading
              ? null
              : () => _rejectReview(review),
        ),
      );

      buttons.add(
        _buildActionButton(
          title: 'حذف',
          icon: Iconsax.trash_copy,
          isDestructive: true,
          onPressed: provider.isActionLoading
              ? null
              : () => _deleteReview(review),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                buttons[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: buttons[i]),
            ],
          ],
        );
      },
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
        size: 17,
      ),
      label: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
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
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOAD MORE
  // ------------------------------------------------------------

  Widget _buildLoadMore(AdminReviewProvider provider) {
    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        bottom: 8,
      ),
      child: Center(
        child: OutlinedButton(
          onPressed: provider.loadMore,
          child: const Text('نمایش نظرات بیشتر'),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_copy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'نظری پیدا نشد',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'در حال حاضر نظری مطابق فیلترهای انتخابی وجود ندارد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildError(AdminReviewProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        0,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.warning_2_copy,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.error ?? 'خطایی رخ داده است.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: provider.loadPage,
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoadingCard() {
    return Container(
      height: 190,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE
  // ------------------------------------------------------------

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final year = localDate.year.toString();

    final month = localDate.month.toString().padLeft(2, '0');

    final day = localDate.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }
}
