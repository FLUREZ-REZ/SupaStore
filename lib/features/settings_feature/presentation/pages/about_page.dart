import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context)
            .colorScheme
            .primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Colors.grey.shade50,

        // ==========================================
        // APP BAR
        // ==========================================

        appBar: AppBar(
          title: const Text(
            'درباره ما',
          ),
          centerTitle: true,
          backgroundColor:
          AppColors.about_us_page_redi,
          elevation: 0,
        ),

        // ==========================================
        // BODY
        // ==========================================

        body: SingleChildScrollView(
          physics:
          const BouncingScrollPhysics(),

          padding: EdgeInsets.all(20.w),

          child: Column(
            children: [
              SizedBox(
                height: 25.h,
              ),

              // ======================================
              // LOGO
              // ======================================

              Container(
                width: 100.w,
                height: 100.w,

                decoration: BoxDecoration(
                  color: AppColors.about_us_page_redi ,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.storefront_outlined,
                  size: 52.sp,
                  color: AppColors.white,
                ),
              ),

              SizedBox(
                height: 18.h,
              ),

              // ======================================
              // APP NAME
              // ======================================

              Text(
                'Supastore',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              SizedBox(
                height: 8.h,
              ),

              // ======================================
              // SHORT DESCRIPTION
              // ======================================

              Text(
                'فروشگاه آنلاین Supastore',
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              SizedBox(
                height: 30.h,
              ),

              // ======================================
              // ABOUT CARD
              // ======================================

              Container(
                width: double.infinity,

                padding:
                EdgeInsets.all(20.w),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    18.r,
                  ),
                  border: Border.all(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 22.sp,
                          color:
                          primaryColor,
                        ),

                        SizedBox(
                          width: 8.w,
                        ),

                        Text(
                          'درباره Supastore',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 16.h,
                    ),

                    Text(
                      'Supastore یک فروشگاه آنلاین است که با هدف ارائه تجربه‌ای ساده، سریع و راحت برای خرید طراحی شده است.',
                      textAlign:
                      TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.8,
                        color:
                        Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 20.h,
              ),

              // ======================================
              // VERSION CARD
              // ======================================

              Container(
                width: double.infinity,

                padding:
                EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    18.r,
                  ),
                  border: Border.all(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons
                          .system_update_outlined,
                      size: 22.sp,
                      color:
                      Colors.grey.shade600,
                    ),

                    SizedBox(
                      width: 12.w,
                    ),

                    Expanded(
                      child: Text(
                        'نسخه برنامه',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ),

                    Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                        Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 40.h,
              ),

              // ======================================
              // COPYRIGHT
              // ======================================

              Text(
                '© 2026 Supastore',
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}