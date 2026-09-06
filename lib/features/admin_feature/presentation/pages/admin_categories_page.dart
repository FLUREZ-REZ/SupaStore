import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/admin_feature/category/data/datasources/admin_category_remote_datasource.dart';
import 'package:supastore/features/admin_feature/category/domain/entities/admin_category.dart';
import 'package:supastore/features/admin_feature/category/presentation/pages/admin_category_form_page.dart';
import 'package:supastore/features/admin_feature/category/presentation/providers/admin_category_provider.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  static const Color _primaryRed = Color(0xFFE21B23);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AdminCategoryProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll / Pagination
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      final provider = context.read<AdminCategoryProvider>();

      if (!provider.isLoading &&
          !provider.isLoadingMore &&
          provider.hasMore) {
        provider.loadCategories();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void _onSearchChanged(String value) {
    if (mounted) {
      setState(() {});
    }

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) return;

        context.read<AdminCategoryProvider>().loadCategories(
          search: value,
        );
      },
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {});

    context.read<AdminCategoryProvider>().loadCategories(
      search: '',
    );
  }

  // ---------------------------------------------------------------------------
  // Add / Edit
  // ---------------------------------------------------------------------------

  Future<void> _openAddCategory() async {
    final provider = context.read<AdminCategoryProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const AdminCategoryFormPage(),
        ),
      ),
    );
  }

  Future<void> _openEditCategory(
      AdminCategory category,
      ) async {
    final provider = context.read<AdminCategoryProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AdminCategoryFormPage(
            category: category,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _deleteCategory(
      AdminCategory category,
      ) async {
    final confirmed = await _showDeleteConfirmationDialog(
      category,
    );

    if (confirmed != true) return;

    final provider = context.read<AdminCategoryProvider>();

    try {
      await provider.deleteCategory(
        categoryId: category.id,
      );

      if (!mounted) return;

      _showSuccessSnackBar(
        'دسته‌بندی با موفقیت حذف شد.',
      );
    } catch (e) {
      if (!mounted) return;

      final message = _extractErrorMessage(e);

      await _showDeleteErrorDialog(
        message,
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(
      AdminCategory category,
      ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            icon: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: _primaryRed,
                size: 32.sp,
              ),
            ),
            title: Text(
              'حذف دسته‌بندی',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),
            content: Text(
              'آیا از حذف دسته‌بندی «${category.name}» مطمئن هستید؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.8,
                color: const Color(0xFF555555),
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              16.w,
              0,
              16.w,
              16.h,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryRed,
                        side: const BorderSide(
                          color: _primaryRed,
                        ),
                        minimumSize: Size(
                          double.infinity,
                          46.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'انصراف',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryRed,
                        foregroundColor: Colors.white,
                        minimumSize: Size(
                          double.infinity,
                          46.h,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'حذف',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteErrorDialog(
      String message,
      ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            icon: Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: _primaryRed,
                size: 36.sp,
              ),
            ),
            title: Text(
              'امکان حذف وجود ندارد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _primaryRed,
              ),
            ),
            content: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _primaryRed.withOpacity(0.15),
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.9,
                  color: const Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              16.w,
              0,
              16.w,
              16.h,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryRed,
                    foregroundColor: Colors.white,
                    minimumSize: Size(
                      double.infinity,
                      48.h,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'متوجه شدم',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _extractErrorMessage(
      Object error,
      ) {
    if (error is CategoryHasProductsException) {
      return error.message;
    }

    final rawMessage = error.toString();

    final message = rawMessage.replaceFirst(
      'Exception: ',
      '',
    );

    if (message.trim().isEmpty) {
      return 'خطایی هنگام حذف دسته‌بندی رخ داد.';
    }

    return message;
  }

  // ---------------------------------------------------------------------------
  // SnackBar
  // ---------------------------------------------------------------------------

  void _showSuccessSnackBar(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> _refresh() async {
    await context.read<AdminCategoryProvider>().loadCategories(
      refresh: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Image URL
  // ---------------------------------------------------------------------------

  String? _getImageUrl(
      String? imagePath,
      ) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final path = imagePath.trim();

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    return Supabase.instance.client.storage
        .from('assets')
        .getPublicUrl(path);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Consumer<AdminCategoryProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            if (provider.isLoading &&
                provider.categories.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primaryRed,
                ),
              );
            }

            if (provider.error != null &&
                provider.categories.isEmpty) {
              return _ErrorState(
                message: _extractErrorMessage(
                  Exception(provider.error),
                ),
                onRetry: () {
                  provider.loadCategories(
                    refresh: true,
                  );
                },
              );
            }

            if (provider.categories.isEmpty) {
              return _buildEmptyState(
                provider,
              );
            }

            return RefreshIndicator(
              color: _primaryRed,
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        16.h,
                        16.w,
                        8.h,
                      ),
                      child: _buildSearchAndAddRow(),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      8.h,
                      16.w,
                      100.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (
                            context,
                            index,
                            ) {
                          if (index >=
                              provider.categories.length) {
                            return _buildLoadingMore(
                              provider,
                            );
                          }

                          final category =
                          provider.categories[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 10.h,
                            ),
                            child: _CategoryCard(
                              category: category,
                              imageUrl: _getImageUrl(
                                category.imageUrl,
                              ),
                              onEdit: () {
                                _openEditCategory(
                                  category,
                                );
                              },
                              onDelete: () {
                                _deleteCategory(
                                  category,
                                );
                              },
                            ),
                          );
                        },
                        childCount: provider.categories.length +
                            (provider.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search + Add Button
  // ---------------------------------------------------------------------------

  Widget _buildSearchAndAddRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAddCategoryButton(),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSearchField(),
        ),
      ],
    );
  }

  Widget _buildAddCategoryButton() {
    return SizedBox(
      height: 52.h,
      child: FilledButton.icon(
        onPressed: _openAddCategory,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'دسته‌بندی جدید',
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Field
  // ---------------------------------------------------------------------------

  Widget _buildSearchField() {
    return SizedBox(
      height: 52.h,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'جستجوی',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.black45,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: _clearSearch,
            icon: const Icon(
              Icons.clear_rounded,
            ),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(
              color: _primaryRed,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(
      AdminCategoryProvider provider,
      ) {
    final hasSearch =
        _searchController.text.trim().isNotEmpty;

    return RefreshIndicator(
      color: _primaryRed,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24.w,
          24.h,
          24.w,
          100.h,
        ),
        children: [
          _buildSearchAndAddRow(),
          SizedBox(height: 70.h),
          _EmptyState(
            hasSearch: hasSearch,
            onAdd: _openAddCategory,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading More
  // ---------------------------------------------------------------------------

  Widget _buildLoadingMore(
      AdminCategoryProvider provider,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: _primaryRed,
        ),
      ),
    );
  }
}

// =============================================================================
// Category Card
// =============================================================================

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _primaryRed = Color(0xFFE21B23);

  final AdminCategory category;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // -------------------------------------------------------------------
          // Image
          // -------------------------------------------------------------------

          _CategoryImage(
            imageUrl: imageUrl,
          ),

          SizedBox(width: 14.w),

          // -------------------------------------------------------------------
          // Info
          // -------------------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),

                SizedBox(height: 6.h),

                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    category.slug,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: 9.h),

                Wrap(
                  spacing: 6.w,
                  runSpacing: 5.h,
                  children: [
                    _CategoryBadge(
                      icon: Icons.sort_rounded,
                      text:
                      'ترتیب ${category.sortOrder}',
                    ),
                    _CategoryBadge(
                      icon: category.isActive
                          ? Icons.check_circle_outline_rounded
                          : Icons.block_rounded,
                      text: category.isActive
                          ? 'فعال'
                          : 'غیرفعال',
                      color: category.isActive
                          ? Colors.green
                          : _primaryRed,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // -------------------------------------------------------------------
          // Actions
          // -------------------------------------------------------------------

          Column(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'ویرایش',
                onPressed: onEdit,
              ),
              SizedBox(height: 7.h),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'حذف',
                color: _primaryRed,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Category Image
// =============================================================================

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82.w,
      height: 82.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _buildPlaceholder()
          : CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 250,
        memCacheHeight: 250,
        placeholder: (
            context,
            url,
            ) {
          return _buildLoading();
        },
        errorWidget: (
            context,
            url,
            error,
            ) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFE21B23),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.category_outlined,
        color: Colors.black26,
        size: 32,
      ),
    );
  }
}

// =============================================================================
// Action Button
// =============================================================================

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        color ?? const Color(0xFF555555);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: buttonColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 38.w,
            height: 38.w,
            child: Icon(
              icon,
              size: 20.sp,
              color: buttonColor,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Category Badge
// =============================================================================

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        color ?? const Color(0xFF777777);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: badgeColor,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearch,
    required this.onAdd,
  });

  static const Color _primaryRed = Color(0xFFE21B23);

  final bool hasSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: _primaryRed.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasSearch
                ? Icons.search_off_rounded
                : Icons.category_outlined,
            size: 48.sp,
            color: _primaryRed,
          ),
        ),

        SizedBox(height: 20.h),

        Text(
          hasSearch
              ? 'دسته‌بندی‌ای پیدا نشد'
              : 'هنوز دسته‌بندی‌ای ثبت نشده است',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF222222),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          hasSearch
              ? 'عبارت جستجو را تغییر دهید.'
              : 'اولین دسته‌بندی فروشگاه خود را ایجاد کنید.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black45,
            height: 1.7,
          ),
        ),

        if (!hasSearch) ...[
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'ایجاد دسته‌بندی',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Error State
// =============================================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  static const Color _primaryRed = Color(0xFFE21B23);

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: _primaryRed,
                size: 42.sp,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              'خطایی رخ داد',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black54,
                height: 1.8,
              ),
            ),

            SizedBox(height: 20.h),

            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'تلاش مجدد',
              ),
            ),
          ],
        ),
      ),
    );
  }
}