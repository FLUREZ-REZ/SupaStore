import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsMenuItem extends StatelessWidget {
  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color =
        iconColor ??
            Theme.of(context)
                .colorScheme
                .primary;

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        child: Row(
          children: [
            // ICON
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: color,
              ),
            ),

            SizedBox(width: 14.w),

            // TITLE
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            // TRAILING
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15.sp,
                color:
                Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}