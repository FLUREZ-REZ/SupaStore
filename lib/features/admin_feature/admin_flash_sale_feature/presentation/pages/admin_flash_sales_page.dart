import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/pages/admin_flash_sale_form_page.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/providers/admin_flash_sales_provider.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/widgets/admin_flash_sale_card.dart';

class AdminFlashSalesPage extends StatelessWidget {
  const AdminFlashSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminFlashSalesProvider>()..loadFlashSales(),
      child: const _AdminFlashSalesView(),
    );
  }
}

class _AdminFlashSalesView extends StatelessWidget {
  const _AdminFlashSalesView();

  static const Color primaryColor = Color(0xFF03045E);
  static const Color backgroundColor = Color(0xFFF7F7F8);
  static const Color dangerColor = Color(0xFFE21B23);

  Future<void> _openForm(
      BuildContext context, {
        dynamic flashSale,
      }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminFlashSaleFormPage(
          flashSale: flashSale,
        ),
      ),
    );

    if (result == true && context.mounted) {
      await context.read<AdminFlashSalesProvider>().refresh();
    }
  }

  Future<void> _deleteFlashSale(
      BuildContext context,
      String id,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف فروش ویژه'),
          content: const Text(
            'آیا از حذف این فروش ویژه مطمئن هستید؟',
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
              style: TextButton.styleFrom(
                foregroundColor: dangerColor,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final provider = context.read<AdminFlashSalesProvider>();

    final success = await provider.deleteFlashSale(id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'فروش ویژه با موفقیت حذف شد.'
              : provider.errorMessage ?? 'حذف فروش ویژه انجام نشد.',
        ),
      ),
    );
  }

  Future<void> _changeStatus(
      BuildContext context, {
        required String id,
        required bool isActive,
      }) async {
    final provider = context.read<AdminFlashSalesProvider>();

    final success = await provider.updateStatus(
      id: id,
      isActive: isActive,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'تغییر وضعیت انجام نشد.',
          ),
        ),
      );
    }
  }

  Widget _buildFlashSaleGrid(
      BuildContext context,
      AdminFlashSalesProvider provider,
      int crossAxisCount,
      double maxWidth,
      ) {
    final double aspectRatio;

    if (crossAxisCount == 1) {
      // موبایل: کارت بلندتر برای جلوگیری از overflow
      aspectRatio = 1;
    } else if (crossAxisCount == 2) {
      // تبلت
      aspectRatio = 1.0;
    } else {
      // دسکتاپ
      aspectRatio = 1.05;
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(
              crossAxisCount == 1 ? 12 : 20,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final flashSale = provider.items[index];

              return AdminFlashSaleCard(
                flashSale: flashSale,
                onEdit: () {
                  _openForm(
                    context,
                    flashSale: flashSale,
                  );
                },
                onDelete: () {
                  _deleteFlashSale(
                    context,
                    flashSale.id,
                  );
                },
                onStatusChanged: (value) {
                  _changeStatus(
                    context,
                    id: flashSale.id,
                    isActive: value,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      AdminFlashSalesProvider provider,
      BoxConstraints constraints,
      ) {
    if (provider.isLoading && !provider.hasData) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (provider.errorMessage != null && !provider.hasData) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.loadFlashSales,
      );
    }

    if (!provider.hasData) {
      return _EmptyView(
        onAdd: () => _openForm(context),
      );
    }

    final width = constraints.maxWidth;

    final int columns;
    final double maxWidth;

    if (width < 600) {
      columns = 1;
      maxWidth = 600;
    } else if (width < 1100) {
      columns = 2;
      maxWidth = 1000;
    } else {
      columns = 3;
      maxWidth = 1450;
    }

    return _buildFlashSaleGrid(
      context,
      provider,
      columns,
      maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<AdminFlashSalesProvider>(
              builder: (context, provider, child) {
                return _buildContent(
                  context,
                  provider,
                  constraints,
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final width = MediaQuery.sizeOf(context).width;

            if (width < 400) {
              return FloatingActionButton(
                onPressed: () => _openForm(context),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                tooltip: 'فروش ویژه جدید',
                child: const Icon(Icons.add),
              );
            }

            return FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('فروش ویژه جدید'),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'هنوز فروش ویژه‌ای ثبت نشده است.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('افزودن فروش ویژه'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
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
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Color(0xFFE21B23),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}