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
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [

            /// User Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    "کاربر",
                    style:
                    AppTextStyles.user.copyWith(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(
                    height: 4.h,
                  ),

                  Text(
                    "9123545359",
                    style:
                    AppTextStyles.userName.copyWith(
                      fontWeight: FontWeight.w600
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
      color: AppColors.home_header_background,
      borderRadius:
      BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(14.r),
        onTap: onTap,
        child: SizedBox(
          width: 35.w,
          height: 35.h,
          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors.home_header,
          ),
        ),
      ),
    );
  }
}