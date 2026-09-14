import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _callSupport(
      BuildContext context,
      String phone,
      ) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'امکان برقراری تماس وجود ندارد.',
          ),
        ),
      );
    }
  }

  Future<void> _sendEmail(
      BuildContext context,
      String email,
      ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'برنامه‌ای برای ارسال ایمیل پیدا نشد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('پشتیبانی'),
          centerTitle: true,
          backgroundColor: AppColors.support_page_redi,
          elevation: 0,
        ),
        body: Consumer<StoreSettingsProvider>(
          builder: (context, storeSettingsProvider, child) {
            final phone = storeSettingsProvider.phone?.trim();
            final email = storeSettingsProvider.email?.trim();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            size: 34.sp,
                            color: AppColors.support_page_redi,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'چطور می‌توانیم کمکتان کنیم؟',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'در صورت داشتن سوال یا مشکل، با ما در ارتباط باشید.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  if ((phone != null && phone.isNotEmpty) ||
                      (email != null && email.isNotEmpty)) ...[
                    const _SectionTitle(
                      title: 'راه‌های ارتباطی',
                    ),
                    SizedBox(height: 8.h),
                  ],

                  if (phone != null && phone.isNotEmpty)
                    _SupportItem(
                      icon: Icons.phone_outlined,
                      title: 'تماس با پشتیبانی',
                      subtitle: phone,
                      iconColor: Colors.green,
                      onTap: () {
                        _callSupport(context, phone);
                      },
                    ),

                  if (phone != null &&
                      phone.isNotEmpty &&
                      email != null &&
                      email.isNotEmpty)
                    SizedBox(height: 10.h),

                  if (email != null && email.isNotEmpty)
                    _SupportItem(
                      icon: Icons.email_outlined,
                      title: 'ایمیل پشتیبانی',
                      subtitle: email,
                      iconColor: Colors.blue,
                      onTap: () {
                        _sendEmail(context, email);
                      },
                    ),

                  SizedBox(height: 24.h),

                  const _SectionTitle(
                    title: 'ساعات پاسخگویی',
                  ),

                  SizedBox(height: 8.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: Colors.orange,
                            size: 23.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شنبه تا پنجشنبه',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '۹:۰۰ تا ۱۸:۰۰',
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
                  ),

                  SizedBox(height: 24.h),

                  const _SectionTitle(
                    title: 'سوالات متداول',
                  ),

                  SizedBox(height: 8.h),

                  _FaqItem(
                    question: 'چطور سفارش خود را پیگیری کنم؟',
                    answer:
                    'از بخش «سفارش‌های من» در پروفایل می‌توانید وضعیت سفارش‌های خود را مشاهده کنید.',
                  ),

                  SizedBox(height: 8.h),

                  _FaqItem(
                    question: 'چطور اطلاعات پروفایل را تغییر دهم؟',
                    answer:
                    'از صفحه پروفایل وارد بخش ویرایش پروفایل شوید و اطلاعات موردنظر را تغییر دهید.',
                  ),

                  SizedBox(height: 8.h),

                  _FaqItem(
                    question:
                    'اگر مشکلی در سفارش وجود داشته باشد چه کار کنم؟',
                    answer:
                    'می‌توانید با استفاده از اطلاعات تماس بالا با پشتیبانی ارتباط برقرار کنید.',
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  const _SupportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        childrenPadding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
        ),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Colors.grey.shade500,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.8,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}