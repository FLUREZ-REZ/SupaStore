import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';

import '../../domain/entities/admin_banner_entity.dart';
import '../providers/admin_banner_provider.dart';
import 'admin_banner_form_page.dart';

class AdminBannersPage extends StatelessWidget {
  const AdminBannersPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminBannerProvider>(
      create: (_) => getIt<AdminBannerProvider>()..loadBanners(),
      child: const _AdminBannersView(),
    );
  }
}

class _AdminBannersView extends StatefulWidget {
  const _AdminBannersView();

  @override
  State<_AdminBannersView> createState() =>
      _AdminBannersViewState();
}

class _AdminBannersViewState extends State<_AdminBannersView> {
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({
    AdminBannerEntity? banner,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminBannerFormPage(
          banner: banner,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await context
          .read<AdminBannerProvider>()
          .loadBanners();
    }
  }

  Future<void> _deleteBanner(
      AdminBannerEntity banner,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'حذف بنر',
          ),
          content: Text(
            'آیا از حذف بنر «${banner.title}» مطمئن هستید؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'انصراف',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'حذف',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider = context.read<AdminBannerProvider>();

    final success = await provider.deleteBanner(
      banner: banner,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      _showMessage(
        provider.errorMessage ??
            'حذف بنر انجام نشد.',
      );
      return;
    }

    _showMessage(
      'بنر با موفقیت حذف شد.',
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Consumer<AdminBannerProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return RefreshIndicator(
            color: const Color(0xFF03045e),
            onRefresh: provider.loadBanners,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                30.h,
              ),
              children: [
                // ==================================================
                // SEARCH + ADD
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textDirection: TextDirection.rtl,
                        onSubmitted: (_) async {
                          provider.setSearch(
                            _searchController.text,
                          );

                          await provider.loadBanners();
                        },
                        decoration: InputDecoration(
                          hintText: 'جستجوی بنر...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14.r,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    SizedBox(
                      height: 52.h,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF03045e),
                          padding:
                          EdgeInsets.symmetric(
                            horizontal: 14.w,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14.r,
                            ),
                          ),
                        ),
                        onPressed: provider.isSaving
                            ? null
                            : () => _openForm(),
                        child: const Icon(
                          Icons.add_rounded,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // FILTER
                // ==================================================

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        title: 'همه',
                        selected:
                        provider.selectedType ==
                            'all',
                        onTap: () async {
                          provider.setBannerType(
                            'all',
                          );

                          await provider.loadBanners();
                        },
                      ),
                      _FilterChip(
                        title: 'هیرو',
                        selected:
                        provider.selectedType ==
                            'hero',
                        onTap: () async {
                          provider.setBannerType(
                            'hero',
                          );

                          await provider.loadBanners();
                        },
                      ),
                      _FilterChip(
                        title: 'تبلیغاتی',
                        selected:
                        provider.selectedType ==
                            'promotional',
                        onTap: () async {
                          provider.setBannerType(
                            'promotional',
                          );

                          await provider.loadBanners();
                        },
                      ),
                      _FilterChip(
                        title: 'پایین صفحه',
                        selected:
                        provider.selectedType ==
                            'bottom_home',
                        onTap: () async {
                          provider.setBannerType(
                            'bottom_home',
                          );

                          await provider.loadBanners();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 18.h,
                ),

                // ==================================================
                // LOADING
                // ==================================================

                if (provider.isLoading)
                  SizedBox(
                    height: 250.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF03045e),
                      ),
                    ),
                  )

                // ==================================================
                // ERROR
                // ==================================================

                else if (provider.errorMessage != null &&
                    provider.banners.isEmpty)
                  SizedBox(
                    height: 250.h,
                    child: Center(
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )

                // ==================================================
                // EMPTY
                // ==================================================

                else if (provider.banners.isEmpty)
                    SizedBox(
                      height: 250.h,
                      child: const Center(
                        child: Text(
                          'بنری پیدا نشد.',
                        ),
                      ),
                    )

                  // ==================================================
                  // LIST
                  // ==================================================

                  else
                    ...provider.banners.map(
                          (banner) => _BannerCard(
                        banner: banner,
                        onEdit: () => _openForm(
                          banner: banner,
                        ),
                        onDelete: () => _deleteBanner(
                          banner,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// FILTER CHIP
// ================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding: EdgeInsets.only(
        left: 8.w,
      ),
      child: ChoiceChip(
        label: Text(
          title,
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(
          0xFFcaf0f8,
        ),
      ),
    );
  }
}

// ================================================================
// BANNER CARD
// ================================================================

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminBannerEntity banner;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 14,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          12.w,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                14.r,
              ),
              child: CachedNetworkImage(
                imageUrl:
                '${banner.imageUrl}?v=${banner.updatedAt.millisecondsSinceEpoch}',
                width: double.infinity,
                height: 170.h,
                fit: BoxFit.cover,
                placeholder: (
                    context,
                    url,
                    ) {
                  return Container(
                    color: Colors.grey.shade200,
                  );
                },
                errorWidget: (
                    context,
                    url,
                    error,
                    ) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              height: 12.h,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    banner.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFcaf0f8,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      8.r,
                    ),
                  ),
                  child: Text(
                    banner.bannerTypeTitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(
                        0xFF03045e,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if (banner.description != null &&
                banner.description!
                    .trim()
                    .isNotEmpty) ...[
              SizedBox(
                height: 6.h,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  banner.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],

            SizedBox(
              height: 8.h,
            ),

            Row(
              children: [
                Text(
                  'ترتیب: ${banner.sortOrder}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                if (banner.hasAction)
                  Text(
                    'عملکرد: ${banner.actionTypeTitle}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),

            SizedBox(
              height: 8.h,
            ),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'ویرایش',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'حذف',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}