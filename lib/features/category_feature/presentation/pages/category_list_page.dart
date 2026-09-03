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
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

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
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryProvider>(
      create: (_) => getIt<CategoryProvider>()..loadCategories(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16.w,
            title: Text(
              'دسته‌بندی‌ها',
              style: AppTextStyles.second_title_section.copyWith(
                color: AppColors.home_header_background,
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

              final categories = _filterCategories(
                provider.categories,
              );

              if (categories.isEmpty) {
                return const _EmptySearch();
              }

              if (_selectedCategoryIndex >= categories.length) {
                _selectedCategoryIndex = 0;
              }

              final selectedCategory =
              categories[_selectedCategoryIndex];

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14.w,
                      4.h,
                      14.w,
                      12.h,
                    ),
                    child: _SearchBox(
                      controller: _searchController,
                      searchQuery: _searchQuery,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _selectedCategoryIndex = 0;
                        });
                      },
                      onClear: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                          _selectedCategoryIndex = 0;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // ==============================
                        // RIGHT SIDE - CATEGORIES
                        // ==============================

                        SizedBox(
                          width: 112.w,
                          child: _CategorySideBar(
                            categories: categories,
                            selectedIndex:
                            _selectedCategoryIndex,
                            onSelected: (index) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                          ),
                        ),

                        // ==============================
                        // LEFT SIDE - CONTENT
                        // ==============================

                        Expanded(
                          child: _CategoryContent(
                            category: selectedCategory,
                            onTap: () {
                              context.pushNamed(
                                'category',
                                extra: selectedCategory,
                              );
                            },
                          ),
                        ),
                      ],
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

// ============================================================
// SEARCH BOX
// ============================================================

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'جستجو در دسته‌بندی‌ها',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 25.sp,
            color: Colors.grey.shade700,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            onPressed: onClear,
            icon: Icon(
              Icons.close_rounded,
              size: 20.sp,
            ),
          )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 15.h,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RIGHT CATEGORY SIDEBAR
// ============================================================

class _CategorySideBar extends StatelessWidget {
  final List<CategoryEntity> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategorySideBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (
            context,
            index,
            ) {
          final category = categories[index];

          final bool isSelected =
              index == selectedIndex;

          return _SideCategoryItem(
            category: category,
            isSelected: isSelected,
            onTap: () {
              onSelected(index);
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// SIDE CATEGORY ITEM
// ============================================================

class _SideCategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideCategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 88.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : const Color(0xFFF8F8F8),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
              ),
              right: isSelected
                  ? BorderSide(
                color: AppColors.primary,
                width: 3.w,
              )
                  : BorderSide.none,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              // IMAGE
              SizedBox(
                width: 38.w,
                height: 38.w,
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (
                      context,
                      url,
                      ) {
                    return Icon(
                      Icons.category_outlined,
                      size: 28.sp,
                      color: Colors.grey.shade400,
                    );
                  },
                  errorWidget: (
                      context,
                      url,
                      error,
                      ) {
                    return Icon(
                      Icons.category_outlined,
                      size: 28.sp,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade500,
                    );
                  },
                ),
              ),

              SizedBox(height: 7.h),

              // NAME
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.5,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN CATEGORY CONTENT
// ============================================================

class _CategoryContent extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const _CategoryContent({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14.w,
        14.h,
        14.w,
        40.h,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'همه محصولات ${category.name}',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),

              SizedBox(width: 5.w),

              Icon(
                Icons.chevron_left_rounded,
                size: 25.sp,
                color: AppColors.primary,
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),

          // ITEMS

          _CategoryExpansionItem(
            title: 'انتخاب ${category.name}',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'محصولات ${category.name}',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'پرفروش‌ترین‌های ${category.name}',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'برندهای مختلف ${category.name}',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'برندهای برتر',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'محصولات براساس قیمت',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'محصولات براساس محبوبیت',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'محصولات جدید',
            onTap: onTap,
          ),

          _CategoryExpansionItem(
            title: 'محصولات ویژه',
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EXPANSION ITEM
// ============================================================

class _CategoryExpansionItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryExpansionItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 66.h,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // TEXT - RIGHT
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // ARROW - LEFT
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 27.sp,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            14.w,
            8.h,
            14.w,
            12.h,
          ),
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius:
              BorderRadius.circular(28.r),
            ),
          ),
        ),

        Expanded(
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 112.w,
                color: const Color(0xFFF8F8F8),
              ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 8,
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFF5F5F5),
                          borderRadius:
                          BorderRadius.circular(8.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ERROR
// ============================================================

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
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 50.sp,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: 14.h),

            Text(
              'دریافت دسته‌بندی‌ها ناموفق بود',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
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

// ============================================================
// EMPTY SEARCH
// ============================================================

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 50.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 12.h),

          Text(
            'دسته‌بندی موردنظر پیدا نشد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            'عبارت دیگری را جستجو کنید',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}