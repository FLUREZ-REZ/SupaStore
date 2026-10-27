
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/presentation/pages/add_edit_address_page.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لطفاً ابتدا وارد حساب کاربری شوید.'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => getIt<AddressProvider>()
        ..loadAddresses(userId: user.id),
      child: const _AddressesView(),
    );
  }
}

// =========================================================
// VIEW
// =========================================================

class _AddressesView extends StatelessWidget {
  const _AddressesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final user = Supabase.instance.client.auth.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: AppColors.orders_page_redi,
          foregroundColor: Colors.white,
          title: const Text('آدرس‌های من'),
          centerTitle: true,
        ),
        body: user == null
            ? const Center(
          child: Text('لطفاً وارد حساب کاربری شوید.'),
        )
            : _buildBody(context, provider, user.id),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: provider.isUpdating
              ? null
              : () async {
            await _openAddAddressPage(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('افزودن آدرس'),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      AddressProvider provider,
      String userId,
      ) {
    if (provider.isLoading) {
      return const _AddressesShimmer();
    }

    if (provider.error != null && provider.addresses.isEmpty) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () {
          provider.loadAddresses(userId: userId);
        },
      );
    }

    if (provider.addresses.isEmpty) {
      return _EmptyState(
        onAddAddress: () {
          _openAddAddressPage(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(userId: userId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          100.h,
        ),
        children: [
          if (provider.error != null)
            _ErrorBanner(
              message: provider.error!,
              onClose: provider.clearError,
            ),
          if (provider.error != null) SizedBox(height: 10.h),
          Text(
            'آدرس‌های شما',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'آدرس موردنظر خود را برای ارسال سفارش انتخاب کنید.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16.h),
          ...provider.addresses.map(
                (address) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _AddressCard(
                address: address,
                isSelected:
                provider.selectedAddress?.id == address.id,
                isUpdating: provider.isUpdating,
                onSelect: () {
                  provider.selectAddress(address);
                },
                onSetDefault: () async {
                  await _setDefaultAddress(
                    context,
                    provider,
                    address,
                    userId,
                  );
                },
                onEdit: () async {
                  await _editAddress(context, address);
                },
                onDelete: () async {
                  await _deleteAddress(
                    context,
                    provider,
                    address,
                    userId,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADD
  // =========================================================

  Future<void> _openAddAddressPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditAddressPage(),
      ),
    );
  }

  // =========================================================
  // EDIT
  // =========================================================

  Future<void> _editAddress(
      BuildContext context,
      AddressEntity address,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAddressPage(address: address),
      ),
    );
  }

  // =========================================================
  // SET DEFAULT
  // =========================================================

  Future<void> _setDefaultAddress(
      BuildContext context,
      AddressProvider provider,
      AddressEntity address,
      String userId,
      ) async {
    if (address.isDefault) return;

    final success = await provider.setDefaultAddress(
      addressId: address.id,
      userId: userId,
    );

    if (!context.mounted) return;

    if (!success && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> _deleteAddress(
      BuildContext context,
      AddressProvider provider,
      AddressEntity address,
      String userId,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف آدرس'),
            content: Text(
              'آیا مطمئن هستید که می‌خواهید آدرس «${address.title}» را حذف کنید؟',
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
                child: Text(
                  'حذف',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    final success = await provider.deleteAddress(
      addressId: address.id,
      userId: userId,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('آدرس با موفقیت حذف شد.'),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }
}

// =========================================================
// ADDRESSES SHIMMER
// =========================================================

class _AddressesShimmer extends StatefulWidget {
  const _AddressesShimmer();

  @override
  State<_AddressesShimmer> createState() =>
      _AddressesShimmerState();
}

class _AddressesShimmerState extends State<_AddressesShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (context, child) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            100.h,
          ),
          children: [
            _ShimmerBox(
              controller: _controller,
              width: 115.w,
              height: 19.h,
              radius: 5.r,
            ),
            SizedBox(height: 10.h),
            _ShimmerBox(
              controller: _controller,
              width: 240.w,
              height: 12.h,
              radius: 5.r,
            ),
            SizedBox(height: 22.h),
            for (int i = 0; i < 3; i++) ...[
              _AddressCardShimmer(controller: _controller),
              SizedBox(height: 12.h),
            ],
          ],
        );
      },
    );
  }
}

// =========================================================
// ADDRESS CARD SHIMMER
// =========================================================

class _AddressCardShimmer extends StatelessWidget {
  const _AddressCardShimmer({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 42.w,
                height: 42.w,
                radius: 30.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ShimmerBox(
                  controller: controller,
                  width: 120.w,
                  height: 15.h,
                  radius: 5.r,
                ),
              ),
              _ShimmerBox(
                controller: controller,
                width: 55.w,
                height: 25.h,
                radius: 8.r,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _ShimmerInfoRow(controller: controller, width: 145.w),
          SizedBox(height: 12.h),
          _ShimmerInfoRow(controller: controller, width: 115.w),
          SizedBox(height: 12.h),
          _ShimmerInfoRow(controller: controller, width: 170.w),
          SizedBox(height: 12.h),
          _ShimmerInfoRow(controller: controller, width: 220.w),
          SizedBox(height: 18.h),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 12.h),
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 90.w,
                height: 30.h,
                radius: 8.r,
              ),
              const Spacer(),
              _ShimmerBox(
                controller: controller,
                width: 32.w,
                height: 32.w,
                radius: 8.r,
              ),
              SizedBox(width: 8.w),
              _ShimmerBox(
                controller: controller,
                width: 32.w,
                height: 32.w,
                radius: 8.r,
              ),
              SizedBox(width: 8.w),
              _ShimmerBox(
                controller: controller,
                width: 32.w,
                height: 32.w,
                radius: 8.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerInfoRow extends StatelessWidget {
  const _ShimmerInfoRow({
    required this.controller,
    required this.width,
  });

  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ShimmerBox(
          controller: controller,
          width: 18.w,
          height: 18.w,
          radius: 5.r,
        ),
        SizedBox(width: 9.w),
        _ShimmerBox(
          controller: controller,
          width: width,
          height: 12.h,
          radius: 5.r,
        ),
      ],
    );
  }
}

// =========================================================
// REUSABLE SHIMMER BOX
// =========================================================

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final AnimationController controller;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final position = -1.0 + controller.value * 3.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(position, 0),
                  end: Alignment(position + 1, 0),
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                  stops: const [0.25, 0.5, 0.75],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================
// ADDRESS CARD
// =========================================================

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.isUpdating,
    required this.onSelect,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressEntity address;
  final bool isSelected;
  final bool isUpdating;
  final VoidCallback onSelect;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: isUpdating ? null : onSelect,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.location_copy,
                      color: primary,
                      size: 23.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      address.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'پیش‌فرض',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              _InfoRow(
                icon: Iconsax.user_copy,
                text: address.receiverName,
              ),
              SizedBox(height: 8.h),
              _InfoRow(
                icon: Iconsax.call_copy,
                text: address.phone,
              ),
              SizedBox(height: 8.h),
              _InfoRow(
                icon: Iconsax.house_copy,
                text: '${address.province}، ${address.city}',
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.house_2_copy,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      address.address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.7,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (address.postalCode != null &&
                  address.postalCode!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _InfoRow(
                  icon: Iconsax.code_copy,
                  text: 'کد پستی: ${address.postalCode}',
                ),
              ],
              SizedBox(height: 14.h),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: isUpdating ? null : onSelect,
                      icon: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18.sp,
                      ),
                      label: Text(
                        isSelected ? 'انتخاب شده' : 'انتخاب',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isUpdating ? null : onEdit,
                    tooltip: 'ویرایش',
                    icon: const Icon(Iconsax.edit_copy),
                  ),
                  IconButton(
                    onPressed: isUpdating ? null : onDelete,
                    tooltip: 'حذف',
                    icon: Icon(
                      Iconsax.trash_copy,
                      color: Colors.red.shade400,
                    ),
                  ),
                  PopupMenuButton<String>(
                    enabled: !isUpdating,
                    onSelected: (value) {
                      if (value == 'default') {
                        onSetDefault();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'default',
                        enabled: !address.isDefault,
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline),
                            SizedBox(width: 8.w),
                            Text(
                              address.isDefault
                                  ? 'آدرس پیش‌فرض'
                                  : 'تعیین به عنوان پیش‌فرض',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// INFO ROW
// =========================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Colors.grey.shade500,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================
// EMPTY STATE
// =========================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAddAddress,
  });

  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.location_copy,
                size: 45.sp,
                color: primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'هنوز آدرسی ثبت نکرده‌اید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'برای ثبت سفارش ابتدا یک آدرس برای ارسال محصولات اضافه کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.7,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onAddAddress,
              icon: const Icon(Icons.add),
              label: const Text('افزودن آدرس'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// ERROR STATE
// =========================================================

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
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.information_copy,
              size: 50.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 14.h),
            Text(
              'خطا در دریافت آدرس‌ها',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// ERROR BANNER
// =========================================================

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.information_copy,
            color: Colors.red.shade600,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.red.shade700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Iconsax.close_circle_copy),
            iconSize: 18.sp,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
