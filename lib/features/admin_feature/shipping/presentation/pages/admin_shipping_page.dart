import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/pages/add_edit_shipping_method_page.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/providers/admin_shipping_provider.dart';

class AdminShippingPage extends StatefulWidget {
  const AdminShippingPage({super.key});

  @override
  State<AdminShippingPage> createState() =>
      _AdminShippingPageState();
}

class _AdminShippingPageState
    extends State<AdminShippingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdminShippingProvider>()
          .loadShippingMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تنظیمات ارسال',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          onPressed: _openAddPage,
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: Text(
            'روش ارسال جدید',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Consumer<AdminShippingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading &&
                !provider.hasShippingMethods) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              );
            }

            if (provider.error != null &&
                !provider.hasShippingMethods) {
              return _buildErrorState(
                provider,
              );
            }

            if (!provider.hasShippingMethods) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: Colors.red,
              onRefresh: provider.refresh,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  18.h,
                  16.w,
                  100.h,
                ),
                children: [
                  _buildHeader(provider),
                  SizedBox(height: 18.h),
                  ...provider.shippingMethods.map(
                        (method) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 12.h,
                        ),
                        child: _buildShippingCard(
                          method,
                          provider,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      AdminShippingProvider provider,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: Colors.indigo,
              size: 27.sp,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'روش‌های ارسال',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'روش‌های ارسال قابل انتخاب در مرحله تسویه حساب',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '${provider.activeShippingMethods} فعال',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${provider.shippingMethods.length} روش',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: method.isActive
              ? Colors.grey.shade200
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 7.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    color: method.isActive
                        ? Colors.indigo.withValues(
                      alpha: 0.08,
                    )
                        : Colors.grey.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(13.r),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 23.sp,
                    color: method.isActive
                        ? Colors.indigo
                        : Colors.grey,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.title,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight:
                                FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildStatusBadge(
                            method.isActive,
                          ),
                        ],
                      ),
                      if (method.description !=
                          null &&
                          method.description!
                              .trim()
                              .isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          method.description!,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            height: 1.5,
                            color:
                            Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
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
                      _toggleMethod(
                        method,
                        provider,
                      );
                    } else if (value == 'delete') {
                      _confirmDelete(
                        method,
                        provider,
                      );
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            SizedBox(width: 10.w),
                            const Text('ویرایش'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              method.isActive
                                  ? Icons
                                  .visibility_off_outlined
                                  : Icons
                                  .visibility_outlined,
                              size: 20,
                            ),
                            SizedBox(width: 10.w),
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
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red.shade600,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'حذف',
                              style: TextStyle(
                                color:
                                Colors.red.shade600,
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
            SizedBox(height: 14.h),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.payments_outlined,
                    title: 'هزینه',
                    value:
                    '${_formatPrice(method.cost)} تومان',
                  ),
                ),
                Container(
                  width: 1,
                  height: 35.h,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.schedule_outlined,
                    title: 'زمان ارسال',
                    value:
                    method.estimatedDays
                        ?.trim()
                        .isNotEmpty ==
                        true
                        ? method.estimatedDays!
                        : 'ثبت نشده',
                  ),
                ),
                Container(
                  width: 1,
                  height: 35.h,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.sort_rounded,
                    title: 'ترتیب',
                    value: method.sortOrder.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          size: 18.sp,
          color: Colors.grey.shade500,
        ),
        SizedBox(height: 5.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 9.5.sp,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isActive ? 'فعال' : 'غیرفعال',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: isActive
              ? Colors.green.shade700
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 82.w,
              height: 82.w,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 40.sp,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'هنوز روش ارسالی ثبت نشده است',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'برای نمایش روش‌های ارسال در Checkout، '
                  'حداقل یک روش ارسال ایجاد کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _openAddPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 11.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
              ),
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'افزودن روش ارسال',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      AdminShippingProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Colors.red,
            ),
            SizedBox(height: 14.h),
            Text(
              'دریافت روش‌های ارسال انجام نشد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (provider.error != null) ...[
              SizedBox(height: 8.h),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: provider.loadShippingMethods,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
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

  Future<void> _openAddPage() async {
    final provider =
    context.read<AdminShippingProvider>();

    final result =
    await Navigator.of(context).push<bool>(
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
    final provider =
    context.read<AdminShippingProvider>();

    final result =
    await Navigator.of(context).push<bool>(
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

  Future<void> _toggleMethod(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) async {
    final success =
    await provider.toggleShippingMethod(
      method,
    );

    if (!mounted) {
      return;
    }

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

  Future<void> _confirmDelete(
      AdminShippingMethodEntity method,
      AdminShippingProvider provider,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حذف روش ارسال',
            ),
            content: Text(
              'آیا از حذف «${method.title}» مطمئن هستید؟\n'
                  'این عملیات قابل بازگشت نیست.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'انصراف',
                ),
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
                child: const Text(
                  'حذف',
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success =
    await provider.deleteShippingMethod(
      id: method.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showSnackBar(
        'روش ارسال حذف شد.',
      );
    } else if (provider.error != null) {
      _showSnackBar(
        provider.error!,
        isError: true,
      );
    }
  }

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
          backgroundColor:
          isError ? Colors.red : Colors.green,
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  String _formatPrice(int price) {
    final value = price.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd =
          value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}