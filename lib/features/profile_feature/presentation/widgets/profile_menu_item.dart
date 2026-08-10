import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: (iconColor ??
                        Theme.of(context)
                            .colorScheme
                            .primary)
                        .withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12.r,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 22.sp,
                    color: iconColor ??
                        Theme.of(context)
                            .colorScheme
                            .primary,
                  ),
                ),

                SizedBox(width: 14.w),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_left,
                  size: 22.sp,
                  color:
                  Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            indent: 70.w,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}