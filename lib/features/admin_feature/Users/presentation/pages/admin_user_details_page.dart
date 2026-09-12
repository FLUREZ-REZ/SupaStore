import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/core/di/injector.dart';

import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';
import 'package:supastore/features/admin_feature/review/domain/entities/admin_review_entity.dart';
import 'package:supastore/features/admin_feature/review/domain/repositories/admin_review_repository.dart';
import 'package:supastore/features/address_feature/domain/usecases/get_address_by_id_use_case.dart';
import 'package:supastore/features/order_feature/domain/entities/order_entity.dart';
import 'package:supastore/features/order_feature/domain/repositories/order_repository.dart';
import 'package:supastore/features/order_feature/presentation/pages/admin_order_details_page.dart';
import 'package:supastore/features/order_feature/presentation/providers/admin_order_provider.dart';

class AdminUserDetailsPage extends StatefulWidget {
  const AdminUserDetailsPage({
    super.key,
    required this.user,
  });

  final AdminUser user;

  @override
  State<AdminUserDetailsPage> createState() =>
      _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState
    extends State<AdminUserDetailsPage> {
  late Future<List<OrderEntity>> _ordersFuture;
  late Future<List<AdminReviewEntity>> _reviewsFuture;

  bool _showAllOrders = false;
  bool _showAllReviews = false;

  @override
  void initState() {
    super.initState();

    _ordersFuture = _loadOrders();
    _reviewsFuture = _loadReviews();
  }

  Future<List<OrderEntity>> _loadOrders() async {
    final repository = getIt<OrderRepository>();

    return repository.getUserOrders(
      widget.user.id,
    );
  }

  Future<List<AdminReviewEntity>> _loadReviews() async {
    final repository = getIt<AdminReviewRepository>();

    final phone = widget.user.phone?.trim();

    if (phone == null || phone.isEmpty) {
      return [];
    }

    final reviews = await repository.getReviews(
      status: 'all',
      search: phone,
      limit: 100,
      offset: 0,
    );

    return reviews
        .where(
          (review) => review.userId == widget.user.id,
    )
        .toList();
  }

  String _displayName() {
    final name = widget.user.fullName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    if (widget.user.phone != null &&
        widget.user.phone!.trim().isNotEmpty) {
      return widget.user.phone!;
    }

    return 'کاربر بدون نام';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'نامشخص';
    }

    final localDate = date.toLocal();

    final year = localDate.year.toString().padLeft(4, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return 'نامشخص';
    }

    final localDate = date.toLocal();

    final year = localDate.year.toString().padLeft(4, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - $hour:$minute';
  }

  String _formatPrice(int price) {
    final value = price.toString();

    return value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = widget.user.avatarUrl?.trim();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 96.w,
          height: 96.w,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return _defaultAvatar();
          },
          errorWidget: (context, url, error) {
            return _defaultAvatar();
          },
        ),
      );
    }

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: 48.sp,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: widget.user.isAdmin
            ? Colors.red.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.user.isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline_rounded,
            size: 17.sp,
            color: widget.user.isAdmin
                ? Colors.red
                : Colors.grey.shade700,
          ),
          SizedBox(width: 6.w),
          Text(
            widget.user.isAdmin
                ? 'مدیر'
                : 'کاربر عادی',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: widget.user.isAdmin
                  ? Colors.red
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            title: 'نام کامل',
            value: _displayName(),
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            title: 'شماره موبایل',
            value: widget.user.phone?.trim().isNotEmpty == true
                ? widget.user.phone!
                : 'ثبت نشده',
            isLtr: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            title: 'نقش',
            value: widget.user.isAdmin
                ? 'مدیر'
                : 'کاربر عادی',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'تاریخ عضویت',
            value: _formatDate(widget.user.createdAt),
            isLtr: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.update_outlined,
            title: 'آخرین بروزرسانی',
            value: _formatDate(widget.user.updatedAt),
            isLtr: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLtr = false,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            size: 19.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 3.h),
              Directionality(
                textDirection:
                isLtr ? TextDirection.ltr : TextDirection.rtl,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 13.h,
      ),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        int? count,
      }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        if (count != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 3.h,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShowAllButton({
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 4.h,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expanded ? 'نمایش کمتر' : 'مشاهده همه',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: expanded ? 18.sp : 12.sp,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return FutureBuilder<List<OrderEntity>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('سفارش‌ها'),
              SizedBox(height: 10.h),
              _buildLoadingCard(),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('سفارش‌ها'),
              SizedBox(height: 10.h),
              _buildErrorCard(
                title: 'خطا در دریافت سفارش‌ها',
                onRetry: () {
                  setState(() {
                    _ordersFuture = _loadOrders();
                  });
                },
              ),
            ],
          );
        }

        final orders = snapshot.data ?? [];

        final visibleOrders = _showAllOrders
            ? orders
            : orders.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'سفارش‌ها',
              count: orders.length,
            ),
            SizedBox(height: 10.h),
            if (orders.isEmpty)
              _buildEmptyCard(
                icon: Icons.shopping_bag_outlined,
                title: 'هنوز سفارشی ثبت نشده',
                description:
                'این کاربر تاکنون سفارشی ثبت نکرده است.',
              )
            else ...[
              ...visibleOrders.map(
                    (order) => Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.h,
                  ),
                  child: _buildOrderCard(order),
                ),
              ),
              if (orders.length > 2)
                _buildShowAllButton(
                  expanded: _showAllOrders,
                  onTap: () {
                    setState(() {
                      _showAllOrders = !_showAllOrders;
                    });
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(
      OrderEntity order,
      ) {
    final status = _getOrderStatusConfig(
      order.status,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminOrderDetailsPage(
                order: order,
                provider: getIt<AdminOrderProvider>(),
                getAddressByIdUseCase:
                getIt<GetAddressByIdUseCase>(),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 7.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.red,
                      size: 21.sp,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            'سفارش #${order.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _formatDateTime(
                              order.createdAt,
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildOrderStatusBadge(status),
                ],
              ),
              SizedBox(height: 13.h),
              Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              SizedBox(height: 13.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOrderInfo(
                      icon: Icons.shopping_bag_outlined,
                      title: 'تعداد کالا',
                      value: '${order.items.length} کالا',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildOrderInfo(
                      icon: Icons.payment_outlined,
                      title: 'پرداخت',
                      value: _paymentStatusTitle(
                        order.paymentStatus,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 13.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'مبلغ نهایی',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_formatPrice(order.totalPrice)} تومان',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'مشاهده جزئیات',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17.sp,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(
      _OrderStatusConfig config,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            config.title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _OrderStatusConfig _getOrderStatusConfig(
      String status,
      ) {
    switch (status) {
      case 'pending':
        return _OrderStatusConfig(
          'در انتظار',
          Colors.orange,
        );

      case 'processing':
        return _OrderStatusConfig(
          'در حال پردازش',
          Colors.blue,
        );

      case 'shipped':
        return _OrderStatusConfig(
          'ارسال شده',
          Colors.indigo,
        );

      case 'delivered':
        return _OrderStatusConfig(
          'تحویل شده',
          Colors.green,
        );

      case 'canceled':
        return _OrderStatusConfig(
          'لغو شده',
          Colors.red,
        );

      default:
        return _OrderStatusConfig(
          status,
          Colors.grey,
        );
    }
  }

  String _paymentStatusTitle(
      String status,
      ) {
    switch (status) {
      case 'paid':
        return 'پرداخت شده';

      case 'pending':
        return 'در انتظار';

      case 'failed':
        return 'ناموفق';

      case 'refunded':
        return 'بازگشت وجه';

      default:
        return status.isEmpty ? 'نامشخص' : status;
    }
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<AdminReviewEntity>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('نظرات'),
              SizedBox(height: 10.h),
              _buildLoadingCard(),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('نظرات'),
              SizedBox(height: 10.h),
              _buildErrorCard(
                title: 'خطا در دریافت نظرات',
                onRetry: () {
                  setState(() {
                    _reviewsFuture = _loadReviews();
                  });
                },
              ),
            ],
          );
        }

        final reviews = snapshot.data ?? [];

        final visibleReviews = _showAllReviews
            ? reviews
            : reviews.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'نظرات',
              count: reviews.length,
            ),
            SizedBox(height: 10.h),
            if (reviews.isEmpty)
              _buildEmptyCard(
                icon: Icons.rate_review_outlined,
                title: 'هنوز نظری ثبت نشده',
                description:
                'این کاربر تاکنون نظری برای محصولات ثبت نکرده است.',
              )
            else ...[
              ...visibleReviews.map(
                    (review) => Padding(
                  padding: EdgeInsets.only(
                    bottom: 10.h,
                  ),
                  child: _buildReviewCard(review),
                ),
              ),
              if (reviews.length > 2)
                _buildShowAllButton(
                  expanded: _showAllReviews,
                  onTap: () {
                    setState(() {
                      _showAllReviews = !_showAllReviews;
                    });
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(
      AdminReviewEntity review,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildReviewProductImage(review),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.productTitle?.trim().isNotEmpty == true
                          ? review.productTitle!
                          : 'محصول نامشخص',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        _formatDateTime(
                          review.createdAt,
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildReviewStatus(review),
            ],
          ),
          SizedBox(height: 13.h),
          Row(
            children: [
              ...List.generate(
                5,
                    (index) => Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 18.sp,
                  color: Colors.amber.shade600,
                ),
              ),
              SizedBox(width: 6.w),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${review.rating}/5',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              if (review.isVerifiedPurchase) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Text(
                    'خرید تأیید شده',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (review.title?.trim().isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Text(
              review.title!,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
          if (review.comment.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              review.comment,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.7,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewProductImage(
      AdminReviewEntity review,
      ) {
    final imageUrl = review.productThumbnail?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: 24.sp,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 58.w,
        height: 58.w,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewStatus(
      AdminReviewEntity review,
      ) {
    final color =
    review.isApproved ? Colors.green : Colors.orange;

    final title =
    review.isApproved ? 'تأیید شده' : 'در انتظار';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 28.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'در حال دریافت اطلاعات...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 25.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard({
    required String title,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 30.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'تلاش مجدد',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'جزئیات کاربر',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _ordersFuture = _loadOrders();
              _reviewsFuture = _loadReviews();

              _showAllOrders = false;
              _showAllReviews = false;
            });

            await Future.wait([
              _ordersFuture,
              _reviewsFuture,
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16.w,
              20.h,
              16.w,
              30.h,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAvatar(),
                      SizedBox(height: 12.h),
                      Text(
                        _displayName(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      if (widget.user.phone != null &&
                          widget.user.phone!.trim().isNotEmpty)
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            widget.user.phone!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      SizedBox(height: 12.h),
                      _buildRoleBadge(),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildSectionTitle('اطلاعات حساب'),
                SizedBox(height: 10.h),
                _buildInfoCard(),
                SizedBox(height: 22.h),
                _buildOrdersSection(),
                SizedBox(height: 12.h),
                _buildReviewsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderStatusConfig {
  const _OrderStatusConfig(
      this.title,
      this.color,
      );

  final String title;
  final Color color;
}