import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
    setState(() {});

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

  Future<void> _openEditCategory(AdminCategory category) async {
    final provider = context.read<AdminCategoryProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AdminCategoryFormPage(category: category),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _deleteCategory(AdminCategory category) async {
    final confirmed = await _showDeleteConfirmationDialog(category);

    if (confirmed != true || !mounted) return;

    final provider = context.read<AdminCategoryProvider>();

    try {
      await provider.deleteCategory(categoryId: category.id);

      if (!mounted) return;

      _showSuccessSnackBar('دسته‌بندی با موفقیت حذف شد.');
    } catch (e) {
      if (!mounted) return;

      await _showDeleteErrorDialog(_extractErrorMessage(e));
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
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.trash_copy,
                color: _primaryRed,
                size: 32,
              ),
            ),
            title: const Text(
              'حذف دسته‌بندی',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            content: Text(
              'آیا از حذف دسته‌بندی «${category.name}» مطمئن هستید؟',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.8,
                color: Color(0xFF555555),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        side: const BorderSide(color: _primaryRed),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryRed,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'حذف',
                        style: TextStyle(
                          fontSize: 13,
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

  Future<void> _showDeleteErrorDialog(String message) async {
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
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2_copy,
                color: _primaryRed,
                size: 36,
              ),
            ),
            title: const Text(
              'امکان حذف وجود ندارد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _primaryRed,
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryRed.withOpacity(0.15),
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.9,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'متوجه شدم',
                    style: TextStyle(
                      fontSize: 13,
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

  String _extractErrorMessage(Object error) {
    if (error is CategoryHasProductsException) {
      return error.message;
    }

    final message = error.toString().replaceFirst('Exception: ', '');

    if (message.trim().isEmpty) {
      return 'خطایی هنگام حذف دسته‌بندی رخ داد.';
    }

    return message;
  }

  // ---------------------------------------------------------------------------
  // SnackBar
  // ---------------------------------------------------------------------------

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _primaryRed,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final path = imagePath.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
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
          builder: (context, provider, child) {
            if (provider.isLoading && provider.categories.isEmpty) {
              return const _CategoriesShimmer();
            }

            if (provider.error != null && provider.categories.isEmpty) {
              return _ErrorState(
                message: _extractErrorMessage(
                  Exception(provider.error),
                ),
                onRetry: () {
                  provider.loadCategories(refresh: true);
                },
              );
            }

            if (provider.categories.isEmpty) {
              return _buildEmptyState(provider);
            }

            return RefreshIndicator(
              color: _primaryRed,
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1100;
                  final isTablet = width >= 700 && width < 1100;

                  final horizontalPadding = isDesktop ? 28.0 : 16.0;

                  final crossAxisCount = isDesktop
                      ? 2
                      : isTablet
                      ? 2
                      : 1;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1500,
                      ),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                20,
                                horizontalPadding,
                                10,
                              ),
                              child: _buildSearchAndAddRow(width),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              8,
                              horizontalPadding,
                              100,
                            ),
                            sliver: crossAxisCount == 1
                                ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  if (index >=
                                      provider.categories.length) {
                                    return _buildLoadingMore(provider);
                                  }

                                  final category =
                                  provider.categories[index];

                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 10),
                                    child: _CategoryCard(
                                      category: category,
                                      imageUrl:
                                      _getImageUrl(category.imageUrl),
                                      onEdit: () =>
                                          _openEditCategory(category),
                                      onDelete: () =>
                                          _deleteCategory(category),
                                    ),
                                  );
                                },
                                childCount:
                                provider.categories.length +
                                    (provider.isLoadingMore ? 1 : 0),
                              ),
                            )
                                : SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  if (index >=
                                      provider.categories.length) {
                                    return const _CategoryCardShimmer();
                                  }

                                  final category =
                                  provider.categories[index];

                                  return _CategoryCard(
                                    category: category,
                                    imageUrl:
                                    _getImageUrl(category.imageUrl),
                                    onEdit: () =>
                                        _openEditCategory(category),
                                    onDelete: () =>
                                        _deleteCategory(category),
                                  );
                                },
                                childCount:
                                provider.categories.length +
                                    (provider.isLoadingMore ? 1 : 0),
                              ),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 12,
                                mainAxisExtent: isDesktop ? 145 : 140,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  Widget _buildSearchAndAddRow(double screenWidth) {
    final isNarrow = screenWidth < 480;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddCategoryButton(),
          const SizedBox(height: 10),
          _buildSearchField(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAddCategoryButton(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSearchField(),
        ),
      ],
    );
  }

  Widget _buildAddCategoryButton() {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: _openAddCategory,
        icon: const Icon(
          Icons.add_rounded,
          size: 20,
        ),
        label: const Text(
          'دسته‌بندی جدید',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0096C7),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
      height: 48,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'جستجوی دسته‌بندی',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black45,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear_rounded),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyState(AdminCategoryProvider provider) {
    final hasSearch = _searchController.text.trim().isNotEmpty;

    return RefreshIndicator(
      color: _primaryRed,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return _buildSearchAndAddRow(constraints.maxWidth);
            },
          ),
          const SizedBox(height: 70),
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

  Widget _buildLoadingMore(AdminCategoryProvider provider) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: _CategoryCardShimmer(),
    );
  }
}

