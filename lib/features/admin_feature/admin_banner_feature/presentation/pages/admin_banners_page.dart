import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
  State<_AdminBannersView> createState() => _AdminBannersViewState();
}

class _AdminBannersViewState extends State<_AdminBannersView> {
  static const Color _primary = Color(0xFF03045E);
  static const Color _secondary = Color(0xFF023E8A);
  static const Color _background = Color(0xFFF7F7F8);
  static const Color _lightBlue = Color(0xFFCAF0F8);
  static const Color _red = Color(0xFFE21B23);

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Add / Edit
  // ---------------------------------------------------------------------------

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

    if (!mounted) return;

    if (result == true) {
      await context.read<AdminBannerProvider>().loadBanners();
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _deleteBanner(
      AdminBannerEntity banner,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.trash_copy,
                color: _red,
                size: 27,
              ),
            ),
            title: const Text(
              'حذف بنر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'آیا از حذف بنر «${banner.title}» مطمئن هستید؟',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.8,
                color: Colors.black54,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
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
                        foregroundColor: _primary,
                        minimumSize: const Size(
                          double.infinity,
                          44,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                          double.infinity,
                          44,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text(
                        'حذف',
                        style: TextStyle(
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

    if (confirmed != true || !mounted) return;

    final provider = context.read<AdminBannerProvider>();

    final success = await provider.deleteBanner(
      banner: banner,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(
        provider.errorMessage ?? 'حذف بنر انجام نشد.',
        isError: true,
      );
      return;
    }

    _showMessage('بنر با موفقیت حذف شد.');
  }

  // ---------------------------------------------------------------------------
  // Message
  // ---------------------------------------------------------------------------

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? _red : _primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  Future<void> _searchBanners(
      AdminBannerProvider provider,
      ) async {
    provider.setSearch(_searchController.text);
    await provider.loadBanners();
  }

  // ---------------------------------------------------------------------------
  // Filter
  // ---------------------------------------------------------------------------

  Future<void> _changeFilter(
      AdminBannerProvider provider,
      String type,
      ) async {
    provider.setBannerType(type);
    await provider.loadBanners();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: Consumer<AdminBannerProvider>(
          builder: (context, provider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final isMobile = width < 600;
                final isTablet = width >= 600 && width < 1100;
                final isDesktop = width >= 1100;

                final horizontalPadding = isDesktop
                    ? 28.0
                    : isTablet
                    ? 22.0
                    : 16.0;

                final crossAxisCount = isMobile
                    ? 1
                    : isTablet
                    ? 2
                    : 3;

                final cardHeight = isMobile
                    ? 350.0
                    : isTablet
                    ? 335.0
                    : 330.0;

                return RefreshIndicator(
                  color: _primary,
                  onRefresh: provider.loadBanners,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1600,
                      ),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // -------------------------------------------------
                          // SEARCH
                          // -------------------------------------------------

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                20,
                                horizontalPadding,
                                12,
                              ),
                              child: _buildSearchSection(
                                provider,
                                isMobile: isMobile,
                              ),
                            ),
                          ),

                          // -------------------------------------------------
                          // FILTERS
                          // -------------------------------------------------

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: _buildFilters(provider),
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 18),
                          ),

                          // -------------------------------------------------
                          // LOADING
                          // -------------------------------------------------

                          if (provider.isLoading)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 280,
                                child: _LoadingState(
                                  color: _primary,
                                ),
                              ),
                            )

                          // -------------------------------------------------
                          // ERROR
                          // -------------------------------------------------

                          else if (provider.errorMessage != null &&
                              provider.banners.isEmpty)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 280,
                                child: _ErrorState(
                                  message: provider.errorMessage!,
                                  onRetry: provider.loadBanners,
                                ),
                              ),
                            )

                          // -------------------------------------------------
                          // EMPTY
                          // -------------------------------------------------

                          else if (provider.banners.isEmpty)
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 280,
                                  child: _EmptyState(
                                    onAdd: provider.isSaving
                                        ? null
                                        : () => _openForm(),
                                  ),
                                ),
                              )

                            // -------------------------------------------------
                            // BANNERS GRID
                            // -------------------------------------------------

                            else
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  40,
                                ),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      final banner =
                                      provider.banners[index];

                                      return _BannerCard(
                                        banner: banner,
                                        onEdit: () => _openForm(
                                          banner: banner,
                                        ),
                                        onDelete: () => _deleteBanner(
                                          banner,
                                        ),
                                      );
                                    },
                                    childCount: provider.banners.length,
                                  ),
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: cardHeight,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Section
  // ---------------------------------------------------------------------------

  Widget _buildSearchSection(
      AdminBannerProvider provider, {
        required bool isMobile,
      }) {
    final searchField = SizedBox(
      height: 50,
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchBanners(provider),
        style: const TextStyle(
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'جستجوی بنر...',
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
            onPressed: () {
              _searchController.clear();
              _searchBanners(provider);
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 19,
            ),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: _primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );

    final addButton = SizedBox(
      height: 50,
      child: FilledButton.icon(
        onPressed: provider.isSaving
            ? null
            : () => _openForm(),
        icon: const Icon(
          Icons.add_rounded,
          size: 21,
        ),
        label: const Text(
          'افزودن بنر',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.4),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          addButton,
          const SizedBox(height: 10),
          searchField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: searchField,
        ),
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  Widget _buildFilters(AdminBannerProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            title: 'همه',
            selected: provider.selectedType == 'all',
            onTap: () => _changeFilter(provider, 'all'),
          ),
          _FilterChip(
            title: 'هیرو',
            selected: provider.selectedType == 'hero',
            onTap: () => _changeFilter(provider, 'hero'),
          ),
          _FilterChip(
            title: 'تبلیغاتی',
            selected: provider.selectedType == 'promotional',
            onTap: () => _changeFilter(provider, 'promotional'),
          ),
          _FilterChip(
            title: 'پایین صفحه',
            selected: provider.selectedType == 'bottom_home',
            onTap: () => _changeFilter(provider, 'bottom_home'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FILTER CHIP
// =============================================================================

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w500,
            color: selected
                ? const Color(0xFF03045E)
                : const Color(0xFF555555),
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFCAF0F8),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? const Color(0xFF90DCEB)
              : const Color(0xFFEAEAEA),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
      ),
    );
  }
}

