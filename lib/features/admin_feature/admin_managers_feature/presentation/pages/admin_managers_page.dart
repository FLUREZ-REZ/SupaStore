import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_managers_feature/domain/entities/admin_manager_entity.dart';
import 'package:supastore/features/admin_feature/admin_managers_feature/presentation/providers/admin_managers_provider.dart';

class AdminManagersPage extends StatelessWidget {
  const AdminManagersPage({super.key});

  static const Color _primaryRed = Color(0xFFE21B23);
  static const Color _background = Color(0xFFF7F7F8);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      getIt<AdminManagersProvider>()..loadManagers(),
      child: const _AdminManagersView(),
    );
  }
}

class _AdminManagersView extends StatelessWidget {
  const _AdminManagersView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminManagersPage._background,
        appBar: AppBar(
          title: const Text('مدیریت مدیران'),
          centerTitle: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                context
                    .read<AdminManagersProvider>()
                    .loadManagers();
              },
              icon: const Icon(Icons.refresh),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AdminManagersPage._primaryRed,
          foregroundColor: Colors.white,
          onPressed: () {
            _showAddManagerDialog(context);
          },
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('افزودن مدیر'),
        ),
        body: const _ManagersBody(),
      ),
    );
  }

  Future<void> _showAddManagerDialog(
      BuildContext context,
      ) async {
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('افزودن مدیر'),
            content: SizedBox(
              width: 420.w,
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'شماره موبایل',
                  hintText: '09123456789',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                  AdminManagersPage._primaryRed,
                ),
                onPressed: () async {
                  final phone = _normalizePhone(
                    phoneController.text,
                  );

                  if (phone.isEmpty) {
                    _showMessage(
                      context,
                      'شماره موبایل را وارد کنید.',
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  final provider =
                  context.read<AdminManagersProvider>();

                  final profile =
                  await provider.findProfileByPhone(
                    phone: phone,
                  );

                  if (!context.mounted) return;

                  if (profile == null) {
                    _showMessage(
                      context,
                      'کاربری با این شماره پیدا نشد.',
                    );
                    return;
                  }

                  await _showManagerForm(
                    context,
                    profile,
                  );
                },
                child: const Text('جستجو'),
              ),
            ],
          ),
        );
      },
    );

    phoneController.dispose();
  }

  Future<void> _showManagerForm(
      BuildContext context,
      AdminManagerEntity manager,
      ) async {
    String selectedRole =
    manager.adminRole == 'none'
        ? 'order_manager'
        : manager.adminRole;

    bool isActive = manager.isActive;

    final provider =
    context.read<AdminManagersProvider>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogContext,
              setState,
              ) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                  manager.fullName?.trim().isNotEmpty == true
                      ? manager.fullName!
                      : 'مدیر جدید',
                ),
                content: SizedBox(
                  width: 460.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _InfoRow(
                        title: 'شماره موبایل',
                        value: manager.phone,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'نقش مدیر',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'super_admin',
                            child: Text('مدیر کل'),
                          ),
                          DropdownMenuItem(
                            value: 'order_manager',
                            child: Text('مدیر سفارش‌ها'),
                          ),
                          DropdownMenuItem(
                            value: 'product_manager',
                            child: Text('مدیر محصولات'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                      SizedBox(height: 8.h),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'مدیر فعال باشد',
                        ),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('انصراف'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      AdminManagersPage._primaryRed,
                    ),
                    onPressed: () async {
                      final selectedRoleValue =
                          selectedRole;

                      final selectedActiveValue =
                          isActive;

                      Navigator.pop(dialogContext);

                      final success =
                      await provider.updateManager(
                        userId: manager.id,
                        adminRole: selectedRoleValue,
                        isActive: selectedActiveValue,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        _showMessage(
                          context,
                          'مدیر با موفقیت ثبت شد.',
                        );
                      } else {
                        _showMessage(
                          context,
                          provider.errorMessage ??
                              'خطایی رخ داد.',
                        );
                      }
                    },
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _normalizePhone(String value) {
    var phone = value.trim();

    phone = phone.replaceAll(' ', '');
    phone = phone.replaceAll('-', '');

    phone = phone
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    if (phone.startsWith('+98')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('0')) {
      phone = '98${phone.substring(1)}';
    }

    return phone;
  }

  static void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}

class _ManagersBody extends StatelessWidget {
  const _ManagersBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminManagersProvider>(
      builder: (
          context,
          provider,
          _,
          ) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.errorMessage != null &&
            provider.managers.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  FilledButton(
                    onPressed: provider.loadManagers,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.managers.isEmpty) {
          return const Center(
            child: Text(
              'هنوز هیچ مدیری ثبت نشده است.',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadManagers,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16.w,
              20.h,
              16.w,
              100.h,
            ),
            itemCount: provider.managers.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: 10.h),
            itemBuilder: (
                context,
                index,
                ) {
              final manager =
              provider.managers[index];

              return _ManagerCard(
                manager: manager,
              );
            },
          ),
        );
      },
    );
  }
}

