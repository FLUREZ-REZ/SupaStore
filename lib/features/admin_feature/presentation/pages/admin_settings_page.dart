import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_payments_settings_feature/presentation/pages/admin_payment_settings_page.dart';
import 'package:supastore/features/admin_feature/settings/presentation/pages/admin_store_infopage.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/pages/admin_shipping_page.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/providers/admin_shipping_provider.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تنظیمات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.w,
            18.h,
            16.w,
            32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),

              _buildSettingTile(
                icon: Icons.storefront_outlined,
                iconColor: Colors.red,
                title: 'اطلاعات فروشگاه',
                subtitle:
                'نام، لوگو، اطلاعات تماس، آدرس، شبکه‌های اجتماعی و اطلاعات حقوقی',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminStoreInfoPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: 22.h),

              _buildSectionTitle('محصولات'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.deepOrange,
                  title: 'تنظیمات محصولات',
                  subtitle:
                  'نمایش محصولات، موجودی، محصولات ویژه، محصولات جدید و قیمت‌ها',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('سفارش‌ها'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: Colors.blue,
                  title: 'تنظیمات سفارش‌ها',
                  subtitle:
                  'ثبت سفارش، حداقل مبلغ، لغو سفارش و وضعیت‌های سفارش',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('ارسال'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.local_shipping_outlined,
                  iconColor: Colors.indigo,
                  title: 'تنظیمات ارسال',
                  subtitle:
                  'روش‌های ارسال، هزینه، ارسال رایگان، محدوده و زمان ارسال',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return ChangeNotifierProvider<AdminShippingProvider>(
                            create: (_) =>
                                getIt<AdminShippingProvider>(),
                            child: const AdminShippingPage(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('پرداخت'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.payment_outlined,
                  iconColor: Colors.green,
                  title: 'تنظیمات پرداخت',
                  subtitle:
                  'درگاه پرداخت، پرداخت آنلاین، پرداخت در محل و حالت تست',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPaymentSettingsPage(),
                      ),
                    );
                  },
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('کاربران'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.people_outline_rounded,
                  iconColor: Colors.orange,
                  title: 'تنظیمات کاربران',
                  subtitle:
                  'ثبت‌نام، OTP، تأیید شماره و تنظیمات حساب کاربری',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('نظرات'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.rate_review_outlined,
                  iconColor: Colors.purple,
                  title: 'تنظیمات نظرات',
                  subtitle:
                  'فعال‌سازی، تأیید دستی، خرید تأییدشده و مدیریت نظرات',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('اعلان‌ها'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  iconColor: Colors.deepPurple,
                  title: 'تنظیمات اعلان‌ها',
                  subtitle:
                  'اعلان سفارش، پرداخت، تغییر وضعیت و نظر جدید',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('مدیران و امنیت'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.security_outlined,
                  iconColor: Colors.teal,
                  title: 'مدیران و امنیت',
                  subtitle:
                  'مدیران، نقش‌ها، سطح دسترسی و لاگ فعالیت‌ها',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 22.h),

              _buildSectionTitle('تنظیمات عمومی'),
              SizedBox(height: 10.h),
              _buildSettingsGroup([
                _buildSettingTile(
                  icon: Icons.tune_outlined,
                  iconColor: Colors.blueGrey,
                  title: 'تنظیمات عمومی سیستم',
                  subtitle:
                  'زبان، واحد پول، منطقه زمانی، تاریخ، تعمیرات و اطلاعات نسخه',
                  onTap: () {},
                ),
              ]),

              SizedBox(height: 28.h),

              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 28.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظیمات فروشگاه',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'مدیریت کامل تنظیمات فروشگاه و پنل مدیریت',
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.6,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsGroup(
      List<Widget> children,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 15.h,
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  size: 23.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        height: 1.55,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Column(
      children: [
        Divider(
          color: Colors.grey.shade200,
          height: 1,
        ),
        SizedBox(height: 18.h),
        Text(
          'SupaStore Admin Panel',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          'نسخه 1.0.0',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}