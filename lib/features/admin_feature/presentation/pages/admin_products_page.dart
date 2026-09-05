import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/features/admin_feature/presentation/pages/admin_product_form_page.dart';

import '../providers/admin_product_provider.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() =>
      _AdminProductsPageState();
}

class _AdminProductsPageState
    extends State<AdminProductsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

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

  Future<void> _deleteProduct(
      Map<String, dynamic> product,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف محصول'),
          content: Text(
            'آیا از حذف «${product['title']}» مطمئن هستید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
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
      await context
          .read<AdminProductProvider>()
          .deleteProduct(
        productId: product['id'] as String,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'محصول با موفقیت حذف شد.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در حذف محصول: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFF7F7F8),

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE21B23),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('محصول جدید'),
      ),

      body: Consumer<AdminProductProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(
              refresh: true,
            ),
            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              slivers: [
                // =========================
                // Search
                // =========================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'جستجوی محصول...',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black45,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // =========================
                // Initial Loading
                // =========================

                if (provider.isLoading &&
                    provider.products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  )

                // =========================
                // Empty
                // =========================

                else if (provider.products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'محصولی پیدا نشد.',
                      ),
                    ),
                  )

                // =========================
                // Products
                // =========================

                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      0,
                      16.w,
                      100.h,
                    ),
                    sliver:
                    SliverList.builder(
                      itemCount:
                      provider.products.length +
                          (provider.hasMore
                              ? 1
                              : 0),

                      itemBuilder:
                          (context, index) {
                        // =========================
                        // Load More
                        // =========================

                        if (index >=
                            provider.products
                                .length) {
                          if (!provider
                              .isLoadingMore) {
                            WidgetsBinding
                                .instance
                                .addPostFrameCallback(
                                  (_) {
                                if (mounted) {
                                  provider
                                      .loadMore();
                                }
                              },
                            );
                          }

                          return Padding(
                            padding:
                            EdgeInsets.all(
                              20.w,
                            ),
                            child:
                            const Center(
                              child:
                              CircularProgressIndicator(),
                            ),
                          );
                        }

                        // =========================
                        // Product
                        // =========================

                        final product =
                        provider.products[
                        index];

                        return _ProductCard(
                          product: product,
                          onEdit: () =>
                              _openForm(
                                product: product,
                              ),
                          onDelete: () =>
                              _deleteProduct(
                                product,
                              ),
                        );
                      },
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

// =====================================================
// Product Card
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

  @override
  Widget build(BuildContext context) {
    final title =
        product['title'] as String? ?? 'بدون عنوان';

    final price =
        product['price'] as int? ?? 0;

    final thumbnail =
    product['thumbnail'] as String?;

    final isAvailable =
        product['is_available'] as bool? ?? false;

    final isFeatured =
        product['is_featured'] as bool? ?? false;

    final discountPercent =
        product['discount_percent'] as int? ?? 0;

    String? imageUrl;

    if (thumbnail != null &&
        thumbnail.trim().isNotEmpty) {
      imageUrl = Supabase.instance.client.storage
          .from('assets')
          .getPublicUrl(
        thumbnail.trim(),
      );
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // تصویر محصول - سمت راست
          // =================================================

          _ProductImage(
            imageUrl: imageUrl,
          ),

          SizedBox(width: 12.w),

          // =================================================
          // اطلاعات محصول - وسط
          // =================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  '${_formatPrice(price)} تومان',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 8.h),

                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _Badge(
                      text: isAvailable
                          ? 'موجود'
                          : 'ناموجود',
                      color: isAvailable
                          ? Colors.green
                          : Colors.red,
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
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // =================================================
          // دکمه‌های عملیات - سمت چپ
          // =================================================

          Column(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'ویرایش',
                color: const Color(0xFF1976D2),
                onPressed: onEdit,
              ),

              SizedBox(height: 8.h),

              _ActionButton(
                icon: Icons.delete_outline,
                label: 'حذف',
                color: const Color(0xFFE21B23),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
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
// Product Image
// =====================================================

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(12.r),
      child: Container(
        width: 82.w,
        height: 82.w,
        color: const Color(0xFFF5F5F5),
        child: imageUrl == null
            ? const Icon(
          Icons.image_outlined,
          color: Colors.black26,
        )
            : CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,

          // ==================================
          // Loading
          // ==================================

          placeholder:
              (context, url) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },

          // ==================================
          // Error
          // ==================================

          errorWidget:
              (context, url, error) {
            return const Icon(
              Icons
                  .image_not_supported_outlined,
              color: Colors.black26,
            );
          },

          // ==================================
          // Cache
          // ==================================

          memCacheWidth: 250,
          memCacheHeight: 250,
        ),
      ),
    );
  }
}

// =====================================================
// Action Button
// =====================================================

class _ActionButton
    extends StatelessWidget {
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
      color:
      color.withValues(alpha: 0.08),
      borderRadius:
      BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(8.r),
        child: Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 7.h,
          ),
          child: Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: color,
              ),

              SizedBox(width: 5.w),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight:
                  FontWeight.w600,
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
// Badge
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
      padding:
      EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: 0.1),
        borderRadius:
        BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.sp,
          color: color,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}