class _ManagerCard extends StatelessWidget {
  const _ManagerCard({
    required this.manager,
  });

  final AdminManagerEntity manager;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: Colors.grey.shade100,
              backgroundImage:
              manager.avatarUrl != null &&
                  manager.avatarUrl!.isNotEmpty
                  ? NetworkImage(
                manager.avatarUrl!,
              )
                  : null,
              child:
              manager.avatarUrl == null ||
                  manager.avatarUrl!.isEmpty
                  ? const Icon(
                Icons.person_outline,
              )
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    manager.fullName?.trim().isNotEmpty ==
                        true
                        ? manager.fullName!
                        : 'بدون نام',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    manager.phone,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _RoleBadge(
                        role: manager.adminRole,
                      ),
                      SizedBox(width: 8.w),
                      _StatusBadge(
                        isActive: manager.isActive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await _editManager(
                      context,
                      manager,
                    );
                    break;

                  case 'toggle':
                    await _toggleStatus(
                      context,
                      manager,
                    );
                    break;

                  case 'remove':
                    await _removeManager(
                      context,
                      manager,
                    );
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('ویرایش نقش'),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    'فعال / غیرفعال کردن',
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'حذف دسترسی مدیریتی',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editManager(
      BuildContext context,
      AdminManagerEntity manager,
      ) async {
    String selectedRole = manager.adminRole;
    bool isActive = manager.isActive;

    final provider =
    context.read<AdminManagersProvider>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogContext,
              setState,
              ) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('ویرایش مدیر'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'نقش',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'super_admin',
                          child: Text('مدیر کل'),
                        ),
                        DropdownMenuItem(
                          value: 'order_manager',
                          child: Text(
                            'مدیر سفارش‌ها',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'product_manager',
                          child: Text(
                            'مدیر محصولات',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    SizedBox(height: 8.h),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('فعال'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('انصراف'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      AdminManagersPage._primaryRed,
                    ),
                    onPressed: () async {
                      final selectedRoleValue =
                          selectedRole;

                      final selectedActiveValue =
                          isActive;

                      Navigator.pop(dialogContext);

                      final success =
                      await provider.updateManager(
                        userId: manager.id,
                        adminRole: selectedRoleValue,
                        isActive: selectedActiveValue,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'تغییرات ذخیره شد.'
                                : provider.errorMessage ??
                                'خطایی رخ داد.',
                          ),
                        ),
                      );
                    },
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleStatus(
      BuildContext context,
      AdminManagerEntity manager,
      ) async {
    final provider =
    context.read<AdminManagersProvider>();

    final success =
    await provider.updateManagerStatus(
      userId: manager.id,
      isActive: !manager.isActive,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? manager.isActive
                ? 'مدیر غیرفعال شد.'
                : 'مدیر فعال شد.'
                : provider.errorMessage ??
                'خطایی رخ داد.',
          ),
        ),
      );
  }

  Future<void> _removeManager(
      BuildContext context,
      AdminManagerEntity manager,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حذف دسترسی مدیریتی',
            ),
            content: const Text(
              'آیا مطمئن هستید که دسترسی مدیریتی '
                  'این کاربر حذف شود؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                  AdminManagersPage._primaryRed,
                ),
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    final provider =
    context.read<AdminManagersProvider>();

    final success =
    await provider.removeManager(
      userId: manager.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'دسترسی مدیریتی حذف شد.'
                : provider.errorMessage ??
                'خطایی رخ داد.',
          ),
        ),
      );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.role,
  });

  final String role;

  String get label {
    switch (role) {
      case 'super_admin':
        return 'مدیر کل';

      case 'order_manager':
        return 'مدیر سفارش‌ها';

      case 'product_manager':
        return 'مدیر محصولات';

      default:
        return 'بدون نقش';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isActive ? 'فعال' : 'غیرفعال',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isActive
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }
}