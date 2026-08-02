import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
      child: Row(
        children: [

          /// User Info
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  "سلام 👋",
                  style:
                  AppTextStyles.body.copyWith(
                    color: Colors.grey,
                  ),
                ),

                SizedBox(
                  height: 4.h,
                ),

                Text(
                  "رضا",
                  style:
                  AppTextStyles.otp_title.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// Notification
          _IconButton(
            icon: Icons.notifications_outlined,
            onTap: () {},
          ),

          SizedBox(
            width: 12.w,
          ),

          /// Cart
          _IconButton(
            icon: Icons.shopping_cart_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black,
      borderRadius:
      BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(14.r),
        onTap: onTap,
        child: SizedBox(
          width: 48.w,
          height: 48.h,
          child: Icon(
            icon,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}