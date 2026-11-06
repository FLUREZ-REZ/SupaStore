
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/pages/add_edit_shipping_method_page.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/providers/admin_shipping_provider.dart';

class AdminShippingPage extends StatefulWidget {
  const AdminShippingPage({super.key});

  @override
  State<AdminShippingPage> createState() => _AdminShippingPageState();
}

class _AdminShippingPageState extends State<AdminShippingPage> {
  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF023E8A);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AdminShippingProvider>().loadShippingMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

          actions: [
            Consumer<AdminShippingProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  tooltip: 'بازخوانی',
                  onPressed: provider.isBusy
                      ? null
                      : () {
                    provider.refresh();
                  },
                  icon: const Icon(Iconsax.refresh_copy),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          onPressed: _openAddPage,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'روش ارسال جدید',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Consumer<AdminShippingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && !provider.hasShippingMethods) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                ),
              );
            }

            if (provider.error != null && !provider.hasShippingMethods) {
              return _buildErrorState(provider);
            }

            if (!provider.hasShippingMethods) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: _primaryColor,
              onRefresh: provider.refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final horizontalPadding = width >= 1200
                      ? 32.0
                      : width >= 650
                      ? 24.0
                      : 16.0;

                  final crossAxisCount = width >= 1250
                      ? 3
                      : width >= 850
                      ? 2
                      : 1;

                  final cardAspectRatio = crossAxisCount == 3
                      ? 1.65
                      : crossAxisCount == 2
                      ? 1.9
                      : 2.2;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      22,
                      horizontalPadding,
                      110,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1450,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(provider),
                              const SizedBox(height: 22),
                              if (crossAxisCount == 1)
                                ...provider.shippingMethods.map(
                                      (method) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 14,
                                    ),
                                    child: _buildShippingCard(
                                      method,
                                      provider,
                                    ),
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount:
                                  provider.shippingMethods.length,
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: cardAspectRatio,
                                  ),
                                  itemBuilder: (context, index) {
                                    final method =
                                    provider.shippingMethods[index];

                                    return _buildShippingCard(
                                      method,
                                      provider,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader(AdminShippingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 480;

          final icon = Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Iconsax.truck_fast_copy,
              color: Colors.indigo,
              size: 27,
            ),
          );

          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'روش‌های ارسال',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'روش‌های ارسال قابل انتخاب در مرحله تسویه حساب',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          );

          final stats = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${provider.activeShippingMethods} فعال',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.shippingMethods.length} روش',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    icon,
                    const SizedBox(width: 13),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    stats,
                    Icon(
                      Iconsax.truck_fast_copy,
                      size: 22,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(child: title),
              const SizedBox(width: 12),
              stats,
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // SHIPPING CARD
  // --------------------------------------------------

  Widget _buildShippingCard(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: method.isActive
              ? Colors.grey.shade200
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: method.isActive
                        ? Colors.indigo.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Iconsax.truck_copy,
                    size: 23,
                    color: method.isActive ? Colors.indigo : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 220,
                            ),
                            child: Text(
                              method.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildStatusBadge(method.isActive),
                        ],
                      ),
                      if (method.description != null &&
                          method.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          method.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEditPage(method);
                    } else if (value == 'toggle') {
                      _toggleMethod(method, provider);
                    } else if (value == 'delete') {
                      _confirmDelete(method, provider);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('ویرایش'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              method.isActive
                                  ? Iconsax.eye_slash_copy
                                  : Iconsax.eye_copy,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              method.isActive
                                  ? 'غیرفعال کردن'
                                  : 'فعال کردن',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.trash_copy,
                              size: 20,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'حذف',
                              style: TextStyle(
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 14),
            _buildInfoSection(method),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AdminShippingMethodEntity method) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 320;

        if (compact) {
          return Column(
            children: [
              _buildInfoItem(
                icon: Iconsax.card_copy,
                title: 'هزینه',
                value: '${_formatPrice(method.cost)} تومان',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Iconsax.clock_copy,
                title: 'زمان ارسال',
                value: method.estimatedDays?.trim().isNotEmpty == true
                    ? method.estimatedDays!
                    : 'ثبت نشده',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Iconsax.sort_copy,
                title: 'ترتیب',
                value: method.sortOrder.toString(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Iconsax.card_copy,
                title: 'هزینه',
                value: '${_formatPrice(method.cost)} تومان',
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Iconsax.clock_copy,
                title: 'زمان ارسال',
                value: method.estimatedDays?.trim().isNotEmpty == true
                    ? method.estimatedDays!
                    : 'ثبت نشده',
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: _buildInfoItem(
                icon: Iconsax.sort_copy,
                title: 'ترتیب',
                value: method.sortOrder.toString(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade500,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'فعال' : 'غیرفعال',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isActive
              ? Colors.green.shade700
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.truck_copy,
                  size: 40,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'هنوز روش ارسالی ثبت نشده است',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'برای نمایش روش‌های ارسال در Checkout، '
                    'حداقل یک روش ارسال ایجاد کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _openAddPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن روش ارسال'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ERROR STATE
  // --------------------------------------------------

  Widget _buildErrorState(AdminShippingProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.warning_2_copy,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'دریافت روش‌های ارسال انجام نشد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: provider.loadShippingMethods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // NAVIGATION
  // --------------------------------------------------

  Future<void> _openAddPage() async {
    final provider = context.read<AdminShippingProvider>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: provider,
            child: const AddEditShippingMethodPage(),
          );
        },
      ),
    );

    if (result == true && mounted) {
      await provider.refresh();
    }
  }

  Future<void> _openEditPage(
      AdminShippingMethodEntity method,
      ) async {
    final provider = context.read<AdminShippingProvider>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: provider,
            child: AddEditShippingMethodPage(
              shippingMethod: method,
            ),
          );
        },
      ),
    );

    if (result == true && mounted) {
      await provider.refresh();
    }
  }

  // --------------------------------------------------
  // TOGGLE
  // --------------------------------------------------

  Future<void> _toggleMethod(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) async {
    final success = await provider.toggleShippingMethod(method);

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        method.isActive
            ? 'روش ارسال غیرفعال شد.'
            : 'روش ارسال فعال شد.',
      );
    } else if (provider.error != null) {
      _showSnackBar(
        provider.error!,
        isError: true,
      );
    }
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  Future<void> _confirmDelete(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف روش ارسال'),
            content: Text(
              'آیا از حذف «${method.title}» مطمئن هستید؟\n'
                  'این عملیات قابل بازگشت نیست.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.deleteShippingMethod(
      id: method.id,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('روش ارسال حذف شد.');
    } else if (provider.error != null) {
      _showSnackBar(
        provider.error!,
        isError: true,
      );
    }
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _formatPrice(int price) {
    final value = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
