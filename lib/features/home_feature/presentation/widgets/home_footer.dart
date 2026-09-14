import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StoreSettingsProvider>(
        builder: (
            context,
            storeSettingsProvider,
            child,
            ) {
          return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreHeader(
                  storeName: storeSettingsProvider.storeName,
                  tagline: storeSettingsProvider.tagline,
                ),
                SizedBox(height: 28.h),
                _ServicesSection(),
                SizedBox(height: 28.h),
                _ContactSection(
                  phone: storeSettingsProvider.phone,
                  email: storeSettingsProvider.email,
                  address: storeSettingsProvider.address,
                  website: storeSettingsProvider.website,
                ),
                SizedBox(height: 28.h),
                _LinksSection(),
                SizedBox(height: 28.h),
                _SocialSection(
                  instagram: storeSettingsProvider.instagram,
                  telegram: storeSettingsProvider.telegram,
                ),
                SizedBox(height: 28.h),
                Divider(
                  height: 1.h,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 18.h),
                _Copyright(
                  storeName: storeSettingsProvider.storeName,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.storeName,
    required this.tagline,
  });

  final String storeName;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final cleanTagline = tagline?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: AppColors.orders_page_redi,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 27.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (cleanTagline != null &&
                  cleanTagline.isNotEmpty) ...[
                SizedBox(height: 5.h),
                Text(
                  cleanTagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

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
        SizedBox(width: 10.w),
        Expanded(
          child: _ServiceItem(
            icon: Icons.security_outlined,
            title: 'پرداخت امن',
            subtitle: 'امن و مطمئن',
          ),
        ),
        SizedBox(width: 10.w),
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
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3.h),
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

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
  });

  final String? phone;
  final String? email;
  final String? address;
  final String? website;

  Future<void> _callPhone(
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

  Future<void> _openWebsite(
      BuildContext context,
      String website,
      ) async {
    String url = website.trim();

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'آدرس وب‌سایت معتبر نیست.',
          ),
        ),
      );

      return;
    }

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
            'امکان باز کردن وب‌سایت وجود ندارد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanPhone = phone?.trim();
    final cleanEmail = email?.trim();
    final cleanAddress = address?.trim();
    final cleanWebsite = website?.trim();

    final hasPhone =
        cleanPhone != null &&
            cleanPhone.isNotEmpty;

    final hasEmail =
        cleanEmail != null &&
            cleanEmail.isNotEmpty;

    final hasAddress =
        cleanAddress != null &&
            cleanAddress.isNotEmpty;

    final hasWebsite =
        cleanWebsite != null &&
            cleanWebsite.isNotEmpty;

    if (!hasPhone &&
        !hasEmail &&
        !hasAddress &&
        !hasWebsite) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اطلاعات تماس',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 14.h),

        if (hasAddress)
          _ContactItem(
            icon: Icons.location_on_outlined,
            title: 'آدرس',
            value: cleanAddress!,
            onTap: null,
          ),

        if (hasAddress &&
            (hasPhone || hasEmail || hasWebsite))
          SizedBox(height: 10.h),

        if (hasPhone)
          _ContactItem(
            icon: Icons.phone_outlined,
            title: 'تلفن',
            value: cleanPhone!,
            onTap: () {
              _callPhone(
                context,
                cleanPhone,
              );
            },
          ),

        if (hasPhone &&
            (hasEmail || hasWebsite))
          SizedBox(height: 10.h),

        if (hasEmail)
          _ContactItem(
            icon: Icons.email_outlined,
            title: 'ایمیل',
            value: cleanEmail!,
            onTap: () {
              _sendEmail(
                context,
                cleanEmail,
              );
            },
          ),

        if (hasEmail && hasWebsite)
          SizedBox(height: 10.h),

        if (hasWebsite)
          _ContactItem(
            icon: Icons.language_outlined,
            title: 'وب‌سایت',
            value: cleanWebsite!,
            onTap: () {
              _openWebsite(
                context,
                cleanWebsite,
              );
            },
          ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  icon,
                  size: 21.sp,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
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
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: 10.h,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinksSection extends StatelessWidget {
  const _LinksSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'دسترسی سریع',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 14.h),
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
      borderRadius: BorderRadius.circular(8.r),
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
            SizedBox(width: 7.w),
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

class _SocialSection extends StatelessWidget {
  const _SocialSection({
    required this.instagram,
    required this.telegram,
  });

  final String? instagram;
  final String? telegram;

  Future<void> _openInstagram(
      BuildContext context,
      String value,
      ) async {
    final cleanValue = value.trim();

    final uri = Uri.tryParse(
      cleanValue.startsWith('http')
          ? cleanValue
          : 'https://instagram.com/${cleanValue.replaceFirst('@', '')}',
    );

    if (uri == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'آدرس اینستاگرام معتبر نیست.',
          ),
        ),
      );

      return;
    }

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
            'امکان باز کردن اینستاگرام وجود ندارد.',
          ),
        ),
      );
    }
  }

  Future<void> _openTelegram(
      BuildContext context,
      String value,
      ) async {
    final cleanValue = value.trim();

    final uri = Uri.tryParse(
      cleanValue.startsWith('http')
          ? cleanValue
          : 'https://t.me/${cleanValue.replaceFirst('@', '')}',
    );

    if (uri == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'آدرس تلگرام معتبر نیست.',
          ),
        ),
      );

      return;
    }

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
            'امکان باز کردن تلگرام وجود ندارد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanInstagram = instagram?.trim();
    final cleanTelegram = telegram?.trim();

    final hasInstagram =
        cleanInstagram != null &&
            cleanInstagram.isNotEmpty;

    final hasTelegram =
        cleanTelegram != null &&
            cleanTelegram.isNotEmpty;

    if (!hasInstagram && !hasTelegram) {
      return const SizedBox.shrink();
    }

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

        if (hasInstagram)
          _SocialButton(
            icon: Icons.camera_alt_outlined,
            onTap: () {
              _openInstagram(
                context,
                cleanInstagram!,
              );
            },
          ),

        if (hasInstagram && hasTelegram)
          SizedBox(width: 8.w),

        if (hasTelegram)
          _SocialButton(
            icon: Icons.send_outlined,
            onTap: () {
              _openTelegram(
                context,
                cleanTelegram!,
              );
            },
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
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
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

class _Copyright extends StatelessWidget {
  const _Copyright({
    required this.storeName,
  });

  final String storeName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} $storeName',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5.h),
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