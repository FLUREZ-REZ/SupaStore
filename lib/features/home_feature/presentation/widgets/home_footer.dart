import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          top: 24.h,
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          28.h,
          20.w,
          20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==========================================
            // Store Header
            // ==========================================

            _StoreHeader(),

            SizedBox(
              height: 28.h,
            ),

            // ==========================================
            // Services
            // ==========================================

            _ServicesSection(),

            SizedBox(
              height: 28.h,
            ),

            // ==========================================
            // Links
            // ==========================================

            _LinksSection(),

            SizedBox(
              height: 28.h,
            ),

            // ==========================================
            // Social Media
            // ==========================================

            _SocialSection(),

            SizedBox(
              height: 28.h,
            ),

            // ==========================================
            // Divider
            // ==========================================

            Divider(
              height: 1.h,
              color: Colors.grey.shade300,
            ),

            SizedBox(
              height: 18.h,
            ),

            // ==========================================
            // Copyright
            // ==========================================

            _Copyright(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// Store Header
// ======================================================

class _StoreHeader extends StatelessWidget {
  const _StoreHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary,
            borderRadius:
            BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 27.sp,
            color: Colors.white,
          ),
        ),

        SizedBox(
          width: 14.w,
        ),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'سوپاستور',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(
                height: 5.h,
              ),

              Text(
                'خرید آسان، سریع و مطمئن',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================
// Services
// ======================================================

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServiceItem(
            icon: Icons.local_shipping_outlined,
            title: 'ارسال سریع',
            subtitle: 'تحویل مطمئن',
          ),
        ),

        SizedBox(
          width: 10.w,
        ),

        Expanded(
          child: _ServiceItem(
            icon: Icons.security_outlined,
            title: 'پرداخت امن',
            subtitle: 'امن و مطمئن',
          ),
        ),

        SizedBox(
          width: 10.w,
        ),

        Expanded(
          child: _ServiceItem(
            icon: Icons.support_agent_outlined,
            title: 'پشتیبانی',
            subtitle: 'همراه شما',
          ),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),

          SizedBox(
            height: 8.h,
          ),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 3.h,
          ),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// Links
// ======================================================

class _LinksSection extends StatelessWidget {
  const _LinksSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'دسترسی سریع',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(
          height: 14.h,
        ),

        _FooterLink(
          title: 'درباره ما',
          onTap: () {},
        ),

        _FooterLink(
          title: 'تماس با ما',
          onTap: () {},
        ),

        _FooterLink(
          title: 'قوانین و مقررات',
          onTap: () {},
        ),

        _FooterLink(
          title: 'حریم خصوصی',
          onTap: () {},
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 7.h,
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              size: 12.sp,
              color: Colors.grey.shade500,
            ),

            SizedBox(
              width: 7.w,
            ),

            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// Social
// ======================================================

class _SocialSection extends StatelessWidget {
  const _SocialSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'ما را دنبال کنید',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        _SocialButton(
          icon: Icons.camera_alt_outlined,
          onTap: () {},
        ),

        SizedBox(
          width: 8.w,
        ),

        _SocialButton(
          icon: Icons.send_outlined,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            size: 21.sp,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Copyright
// ======================================================

class _Copyright extends StatelessWidget {
  const _Copyright();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '© 2026 سوپاستور',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: 5.h,
          ),

          Text(
            'تمامی حقوق محفوظ است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}