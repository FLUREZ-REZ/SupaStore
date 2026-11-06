
import 'package:flutter/material.dart';
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

          centerTitle: true,
          elevation: 0,
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
          backgroundColor: AppColors.orders_page_redi,
          foregroundColor: Colors.white,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 1200
            ? 32.0
            : width >= 700
            ? 24.0
            : 16.0;

        return RefreshIndicator(
          onRefresh: () => provider.refresh(userId: userId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              110,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.error != null) ...[
                        _ErrorBanner(
                          message: provider.error!,
                          onClose: provider.clearError,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'آدرس‌های شما',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'آدرس موردنظر خود را برای ارسال سفارش انتخاب کنید.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAddressLayout(
                        context,
                        provider,
                        userId,
                        width,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressLayout(
      BuildContext context,
      AddressProvider provider,
      String userId,
      double width,
      ) {
    // موبایل: کارت‌ها زیر هم
    if (width < 650) {
      return Column(
        children: provider.addresses.map((address) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AddressCard(
              address: address,
              isSelected: provider.selectedAddress?.id == address.id,
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
          );
        }).toList(),
      );
    }

    // تبلت و دسکتاپ: نمایش شبکه‌ای
    final crossAxisCount = width >= 1100 ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.addresses.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: 330,
      ),
      itemBuilder: (context, index) {
        final address = provider.addresses[index];

        return _AddressCard(
          address: address,
          isSelected: provider.selectedAddress?.id == address.id,
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
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 1200
            ? 32.0
            : width >= 700
            ? 24.0
            : 16.0;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                100,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(
                          controller: _controller,
                          width: 120,
                          height: 20,
                          radius: 5,
                        ),
                        const SizedBox(height: 12),
                        _ShimmerBox(
                          controller: _controller,
                          width: 260,
                          height: 13,
                          radius: 5,
                        ),
                        const SizedBox(height: 26),
                        if (width >= 1100)
                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              mainAxisExtent: 330,
                            ),
                            itemBuilder: (context, index) {
                              return _AddressCardShimmer(
                                controller: _controller,
                              );
                            },
                          )
                        else
                          ...List.generate(
                            3,
                                (index) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 14),
                              child: _AddressCardShimmer(
                                controller: _controller,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 42,
                height: 42,
                radius: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShimmerBox(
                  controller: controller,
                  width: 120,
                  height: 15,
                  radius: 5,
                ),
              ),
              _ShimmerBox(
                controller: controller,
                width: 55,
                height: 25,
                radius: 8,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ShimmerInfoRow(controller: controller, width: 145),
          const SizedBox(height: 12),
          _ShimmerInfoRow(controller: controller, width: 115),
          const SizedBox(height: 12),
          _ShimmerInfoRow(controller: controller, width: 170),
          const SizedBox(height: 12),
          _ShimmerInfoRow(controller: controller, width: 220),
          const SizedBox(height: 18),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            children: [
              _ShimmerBox(
                controller: controller,
                width: 90,
                height: 30,
                radius: 8,
              ),
              const Spacer(),
              _ShimmerBox(
                controller: controller,
                width: 32,
                height: 32,
                radius: 8,
              ),
              const SizedBox(width: 8),
              _ShimmerBox(
                controller: controller,
                width: 32,
                height: 32,
                radius: 8,
              ),
              const SizedBox(width: 8),
              _ShimmerBox(
                controller: controller,
                width: 32,
                height: 32,
                radius: 8,
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
          width: 18,
          height: 18,
          radius: 5,
        ),
        const SizedBox(width: 9),
        _ShimmerBox(
          controller: controller,
          width: width,
          height: 12,
          radius: 5,
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
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 400;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isUpdating ? null : onSelect,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(compact ? 13 : 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.location_copy,
                      color: primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      address.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'پیش‌فرض',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Iconsax.user_copy,
                text: address.receiverName,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Iconsax.call_copy,
                text: address.phone,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Iconsax.house_copy,
                text: '${address.province}، ${address.city}',
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.house_2_copy,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.address,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.7,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (address.postalCode != null &&
                  address.postalCode!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Iconsax.code_copy,
                  text: 'کد پستی: ${address.postalCode}',
                ),
              ],
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              _buildActions(context, compact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool compact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: isUpdating ? null : onSelect,
                icon: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                label: Text(
                  isSelected ? 'انتخاب شده' : 'انتخاب آدرس',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  _defaultMenu(),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: isUpdating ? null : onSelect,
                icon: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                label: Text(
                  isSelected ? 'انتخاب شده' : 'انتخاب',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            _defaultMenu(),
          ],
        );
      },
    );
  }

  Widget _defaultMenu() {
    return PopupMenuButton<String>(
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
              const SizedBox(width: 8),
              Text(
                address.isDefault
                    ? 'آدرس پیش‌فرض'
                    : 'تعیین به عنوان پیش‌فرض',
              ),
            ],
          ),
        ),
      ],
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
          size: 18,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.location_copy,
                          size: 45,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'هنوز آدرسی ثبت نکرده‌اید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'برای ثبت سفارش ابتدا یک آدرس برای ارسال محصولات اضافه کنید.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: onAddAddress,
                        icon: const Icon(Icons.add),
                        label: const Text('افزودن آدرس'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.information_copy,
                        size: 50,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'خطا در دریافت آدرس‌ها',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: onRetry,
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.information_copy,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.red.shade700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Iconsax.close_circle_copy),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
