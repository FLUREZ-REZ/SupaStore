import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/features/admin_feature/Users/domain/entities/admin_user.dart';



class AdminUserDetailsPage extends StatelessWidget {
  const AdminUserDetailsPage({
    super.key,
    required this.user,
  });

  final AdminUser user;

  String _displayName() {
    final name = user.fullName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    if (user.phone != null &&
        user.phone!.trim().isNotEmpty) {
      return user.phone!;
    }

    return 'کاربر بدون نام';
  }

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'نامشخص';
    }

    final localDate = date.toLocal();

    final year = localDate.year
        .toString()
        .padLeft(
      4,
      '0',
    );

    final month = localDate.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    final day = localDate.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$year/$month/$day';
  }

  Widget _buildAvatar() {
    final avatarUrl =
    user.avatarUrl?.trim();

    if (avatarUrl != null &&
        avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          24.r,
        ),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 96.w,
          height: 96.w,
          fit: BoxFit.cover,
          placeholder: (
              context,
              url,
              ) {
            return _defaultAvatar();
          },
          errorWidget: (
              context,
              url,
              error,
              ) {
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
        borderRadius: BorderRadius.circular(
          24.r,
        ),
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
        color: user.isAdmin
            ? Colors.red.withValues(
          alpha: 0.08,
        )
            : Colors.grey.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          10.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user.isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline_rounded,
            size: 17.sp,
            color: user.isAdmin
                ? Colors.red
                : Colors.grey.shade700,
          ),
          SizedBox(width: 6.w),
          Text(
            user.isAdmin
                ? 'مدیر'
                : 'کاربر عادی',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: user.isAdmin
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
      padding: EdgeInsets.all(
        16.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18.r,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 8.r,
            offset: Offset(
              0,
              3.h,
            ),
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
            value: user.phone?.trim().isNotEmpty == true
                ? user.phone!
                : 'ثبت نشده',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            title: 'نقش',
            value: user.isAdmin
                ? 'مدیر'
                : 'کاربر عادی',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'تاریخ عضویت',
            value: _formatDate(
              user.createdAt,
            ),
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.update_outlined,
            title: 'آخرین بروزرسانی',
            value: _formatDate(
              user.updatedAt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(
              11.r,
            ),
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
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
      String title,
      ) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildComingSoonCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        18.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16.r,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(
                12.r,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.red,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
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
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            20.h,
            16.w,
            30.h,
          ),
          child: Column(
            children: [
              // ----------------------------------------------------------------
              // PROFILE HEADER
              // ----------------------------------------------------------------

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  20.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    20.r,
                  ),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.035,
                      ),
                      blurRadius: 8.r,
                      offset: Offset(
                        0,
                        3.h,
                      ),
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

                    if (user.phone != null &&
                        user.phone!.trim().isNotEmpty)
                      Text(
                        user.phone!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),

                    SizedBox(height: 12.h),

                    _buildRoleBadge(),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ----------------------------------------------------------------
              // INFORMATION
              // ----------------------------------------------------------------

              _buildSectionTitle(
                'اطلاعات حساب',
              ),

              SizedBox(height: 10.h),

              _buildInfoCard(),

              SizedBox(height: 22.h),

              // ----------------------------------------------------------------
              // FUTURE SECTIONS
              // ----------------------------------------------------------------

              _buildSectionTitle(
                'بخش‌های کاربر',
              ),

              SizedBox(height: 10.h),

              _buildComingSoonCard(
                icon: Icons.location_on_outlined,
                title: 'آدرس‌ها',
                description:
                'آدرس‌های ثبت‌شده کاربر در این بخش نمایش داده می‌شوند.',
              ),

              SizedBox(height: 10.h),

              _buildComingSoonCard(
                icon: Icons.shopping_bag_outlined,
                title: 'سفارش‌ها',
                description:
                'پس از تکمیل سیستم سفارش، سفارش‌های کاربر اینجا نمایش داده می‌شوند.',
              ),

              SizedBox(height: 10.h),

              _buildComingSoonCard(
                icon: Icons.rate_review_outlined,
                title: 'نظرات',
                description:
                'نظرات ثبت‌شده کاربر در این بخش نمایش داده می‌شوند.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}