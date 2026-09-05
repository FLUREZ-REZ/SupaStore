import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خلاصه وضعیت فروشگاه',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.45,
            children: const [
              _StatCard(
                title: 'فروش امروز',
                value: '۰ تومان',
                icon: Icons.payments_rounded,
              ),
              _StatCard(
                title: 'سفارش‌ها',
                value: '۰',
                icon: Icons.shopping_bag_rounded,
              ),
              _StatCard(
                title: 'محصولات',
                value: '۰',
                icon: Icons.inventory_2_rounded,
              ),
              _StatCard(
                title: 'کاربران',
                value: '۰',
                icon: Icons.people_alt_rounded,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'فعالیت‌های اخیر',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(
              child: Text(
                'هنوز فعالیتی ثبت نشده است.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 26.sp,
            color: const Color(0xFFE21B23),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}