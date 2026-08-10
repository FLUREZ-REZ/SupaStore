import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    required this.userId,
  });

  final String email;
  final String userId;

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 34.sp,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),

          SizedBox(width: 14.w),

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
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  'شناسه: ${_shortUserId(userId)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                    Colors.grey.shade500,
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