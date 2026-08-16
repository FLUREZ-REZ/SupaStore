import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({
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
            'حریم خصوصی',
          ),
          centerTitle: true,
          backgroundColor:
          Colors.white,
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
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ======================================
              // HEADER
              // ======================================

              Container(
                width: double.infinity,
                padding:
                EdgeInsets.all(20.w),

                decoration: BoxDecoration(
                  color: primaryColor
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18.r,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,

                      decoration:
                      BoxDecoration(
                        color: primaryColor
                            .withValues(
                          alpha: 0.12,
                        ),
                        shape:
                        BoxShape.circle,
                      ),

                      child: Icon(
                        Icons
                            .security_outlined,
                        size: 28.sp,
                        color:
                        primaryColor,
                      ),
                    ),

                    SizedBox(
                      width: 14.w,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'حریم خصوصی',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          SizedBox(
                            height: 5.h,
                          ),

                          Text(
                            'محافظت از اطلاعات شما برای ما اهمیت دارد.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 24.h,
              ),

              // ======================================
              // INTRO
              // ======================================

              _PrivacySection(
                title:
                'اطلاعاتی که دریافت می‌کنیم',
                icon:
                Icons.person_outline_rounded,
                iconColor:
                Colors.blue,
                child: const Text(
                  'برای استفاده از برخی امکانات Supastore ممکن است اطلاعاتی مانند شماره همراه، نام و اطلاعات مربوط به حساب کاربری شما دریافت شود.',
                ),
              ),

              // ======================================
              // PROFILE
              // ======================================

              _PrivacySection(
                title:
                'اطلاعات حساب کاربری',
                icon:
                Icons.account_circle_outlined,
                iconColor:
                Colors.green,
                child: const Text(
                  'اطلاعات حساب کاربری شما برای شناسایی حساب، نمایش اطلاعات پروفایل و ارائه خدمات فروشگاه استفاده می‌شود.',
                ),
              ),

              // ======================================
              // ORDERS
              // ======================================

              _PrivacySection(
                title:
                'اطلاعات سفارش‌ها',
                icon:
                Icons.receipt_long_outlined,
                iconColor:
                Colors.orange,
                child: const Text(
                  'اطلاعات مربوط به سبد خرید و سفارش‌های شما برای ثبت، پردازش و پیگیری سفارش‌ها استفاده می‌شود.',
                ),
              ),

              // ======================================
              // SECURITY
              // ======================================

              _PrivacySection(
                title:
                'امنیت اطلاعات',
                icon:
                Icons.lock_outline_rounded,
                iconColor:
                Colors.red,
                child: const Text(
                  'ما تلاش می‌کنیم اطلاعات کاربران به شکل مناسب نگهداری و محافظت شود و دسترسی به اطلاعات فقط در محدوده مورد نیاز برنامه انجام شود.',
                ),
              ),

              // ======================================
              // DATA SHARING
              // ======================================

              _PrivacySection(
                title:
                'اشتراک‌گذاری اطلاعات',
                icon:
                Icons.share_outlined,
                iconColor:
                Colors.purple,
                child: const Text(
                  'اطلاعات شخصی کاربران بدون مجوز قانونی یا رضایت کاربر، در اختیار اشخاص و مجموعه‌های غیرمرتبط قرار نخواهد گرفت.',
                ),
              ),

              // ======================================
              // USER CONTROL
              // ======================================

              _PrivacySection(
                title:
                'کنترل اطلاعات',
                icon:
                Icons.manage_accounts_outlined,
                iconColor:
                Colors.teal,
                child: const Text(
                  'شما می‌توانید اطلاعات پروفایل خود مانند نام و تصویر پروفایل را از طریق بخش ویرایش پروفایل تغییر دهید.',
                ),
              ),

              SizedBox(
                height: 10.h,
              ),

              // ======================================
              // LAST UPDATE
              // ======================================

              Center(
                child: Text(
                  'آخرین بروزرسانی: 2026',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                    Colors.grey.shade400,
                  ),
                ),
              ),

              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================
// PRIVACY SECTION
// ====================================================

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(
        bottom: 14.h,
      ),

      padding: EdgeInsets.all(18.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          16.r,
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
              Container(
                width: 38.w,
                height: 38.w,

                decoration:
                BoxDecoration(
                  color: iconColor
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10.r,
                  ),
                ),

                child: Icon(
                  icon,
                  size: 21.sp,
                  color: iconColor,
                ),
              ),

              SizedBox(
                width: 10.w,
              ),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 12.h,
          ),

          DefaultTextStyle(
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.9,
              color:
              Colors.grey.shade700,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}