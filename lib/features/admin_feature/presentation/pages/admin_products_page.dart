
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/admin_feature/presentation/pages/admin_product_form_page.dart';

import '../providers/admin_product_provider.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  Timer? _searchTimer;

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminProductProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // SEARCH
  // =====================================================

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) return;

        context.read<AdminProductProvider>().loadProducts(
          search: value,
        );
      },
    );
  }

  // =====================================================
  // OPEN PRODUCT FORM
  // =====================================================

  Future<void> _openForm({
    Map<String, dynamic>? product,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminProductProvider>(),
          child: AdminProductFormPage(
            product: product,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DELETE PRODUCT
  // =====================================================

  Future<void> _deleteProduct(
      Map<String, dynamic> product,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف محصول'),
          content: Text(
            'آیا از حذف «${product['title']}» مطمئن هستید؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<AdminProductProvider>().deleteProduct(
        productId: product['id'] as String,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('محصول با موفقیت حذف شد.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در حذف محصول: $e'),
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('محصول جدید'),
      ),

      body: Consumer<AdminProductProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final horizontalPadding = width < 600
                  ? 14.0
                  : width < 1000
                  ? 22.0
                  : 28.0;

              const maxContentWidth = 1150.0;

              return RefreshIndicator(
                onRefresh: () {
                  return provider.loadProducts(
                    refresh: true,
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // =====================================
                    // SEARCH
                    // =====================================

                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              20,
                              horizontalPadding,
                              18,
                            ),
                            child: _SearchField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // =====================================
                    // INITIAL LOADING
                    // =====================================

                    if (provider.isLoading &&
                        provider.products.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )

                    // =====================================
                    // EMPTY
                    // =====================================

                    else if (provider.products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyProducts(),
                      )

                    // =====================================
                    // PRODUCTS
                    // =====================================

                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          110,
                        ),
                        sliver: SliverList.builder(
                          itemCount: provider.products.length +
                              (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // -----------------------------
                            // LOAD MORE
                            // -----------------------------

                            if (index >= provider.products.length) {
                              if (!provider.isLoadingMore) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted) return;

                                  if (!provider.isLoadingMore &&
                                      provider.hasMore) {
                                    provider.loadMore();
                                  }
                                });
                              }

                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // -----------------------------
                            // PRODUCT
                            // -----------------------------

                            final product = provider.products[index];

                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: maxContentWidth,
                                ),
                                child: _ProductCard(
                                  product: product,
                                  onEdit: () {
                                    _openForm(
                                      product: product,
                                    );
                                  },
                                  onDelete: () {
                                    _deleteProduct(product);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// SEARCH FIELD
// =====================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'جستجوی محصول...',
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Colors.black45,
        ),
        suffixIcon: const Icon(
          Icons.search,
          color: Color(0xFF03045E),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEDEDED),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF03045E),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// EMPTY PRODUCTS
// =====================================================

class _EmptyProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.box_search_copy,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 14),
          const Text(
            'محصولی پیدا نشد.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PRODUCT CARD
// =====================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _primaryColor = Color(0xFF03045E);

  @override
  Widget build(BuildContext context) {
    final title = product['title'] as String? ?? 'بدون عنوان';

    final priceValue = product['price'];
    final price = priceValue is num ? priceValue.toInt() : 0;

    final thumbnail = product['thumbnail'] as String?;

    final isAvailable =
        product['is_available'] as bool? ?? false;

    final isFeatured =
        product['is_featured'] as bool? ?? false;

    final discountValue = product['discount_percent'];
    final discountPercent =
    discountValue is num ? discountValue.toInt() : 0;

    String? imageUrl;

    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      imageUrl = Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(thumbnail.trim());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 560;
        final isSmallMobile = width < 380;

        final imageSize = isSmallMobile
            ? 68.0
            : isMobile
            ? 78.0
            : 96.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isSmallMobile ? 10 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF0F0F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          // ===========================================
          // MOBILE LAYOUT
          // ===========================================

          child: isMobile
              ? Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductImage(
                    imageUrl: imageUrl,
                    size: imageSize,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ProductInformation(
                      title: title,
                      price: price,
                      isAvailable: isAvailable,
                      isFeatured: isFeatured,
                      discountPercent: discountPercent,
                      compact: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(
                height: 1,
                color: Color(0xFFF0F0F0),
              ),

              const SizedBox(height: 12),

              // Mobile actions
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'ویرایش',
                    color: const Color(0xFF1976D2),
                    onPressed: onEdit,
                  ),

                  const SizedBox(width: 8),

                  _ActionButton(
                    icon: Iconsax.trash_copy,
                    label: 'حذف',
                    color: const Color(0xFFE21B23),
                    onPressed: onDelete,
                  ),

                  const Spacer(),

                  const Icon(
                    Iconsax.box_copy,
                    size: 17,
                    color: Colors.black26,
                  ),
                ],
              ),
            ],
          )

          // ===========================================
          // TABLET & DESKTOP LAYOUT
          // ===========================================

              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProductImage(
                imageUrl: imageUrl,
                size: imageSize,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _ProductInformation(
                  title: title,
                  price: price,
                  isAvailable: isAvailable,
                  isFeatured: isFeatured,
                  discountPercent: discountPercent,
                  compact: false,
                ),
              ),

              const SizedBox(width: 18),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'ویرایش',
                    color: const Color(0xFF1976D2),
                    onPressed: onEdit,
                  ),

                  const SizedBox(height: 9),

                  _ActionButton(
                    icon: Iconsax.trash_copy,
                    label: 'حذف',
                    color: const Color(0xFFE21B23),
                    onPressed: onDelete,
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

// =====================================================
// PRODUCT INFORMATION
// =====================================================

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.title,
    required this.price,
    required this.isAvailable,
    required this.isFeatured,
    required this.discountPercent,
    required this.compact,
  });

  final String title;
  final int price;
  final bool isAvailable;
  final bool isFeatured;
  final int discountPercent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            height: 1.7,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),

        const SizedBox(height: 7),

        // Price
        Text(
          '${_formatPrice(price)} تومان',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 9),

        // Badges
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            runSpacing: 6,
            children: [
              _Badge(
                text: isAvailable ? 'موجود' : 'ناموجود',
                color: isAvailable ? Colors.green : Colors.red,
              ),

              if (isFeatured)
                const _Badge(
                  text: 'ویژه',
                  color: Colors.orange,
                ),

              if (discountPercent > 0)
                _Badge(
                  text: '$discountPercent٪ تخفیف',
                  color: Colors.blue,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }
}

// =====================================================
// PRODUCT IMAGE
// =====================================================

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.size,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFF5F5F5),
        child: imageUrl == null
            ? const Icon(
          Iconsax.image_copy,
          color: Colors.black26,
          size: 28,
        )
            : CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,

          placeholder: (context, url) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },

          errorWidget: (context, url, error) {
            return const Icon(
              Iconsax.image_copy,
              color: Colors.black26,
              size: 28,
            );
          },

          memCacheWidth: 250,
          memCacheHeight: 250,
        ),
      ),
    );
  }
}

// =====================================================
// ACTION BUTTON
// =====================================================

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),

              const SizedBox(width: 5),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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

// =====================================================
// BADGE
// =====================================================

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =====================================================
// PRICE FORMAT
// =====================================================

String _formatPrice(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}
