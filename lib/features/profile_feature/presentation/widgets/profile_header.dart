import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    required this.userId,
    this.onEdit,
  });

  final String email;
  final String userId;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

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
          // PROFILE ICON
          // ============================================================

          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: primaryColor.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 34.sp,
              color: primaryColor,
            ),
          ),

          SizedBox(width: 14.w),

          // ============================================================
          // USER INFORMATION
          // ============================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'حساب کاربری',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  email.isNotEmpty
                      ? email
                      : 'کاربر فروشگاه',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  'شناسه: ${_shortUserId(userId)}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // EDIT BUTTON
          // ============================================================

          if (onEdit != null) ...[
            SizedBox(width: 8.w),

            Material(
              color: primaryColor.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(12.r),
              child: InkWell(
                onTap: onEdit,
                borderRadius:
                BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(9.w),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
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