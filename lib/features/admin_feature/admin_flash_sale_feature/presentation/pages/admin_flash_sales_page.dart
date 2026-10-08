import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/pages/admin_flash_sale_form_page.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/providers/admin_flash_sales_provider.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/widgets/admin_flash_sale_card.dart';

class AdminFlashSalesPage extends StatelessWidget {
  const AdminFlashSalesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      getIt<AdminFlashSalesProvider>()
        ..loadFlashSales(),
      child: const _AdminFlashSalesView(),
    );
  }
}

class _AdminFlashSalesView
    extends StatelessWidget {
  const _AdminFlashSalesView();

  Future<void> _openForm(
      BuildContext context, {
        dynamic flashSale,
      }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminFlashSaleFormPage(
              flashSale: flashSale,
            ),
      ),
    );

    if (result == true &&
        context.mounted) {
      await context
          .read<AdminFlashSalesProvider>()
          .refresh();
    }
  }

  Future<void> _deleteFlashSale(
      BuildContext context,
      String id,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'حذف فروش ویژه',
          ),
          content: const Text(
            'آیا از حذف این فروش ویژه مطمئن هستید؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'انصراف',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor:
                const Color(0xFFE21B23),
              ),
              child: const Text(
                'حذف',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final provider =
    context.read<AdminFlashSalesProvider>();

    final success =
    await provider.deleteFlashSale(id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'فروش ویژه با موفقیت حذف شد.'
              : provider.errorMessage ??
              'حذف فروش ویژه انجام نشد.',
        ),
      ),
    );
  }

  Future<void> _changeStatus(
      BuildContext context, {
        required String id,
        required bool isActive,
      }) async {
    final provider =
    context.read<AdminFlashSalesProvider>();

    final success =
    await provider.updateStatus(
      id: id,
      isActive: isActive,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'تغییر وضعیت انجام نشد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        body: Consumer<
            AdminFlashSalesProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            if (provider.isLoading &&
                !provider.hasData) {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            if (provider.errorMessage != null &&
                !provider.hasData) {
              return _ErrorView(
                message:
                provider.errorMessage!,
                onRetry:
                provider.loadFlashSales,
              );
            }

            if (!provider.hasData) {
              return _EmptyView(
                onAdd: () {
                  _openForm(context);
                },
              );
            }

            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: provider.items.length,
                itemBuilder:
                    (context, index) {
                  final flashSale =
                  provider.items[index];

                  return AdminFlashSaleCard(
                    flashSale: flashSale,
                    onEdit: () {
                      _openForm(
                        context,
                        flashSale:
                        flashSale,
                      );
                    },
                    onDelete: () {
                      _deleteFlashSale(
                        context,
                        flashSale.id,
                      );
                    },
                    onStatusChanged: (
                        value,
                        ) {
                      _changeStatus(
                        context,
                        id: flashSale.id,
                        isActive: value,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton
            .extended(
          onPressed: () {
            _openForm(context);
          },
          backgroundColor:
          const Color(0xFF03045e),
          foregroundColor: Colors.white,
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'فروش ویژه جدید',
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'هنوز فروش ویژه‌ای ثبت نشده است.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'افزودن فروش ویژه',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFE21B23),
                foregroundColor:
                Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52.sp,
              color: const Color(
                0xFFE21B23,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
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