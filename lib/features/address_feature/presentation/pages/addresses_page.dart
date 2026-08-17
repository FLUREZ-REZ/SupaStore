import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/presentation/pages/add_edit_address_page.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید.',
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
      getIt<AddressProvider>()
        ..loadAddresses(
          userId: user.id,
        ),
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
    final provider =
    context.watch<AddressProvider>();

    final user =
        Supabase.instance.client.auth.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Colors.grey.shade50,

        appBar: AppBar(
          title: const Text(
            'آدرس‌های من',
          ),
          centerTitle: true,
        ),

        body: user == null
            ? const Center(
          child: Text(
            'لطفاً وارد حساب کاربری شوید.',
          ),
        )
            : _buildBody(
          context,
          provider,
          user.id,
        ),

        floatingActionButton:
        FloatingActionButton.extended(
          onPressed:
          provider.isUpdating
              ? null
              : () async {
            await _openAddAddressPage(
              context,
            );
          },
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'افزودن آدرس',
          ),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null &&
        provider.addresses.isEmpty) {
      return _ErrorState(
        message: provider.error!,
        onRetry: () {
          provider.loadAddresses(
            userId: userId,
          );
        },
      );
    }

    if (provider.addresses.isEmpty) {
      return _EmptyState(
        onAddAddress: () {
          _openAddAddressPage(
            context,
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return provider.refresh(
          userId: userId,
        );
      },
      child: ListView(
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

          if (provider.error != null)
            SizedBox(
              height: 10.h,
            ),

          Text(
            'آدرس‌های شما',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 6.h,
          ),

          Text(
            'آدرس موردنظر خود را برای ارسال سفارش انتخاب کنید.',
            style: TextStyle(
              fontSize: 12.sp,
              color:
              Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: 16.h,
          ),

          ...provider.addresses.map(
                (address) {
              return Padding(
                padding:
                EdgeInsets.only(
                  bottom: 12.h,
                ),
                child: _AddressCard(
                  address: address,
                  isSelected:
                  provider
                      .selectedAddress
                      ?.id ==
                      address.id,
                  isUpdating:
                  provider.isUpdating,
                  onSelect: () {
                    provider.selectAddress(
                      address,
                    );
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
                    await _editAddress(
                      context,
                      address,
                    );
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
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADD
  // =========================================================

  Future<void> _openAddAddressPage(
      BuildContext context,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AddEditAddressPage(),
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
        builder: (_) =>
            AddEditAddressPage(
              address: address,
            ),
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
    if (address.isDefault) {
      return;
    }

    final success =
    await provider.setDefaultAddress(
      addressId: address.id,
      userId: userId,
    );

    if (!context.mounted) {
      return;
    }

    if (!success &&
        provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
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
    final shouldDelete =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection:
          TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حذف آدرس',
            ),
            content: Text(
              'آیا مطمئن هستید که می‌خواهید آدرس «${address.title}» را حذف کنید؟',
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
                child: Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final success =
    await provider.deleteAddress(
      addressId: address.id,
      userId: userId,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'آدرس با موفقیت حذف شد.',
          ),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
      );
    }
  }
}

// =========================================================
// ADDRESS CARD
// =========================================================

class _AddressCard
    extends StatelessWidget {
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
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(
        18.r,
      ),
      child: InkWell(
        onTap: isUpdating
            ? null
            : onSelect,
        borderRadius:
        BorderRadius.circular(
          18.r,
        ),
        child: Container(
          padding:
          EdgeInsets.all(16.w),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              18.r,
            ),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context)
                  .colorScheme
                  .primary
                  : Colors.grey
                  .shade200,
              width:
              isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // =================================================
              // HEADER
              // =================================================

              Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration:
                    BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary
                          .withValues(
                        alpha: 0.08,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child: Icon(
                      Icons
                          .location_on_outlined,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                      size: 23.sp,
                    ),
                  ),

                  SizedBox(
                    width: 12.w,
                  ),

                  Expanded(
                    child: Text(
                      address.title,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  if (address.isDefault)
                    Container(
                      padding:
                      EdgeInsets
                          .symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors
                            .green
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          8.r,
                        ),
                      ),
                      child: Text(
                        'پیش‌فرض',
                        style:
                        TextStyle(
                          fontSize: 10.sp,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Colors.green,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(
                height: 14.h,
              ),

              // =================================================
              // RECEIVER
              // =================================================

              _InfoRow(
                icon:
                Icons.person_outline,
                text:
                address.receiverName,
              ),

              SizedBox(
                height: 8.h,
              ),

              // =================================================
              // PHONE
              // =================================================

              _InfoRow(
                icon:
                Icons.phone_outlined,
                text: address.phone,
              ),

              SizedBox(
                height: 8.h,
              ),

              // =================================================
              // ADDRESS
              // =================================================

              _InfoRow(
                icon: Icons
                    .location_city_outlined,
                text:
                '${address.province}، ${address.city}',
              ),

              SizedBox(
                height: 8.h,
              ),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Icon(
                    Icons
                        .home_outlined,
                    size: 18.sp,
                    color: Colors
                        .grey
                        .shade500,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: Text(
                      address.address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.7,
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),
                  ),
                ],
              ),

              if (address.postalCode !=
                  null &&
                  address.postalCode!
                      .isNotEmpty) ...[
                SizedBox(
                  height: 8.h,
                ),
                _InfoRow(
                  icon: Icons
                      .markunread_mailbox_outlined,
                  text:
                  'کد پستی: ${address.postalCode}',
                ),
              ],

              SizedBox(
                height: 14.h,
              ),

              const Divider(
                height: 1,
              ),

              SizedBox(
                height: 8.h,
              ),

              // =================================================
              // ACTIONS
              // =================================================

              Row(
                children: [
                  // انتخاب
                  Expanded(
                    child: TextButton.icon(
                      onPressed:
                      isUpdating
                          ? null
                          : onSelect,
                      icon: Icon(
                        isSelected
                            ? Icons
                            .radio_button_checked
                            : Icons
                            .radio_button_unchecked,
                        size: 18.sp,
                      ),
                      label: Text(
                        isSelected
                            ? 'انتخاب شده'
                            : 'انتخاب',
                      ),
                    ),
                  ),

                  // ویرایش
                  IconButton(
                    onPressed:
                    isUpdating
                        ? null
                        : onEdit,
                    tooltip: 'ویرایش',
                    icon: const Icon(
                      Icons
                          .edit_outlined,
                    ),
                  ),

                  // حذف
                  IconButton(
                    onPressed:
                    isUpdating
                        ? null
                        : onDelete,
                    tooltip: 'حذف',
                    icon: Icon(
                      Icons
                          .delete_outline,
                      color: Colors
                          .red
                          .shade400,
                    ),
                  ),

                  PopupMenuButton<String>(
                    enabled:
                    !isUpdating,
                    onSelected:
                        (value) {
                      if (value ==
                          'default') {
                        onSetDefault();
                      }
                    },
                    itemBuilder:
                        (context) {
                      return [
                        PopupMenuItem<
                            String>(
                          value:
                          'default',
                          enabled:
                          !address
                              .isDefault,
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .check_circle_outline,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                address.isDefault
                                    ? 'آدرس پیش‌فرض'
                                    : 'تعیین به عنوان پیش‌فرض',
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
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

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Colors.grey.shade500,
        ),
        SizedBox(
          width: 8.w,
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color:
              Colors.grey.shade700,
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

class _EmptyState
    extends StatelessWidget {
  const _EmptyState({
    required this.onAddAddress,
  });

  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          horizontal: 32.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration:
              BoxDecoration(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary
                    .withValues(
                  alpha: 0.08,
                ),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .location_on_outlined,
                size: 45.sp,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary,
              ),
            ),

            SizedBox(
              height: 20.h,
            ),

            Text(
              'هنوز آدرسی ثبت نکرده‌اید',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Text(
              'برای ثبت سفارش ابتدا یک آدرس برای ارسال محصولات اضافه کنید.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.7,
                color: Colors
                    .grey
                    .shade600,
              ),
            ),

            SizedBox(
              height: 20.h,
            ),

            ElevatedButton.icon(
              onPressed:
              onAddAddress,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'افزودن آدرس',
              ),
              style:
              ElevatedButton.styleFrom(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 12.h,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    12.r,
                  ),
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

class _ErrorState
    extends StatelessWidget {
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
        padding:
        EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .error_outline,
              size: 50.sp,
              color:
              Colors.red.shade400,
            ),

            SizedBox(
              height: 14.h,
            ),

            Text(
              'خطا در دریافت آدرس‌ها',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors
                    .grey
                    .shade600,
              ),
            ),

            SizedBox(
              height: 18.h,
            ),

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

// =========================================================
// ERROR BANNER
// =========================================================

class _ErrorBanner
    extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onClose,
  });

  final String message;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      EdgeInsets.all(12.w),
      decoration:
      BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons
                .error_outline,
            color:
            Colors.red.shade600,
            size: 20.sp,
          ),

          SizedBox(
            width: 8.w,
          ),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.sp,
                color:
                Colors.red.shade700,
              ),
            ),
          ),

          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
            ),
            iconSize: 18.sp,
            padding:
            EdgeInsets.zero,
            constraints:
            const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}