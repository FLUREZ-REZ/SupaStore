
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/store_settings_provider.dart';

import 'package:supastore/features/settings_feature/presentation/pages/about_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/privacy_page.dart';
import 'package:supastore/features/settings_feature/presentation/pages/support_page.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StoreSettingsProvider>(
        builder: (context, storeSettingsProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final isDesktop = width >= 1000;
              final horizontalPadding = isDesktop
                  ? 32.0
                  : width >= 600
                  ? 24.0
                  : 18.0;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 32),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F6),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1280,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isDesktop ? 36 : 28,
                        horizontalPadding,
                        22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StoreHeader(
                            storeName: storeSettingsProvider.storeName,
                            tagline: storeSettingsProvider.tagline,
                          ),

                          SizedBox(height: isDesktop ? 32 : 26),

                          const _ServicesSection(),

                          SizedBox(height: isDesktop ? 32 : 26),

                          const _FooterDivider(),

                          SizedBox(height: isDesktop ? 28 : 22),

                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _ContactSection(
                                    phone: storeSettingsProvider.phone,
                                    email: storeSettingsProvider.email,
                                    address: storeSettingsProvider.address,
                                    website: storeSettingsProvider.website,
                                  ),
                                ),

                                const SizedBox(width: 32),

                                Container(
                                  width: 1,
                                  height: 150,
                                  color: Colors.grey.shade300,
                                ),

                                const SizedBox(width: 32),

                                Expanded(
                                  flex: 5,
                                  child: _LinksAndSocialSection(
                                    instagram:
                                    storeSettingsProvider.instagram,
                                    telegram:
                                    storeSettingsProvider.telegram,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _ContactSection(
                              phone: storeSettingsProvider.phone,
                              email: storeSettingsProvider.email,
                              address: storeSettingsProvider.address,
                              website: storeSettingsProvider.website,
                            ),

                            const SizedBox(height: 24),

                            const _FooterDivider(),

                            const SizedBox(height: 22),

                            _LinksAndSocialSection(
                              instagram: storeSettingsProvider.instagram,
                              telegram: storeSettingsProvider.telegram,
                            ),
                          ],

                          const SizedBox(height: 24),

                          const _FooterDivider(),

                          const SizedBox(height: 18),

                          _Copyright(
                            storeName: storeSettingsProvider.storeName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// Store Header
// ------------------------------------------------------------

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.storeName,
    required this.tagline,
  });

  final String storeName;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 600 && width < 1000;

    final iconBoxSize = isDesktop
        ? 52.0
        : isTablet
        ? 48.0
        : 44.0;

    final cleanTagline = tagline?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: AppColors.orders_page_redi,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Iconsax.bag_2_copy,
            size: isDesktop ? 25 : 22,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isDesktop
                      ? 19
                      : isTablet
                      ? 18
                      : 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                ),
              ),

              if (cleanTagline != null && cleanTagline.isNotEmpty) ...[
                const SizedBox(height: 5),

                Text(
                  cleanTagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
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

// ------------------------------------------------------------
// Services
// ------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 600 && width < 1000;

    return Column(
      children: [
        Icon(
          icon,
          size: isDesktop
              ? 27
              : isTablet
              ? 24
              : 22,
          color: AppColors.orders_page_redi,
        ),

        const SizedBox(height: 8),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 12 : 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 10 : 9,
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
      height: 42,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ------------------------------------------------------------
// Contact Section
// ------------------------------------------------------------

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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

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
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF252525),
          ),
        ),

        const SizedBox(height: 14),

        if (hasAddress)
          _ContactItem(
            icon: Iconsax.location_copy,
            title: 'آدرس',
            value: cleanAddress!,
            onTap: null,
          ),

        if (hasAddress && (hasPhone || hasEmail || hasWebsite))
          const SizedBox(height: 10),

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
          const SizedBox(height: 10),

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
          const SizedBox(height: 10),

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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Icon(
                  icon,
                  size: isDesktop ? 21 : 19,
                  color: AppColors.orders_page_redi,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 10,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 11,
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 11,
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

// ------------------------------------------------------------
// Quick Links & Social Networks
// ------------------------------------------------------------

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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

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
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دسترسی سریع',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF252525),
                ),
              ),

              const SizedBox(height: 10),

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

        if (hasInstagram || hasTelegram) ...[
          SizedBox(width: isDesktop ? 24 : 12),

          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شبکه‌های اجتماعی',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF252525),
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
          ),
        ],
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 12 : 11,
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

    final size = isDesktop ? 44.0 : 40.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            size: isDesktop ? 21 : 19,
            color: AppColors.orders_page_redi,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Divider
// ------------------------------------------------------------

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

// ------------------------------------------------------------
// Copyright
// ------------------------------------------------------------

class _Copyright extends StatelessWidget {
  const _Copyright({
    required this.storeName,
  });

  final String storeName;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;

    return Center(
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} $storeName',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'تمامی حقوق محفوظ است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 11 : 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
