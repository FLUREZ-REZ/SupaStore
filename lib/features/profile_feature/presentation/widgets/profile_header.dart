import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:supastore/features/profile_feature/domain/entities/profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    required this.userId,
    this.profile,
  });

  final String email;
  final String userId;
  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    final fullName = profile?.fullName;
    final phone = profile?.phone;
    final avatarUrl = profile?.avatarUrl;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // ============================================================
          // AVATAR
          // ============================================================

          _Avatar(
            avatarUrl: avatarUrl,
          ),

          SizedBox(width: 14.w),

          // ============================================================
          // USER INFO
          // ============================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // FULL NAME
                // ------------------------------------------------------

                Text(
                  fullName?.isNotEmpty == true
                      ? fullName!
                      : 'کاربر فروشگاه',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 7.h),

                // ------------------------------------------------------
                // EMAIL
                // ------------------------------------------------------

                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                // ------------------------------------------------------
                // PHONE
                // ------------------------------------------------------

                if (phone != null && phone.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],

                SizedBox(height: 5.h),

                // ------------------------------------------------------
                // USER ID
                // ------------------------------------------------------

                Text(
                  'شناسه: ${_shortUserId(userId)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortUserId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return '${id.substring(0, 8)}...';
  }
}

// ====================================================================
// AVATAR
// ====================================================================

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
  });

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    // ================================================================
    // NO AVATAR
    // ================================================================

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _DefaultAvatar(
        color: primaryColor,
      );
    }

    // ================================================================
    // AVATAR IMAGE
    // ================================================================

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: 64.w,
        height: 64.w,
        fit: BoxFit.cover,

        // ------------------------------------------------------------
        // LOADING
        // ------------------------------------------------------------

        placeholder: (
            context,
            url,
            ) {
          return Container(
            width: 64.w,
            height: 64.w,
            color: primaryColor.withValues(
              alpha: 0.08,
            ),
            child: Center(
              child: SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              ),
            ),
          );
        },

        // ------------------------------------------------------------
        // ERROR
        // ------------------------------------------------------------

        errorWidget: (
            context,
            url,
            error,
            ) {
          return _DefaultAvatar(
            color: primaryColor,
          );
        },
      ),
    );
  }
}

// ====================================================================
// DEFAULT AVATAR
// ====================================================================

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.1,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        size: 34.sp,
        color: color,
      ),
    );
  }
}