// =============================================================================
// Shimmer - Initial Loading
// =============================================================================

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isNarrow = width < 480;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: _ShimmerEffect(
                child: Column(
                  children: [
                    if (isNarrow)
                      Column(
                        children: [
                          const _SkeletonBox(
                            width: double.infinity,
                            height: 48,
                            radius: 12,
                          ),
                          const SizedBox(height: 10),
                          const _SkeletonBox(
                            width: double.infinity,
                            height: 48,
                            radius: 12,
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          _SkeletonBox(
                            width: 150,
                            height: 48,
                            radius: 12,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _SkeletonBox(
                              width: double.infinity,
                              height: 48,
                              radius: 12,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    if (width >= 700)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 145,
                        ),
                        itemBuilder: (context, index) {
                          return const _CategoryCardSkeleton();
                        },
                      )
                    else
                      const Column(
                        children: [
                          _CategoryCardSkeleton(),
                          SizedBox(height: 10),
                          _CategoryCardSkeleton(),
                          SizedBox(height: 10),
                          _CategoryCardSkeleton(),
                          SizedBox(height: 10),
                          _CategoryCardSkeleton(),
                          SizedBox(height: 10),
                          _CategoryCardSkeleton(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Shimmer - Pagination Loading
// =============================================================================

class _CategoryCardShimmer extends StatelessWidget {
  const _CategoryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerEffect(
      child: _CategoryCardSkeleton(),
    );
  }
}

// =============================================================================
// Shimmer Animation
// =============================================================================

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect({
    required this.child,
  });

  final Widget child;

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final position = -1.5 + (_controller.value * 3);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(position, 0),
              end: Alignment(position + 1.5, 0),
              colors: const [
                Color(0xFFEAEAEA),
                Color(0xFFF8F8F8),
                Color(0xFFEAEAEA),
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

// =============================================================================
// Skeleton Box
// =============================================================================

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// =============================================================================
// Category Card Skeleton
// =============================================================================

class _CategoryCardSkeleton extends StatelessWidget {
  const _CategoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          const _SkeletonBox(
            width: 76,
            height: 76,
            radius: 12,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 125,
                  height: 14,
                  radius: 5,
                ),
                SizedBox(height: 10),
                _SkeletonBox(
                  width: 95,
                  height: 10,
                  radius: 5,
                ),
                SizedBox(height: 13),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _SkeletonBox(
                      width: 72,
                      height: 23,
                      radius: 7,
                    ),
                    _SkeletonBox(
                      width: 58,
                      height: 23,
                      radius: 7,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            children: [
              _SkeletonBox(
                width: 36,
                height: 36,
                radius: 9,
              ),
              SizedBox(height: 7),
              _SkeletonBox(
                width: 36,
                height: 36,
                radius: 9,
              ),
            ],
          ),
        ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 350;

        final imageSize = isCompact ? 64.0 : 76.0;
        final titleSize = isCompact ? 13.0 : 14.0;

        return Container(
          padding: EdgeInsets.all(isCompact ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
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
              _CategoryImage(
                imageUrl: imageUrl,
                size: imageSize,
              ),
              SizedBox(width: isCompact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        category.slug,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _CategoryBadge(
                          icon: Icons.sort_rounded,
                          text: 'ترتیب ${category.sortOrder}',
                        ),
                        _CategoryBadge(
                          icon: category.isActive
                              ? Icons.check_circle_outline_rounded
                              : Icons.block_rounded,
                          text: category.isActive ? 'فعال' : 'غیرفعال',
                          color: category.isActive
                              ? Colors.green
                              : _primaryRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 7 : 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'ویرایش',
                    onPressed: onEdit,
                    compact: isCompact,
                  ),
                  const SizedBox(height: 7),
                  _ActionButton(
                    icon: Iconsax.trash_copy,
                    tooltip: 'حذف',
                    color: _primaryRed,
                    onPressed: onDelete,
                    compact: isCompact,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Category Image
// =============================================================================

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({
    required this.imageUrl,
    required this.size,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _buildPlaceholder()
          : CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 250,
        memCacheHeight: 250,
        placeholder: (context, url) => _buildLoading(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildLoading() {
    return const _ShimmerEffect(
      child: ColoredBox(
        color: Color(0xFFEAEAEA),
        child: SizedBox.expand(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Iconsax.category_copy,
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
    this.compact = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? const Color(0xFF555555);
    final size = compact ? 34.0 : 38.0;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: buttonColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: compact ? 18 : 20,
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
    final badgeColor = color ?? const Color(0xFF777777);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Empty State
// =============================================================================

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxWidth < 400 ? 85.0 : 100.0;

        return Column(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: _primaryRed.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Iconsax.category_copy,
                size: iconSize * 0.48,
                color: _primaryRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch
                  ? 'دسته‌بندی‌ای پیدا نشد'
                  : 'هنوز دسته‌بندی‌ای ثبت نشده است',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'عبارت جستجو را تغییر دهید.'
                  : 'اولین دسته‌بندی فروشگاه خود را ایجاد کنید.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black45,
                height: 1.7,
              ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('ایجاد دسته‌بندی'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        );
      },
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
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.warning_2_copy,
                  color: _primaryRed,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'خطایی رخ داد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}