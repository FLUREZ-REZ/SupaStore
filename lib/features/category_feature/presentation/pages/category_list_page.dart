import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/presentation/providers/category_provider.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({
    super.key,
  });

  @override
  State<CategoryListPage> createState() =>
      _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryEntity> _filterCategories(
      List<CategoryEntity> categories,
      ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.name
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryProvider>(
      create: (_) => getIt<CategoryProvider>()
        ..loadCategories(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,

            title: Text(
              'دسته‌بندی‌ها',
              style: AppTextStyles.second_title_section
                  .copyWith(
                color: AppColors.black,
              ),
            ),
          ),

          body: Consumer<CategoryProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
              if (provider.isLoading) {
                return const _CategoryLoading();
              }

              if (provider.error != null) {
                return _CategoryError(
                  message: provider.error!,
                  onRetry: () {
                    provider.loadCategories();
                  },
                );
              }

              final categories =
              _filterCategories(
                provider.categories,
              );

              return Column(
                children: [

                  /// Search
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      8.h,
                      16.w,
                      18.h,
                    ),
                    child: TextField(
                      controller: _searchController,

                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },

                      decoration: InputDecoration(
                        hintText:
                        'جستجوی دسته‌بندی...',

                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22.sp,
                          color: Colors.grey.shade600,
                        ),

                        suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

                            setState(() {
                              _searchQuery =
                              '';
                            });
                          },
                          icon: Icon(
                            Icons
                                .close_rounded,
                            size: 20.sp,
                          ),
                        )
                            : null,

                        filled: true,
                        fillColor:
                        const Color(0xFFF6F6F6),

                        contentPadding:
                        EdgeInsets.symmetric(
                          vertical: 13.h,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color:
                            AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Categories
                  Expanded(
                    child: categories.isEmpty
                        ? const _EmptySearch()
                        : GridView.builder(
                      padding:
                      EdgeInsets.fromLTRB(
                        16.w,
                        0,
                        16.w,
                        30.h,
                      ),

                      physics:
                      const BouncingScrollPhysics(),

                      itemCount:
                      categories.length,

                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 18.w,
                        mainAxisSpacing: 24.h,
                        childAspectRatio: 0.78,
                      ),

                      itemBuilder:
                          (context, index) {
                        final category =
                        categories[index];

                        return _CategoryItem(
                          category: category,
                          onTap: () {
                            context.pushNamed(
                              'category',
                              extra: category,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


/// =======================================================
/// Category Item
/// =======================================================

class _CategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16.r),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          /// Image
          Container(
            width: 82.w,
            height: 82.w,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6F6F6),
            ),

            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                category.imageUrl,

                fit: BoxFit.contain,

                placeholder:
                    (context, url) {
                  return Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },

                errorWidget:
                    (context, url, error) {
                  return Icon(
                    Icons
                        .image_not_supported_outlined,
                    size: 30.sp,
                    color:
                    Colors.grey.shade400,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// Name
          Text(
            category.name,

            maxLines: 2,

            overflow:
            TextOverflow.ellipsis,

            textAlign:
            TextAlign.center,

            style:
            AppTextStyles.category.copyWith(
              color: AppColors.black,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


/// =======================================================
/// Loading
/// =======================================================

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        30.h,
      ),

      itemCount: 9,

      physics:
      const NeverScrollableScrollPhysics(),

      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 18.w,
        mainAxisSpacing: 24.h,
        childAspectRatio: 0.78,
      ),

      itemBuilder: (_, index) {
        return Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              width: 82.w,
              height: 82.w,

              decoration:
              const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF6F6F6),
              ),
            ),

            SizedBox(height: 10.h),

            Container(
              width: 55.w,
              height: 12.h,

              decoration:
              BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius:
                BorderRadius.circular(6.r),
              ),
            ),
          ],
        );
      },
    );
  }
}


/// =======================================================
/// Error
/// =======================================================

class _CategoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CategoryError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.all(24.w),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [

            Icon(
              Icons.cloud_off_rounded,
              size: 50.sp,
              color:
              Colors.grey.shade400,
            ),

            SizedBox(height: 14.h),

            Text(
              'دریافت دسته‌بندی‌ها ناموفق بود',
              textAlign:
              TextAlign.center,

              style: TextStyle(
                fontSize: 15.sp,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              message,
              textAlign:
              TextAlign.center,

              maxLines: 3,

              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 12.sp,
                color:
                Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 18.h),

            ElevatedButton.icon(
              onPressed: onRetry,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// =======================================================
/// Empty Search
/// =======================================================

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Icon(
            Icons.search_off_rounded,
            size: 50.sp,
            color:
            Colors.grey.shade400,
          ),

          SizedBox(height: 12.h),

          Text(
            'دسته‌بندی موردنظر پیدا نشد',

            style: TextStyle(
              fontSize: 14.sp,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            'عبارت دیگری را جستجو کنید',

            style: TextStyle(
              fontSize: 12.sp,
              color:
              Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}