import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';

// مسیرها را مطابق ساختار پروژه خودت تنظیم کن.
import 'package:supastore/features/settings_feature/presentation/pages/about_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/privacy_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/support_page.dart';

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
              top: 32.h,
            ),
            padding: EdgeInsets.fromLTRB(
              20.w,
              30.h,
              20.w,
              22.h,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreHeader(
                  storeName: storeSettingsProvider.storeName,
                  tagline: storeSettingsProvider.tagline,
                ),

                SizedBox(height: 28.h),

                const _ServicesSection(),

                SizedBox(height: 28.h),

                const _FooterDivider(),

                SizedBox(height: 24.h),

                _ContactSection(
                  phone: storeSettingsProvider.phone,
                  email: storeSettingsProvider.email,
                  address: storeSettingsProvider.address,
                  website: storeSettingsProvider.website,
                ),

                SizedBox(height: 26.h),

                const _FooterDivider(),

                SizedBox(height: 24.h),

                _LinksAndSocialSection(
                  instagram: storeSettingsProvider.instagram,
                  telegram: storeSettingsProvider.telegram,
                ),

                SizedBox(height: 24.h),

                const _FooterDivider(),

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: AppColors.orders_page_redi,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Iconsax.bag_2_copy,
            size: 23.sp,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 13.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                ),
              ),

              if (cleanTagline != null && cleanTagline.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  cleanTagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
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
        const Expanded(
          child: _ServiceItem(
            icon: Iconsax.truck_fast_copy,
            title: 'ارسال سریع',
            subtitle: 'تحویل مطمئن',
          ),
        ),

        const _VerticalDivider(),

        const Expanded(
          child: _ServiceItem(
            icon: Iconsax.verify_copy,
            title: 'پرداخت امن',
            subtitle: 'امن و مطمئن',
          ),
        ),

        const _VerticalDivider(),

        const Expanded(
          child: _ServiceItem(
            icon: Iconsax.message_copy,
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
    return Column(
      children: [
        Icon(
          icon,
          size: 23.sp,
          color: AppColors.orders_page_redi,
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),

        SizedBox(height: 3.h),

        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8.5.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38.h,
      color: Colors.grey.shade300,
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
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
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, 'امکان برقراری تماس وجود ندارد.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, 'امکان برقراری تماس وجود ندارد.');
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
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, 'برنامه‌ای برای ارسال ایمیل پیدا نشد.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, 'برنامه‌ای برای ارسال ایمیل پیدا نشد.');
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

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      if (!context.mounted) return;
      _showError(context, 'آدرس وب‌سایت معتبر نیست.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, 'امکان باز کردن وب‌سایت وجود ندارد.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, 'امکان باز کردن وب‌سایت وجود ندارد.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanPhone = phone?.trim();
    final cleanEmail = email?.trim();
    final cleanAddress = address?.trim();
    final cleanWebsite = website?.trim();

    final hasPhone = cleanPhone != null && cleanPhone.isNotEmpty;
    final hasEmail = cleanEmail != null && cleanEmail.isNotEmpty;
    final hasAddress = cleanAddress != null && cleanAddress.isNotEmpty;
    final hasWebsite = cleanWebsite != null && cleanWebsite.isNotEmpty;

    if (!hasPhone && !hasEmail && !hasAddress && !hasWebsite) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تماس با ما',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF252525),
          ),
        ),

        SizedBox(height: 14.h),

        if (hasAddress)
          _ContactItem(
            icon: Iconsax.location_copy,
            title: 'آدرس',
            value: cleanAddress!,
            onTap: null,
          ),

        if (hasAddress && (hasPhone || hasEmail || hasWebsite))
          SizedBox(height: 10.h),

        if (hasPhone)
          _ContactItem(
            icon: Iconsax.call_copy,
            title: 'تلفن',
            value: cleanPhone!,
            onTap: () {
              _callPhone(context, cleanPhone);
            },
          ),

        if (hasPhone && (hasEmail || hasWebsite))
          SizedBox(height: 10.h),

        if (hasEmail)
          _ContactItem(
            icon: Iconsax.send_1_copy,
            title: 'ایمیل',
            value: cleanEmail!,
            onTap: () {
              _sendEmail(context, cleanEmail);
            },
          ),

        if (hasEmail && hasWebsite)
          SizedBox(height: 10.h),

        if (hasWebsite)
          _ContactItem(
            icon: Iconsax.link_copy,
            title: 'وب‌سایت',
            value: cleanWebsite!,
            onTap: () {
              _openWebsite(context, cleanWebsite);
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 7.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30.w,
                child: Icon(
                  icon,
                  size: 19.sp,
                  color: AppColors.orders_page_redi,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.h,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 11.sp,
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

class _LinksAndSocialSection extends StatelessWidget {
  const _LinksAndSocialSection({
    required this.instagram,
    required this.telegram,
  });

  final String? instagram;
  final String? telegram;

  Future<void> _openSocial(
      BuildContext context,
      String value,
      String baseUrl,
      String errorMessage,
      ) async {
    final cleanValue = value.trim();

    final url = cleanValue.startsWith('http://') ||
        cleanValue.startsWith('https://')
        ? cleanValue
        : '$baseUrl${cleanValue.replaceFirst('@', '')}';

    final uri = Uri.tryParse(url);

    if (uri == null || uri.host.isEmpty) {
      if (!context.mounted) return;
      _showSocialError(context, errorMessage);
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showSocialError(context, errorMessage);
      }
    } catch (_) {
      if (!context.mounted) return;
      _showSocialError(context, errorMessage);
    }
  }

  void _showSocialError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanInstagram = instagram?.trim();
    final cleanTelegram = telegram?.trim();

    final hasInstagram =
        cleanInstagram != null && cleanInstagram.isNotEmpty;

    final hasTelegram =
        cleanTelegram != null && cleanTelegram.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دسترسی سریع',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF252525),
                ),
              ),

              SizedBox(height: 10.h),

              _FooterLink(
                title: 'درباره ما',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutPage(),
                    ),
                  );
                },
              ),

              _FooterLink(
                title: 'تماس با ما',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SupportPage(),
                    ),
                  );
                },
              ),

              _FooterLink(
                title: 'قوانین و مقررات',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPage(),
                    ),
                  );
                },
              ),

              _FooterLink(
                title: 'حریم خصوصی',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        if (hasInstagram || hasTelegram)
          SizedBox(width: 10.w),

        if (hasInstagram || hasTelegram)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'شبکه‌های اجتماعی',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF252525),
                ),
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  if (hasInstagram)
                    _SocialButton(
                      icon: Iconsax.instagram_copy,
                      onTap: () {
                        _openSocial(
                          context,
                          cleanInstagram!,
                          'https://instagram.com/',
                          'امکان باز کردن اینستاگرام وجود ندارد.',
                        );
                      },
                    ),

                  if (hasInstagram && hasTelegram)
                    SizedBox(width: 8.w),

                  if (hasTelegram)
                    _SocialButton(
                      icon: Iconsax.send_2_copy,
                      onTap: () {
                        _openSocial(
                          context,
                          cleanTelegram!,
                          'https://t.me/',
                          'امکان باز کردن تلگرام وجود ندارد.',
                        );
                      },
                    ),
                ],
              ),
            ],
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
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ),
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
      borderRadius: BorderRadius.circular(11.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            size: 19.sp,
            color: AppColors.orders_page_redi,
          ),
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade300,
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
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'تمامی حقوق محفوظ است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}