// =============================================================================
// BANNER CARD
// =============================================================================

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _primary = Color(0xFF03045E);
  static const Color _lightBlue = Color(0xFFCAF0F8);
  static const Color _red = Color(0xFFE21B23);

  final AdminBannerEntity banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isCompact = width < 300;

        final imageHeight = width < 350
            ? 145.0
            : width < 430
            ? 155.0
            : 145.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFEDEEF0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------------------------------------------------
                // IMAGE
                // ---------------------------------------------------------

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                    '${banner.imageUrl}?v=${banner.updatedAt.millisecondsSinceEpoch}',
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return Container(
                        height: imageHeight,
                        color: const Color(0xFFF0F1F3),
                        child: const Center(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        height: imageHeight,
                        color: const Color(0xFFF0F1F3),
                        child: const Center(
                          child: Icon(
                            Iconsax.image_copy,
                            color: Colors.black26,
                            size: 34,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 11),

                // ---------------------------------------------------------
                // TITLE + TYPE
                // ---------------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.36,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        banner.bannerTypeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------------------------------------------------------
                // DESCRIPTION
                // ---------------------------------------------------------

                if (banner.description != null &&
                    banner.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      banner.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // ---------------------------------------------------------
                // DETAILS
                // ---------------------------------------------------------

                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    _BannerInfo(
                      icon: Icons.sort_rounded,
                      text: 'ترتیب: ${banner.sortOrder}',
                    ),
                    if (banner.hasAction)
                      _BannerInfo(
                        icon: Icons.touch_app_outlined,
                        text: banner.actionTypeTitle,
                      ),
                  ],
                ),

                const Spacer(),

                const Divider(
                  height: 16,
                  color: Color(0xFFF0F0F0),
                ),

                // ---------------------------------------------------------
                // ACTIONS
                // ---------------------------------------------------------

                Row(
                  children: [
                    const Spacer(),
                    _BannerActionButton(
                      icon: Icons.edit_outlined,
                      label: 'ویرایش',
                      color: _primary,
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _BannerActionButton(
                      icon: Iconsax.trash_copy,
                      label: 'حذف',
                      color: _red,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// BANNER INFO
// =============================================================================

class _BannerInfo extends StatelessWidget {
  const _BannerInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.black45,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// BANNER ACTION BUTTON
// =============================================================================

class _BannerActionButton extends StatelessWidget {
  const _BannerActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LOADING STATE
// =============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: color,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'در حال دریافت بنرها...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
  });

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFF03045E).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.image_copy,
                size: 40,
                color: Color(0xFF03045E),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'بنری پیدا نشد.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'برای نمایش بنر در فروشگاه، اولین بنر خود را ایجاد کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('افزودن بنر'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF03045E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFFE21B23).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.warning_2_copy,
                  color: Color(0xFFE21B23),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'خطا در دریافت بنرها',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش مجدد'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}