import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/domain/entities/admin_general_settings_entity.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/presentation/providers/admin_general_settings_provider.dart';

class AdminGeneralSettingsPage extends StatelessWidget {
  const AdminGeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminGeneralSettingsProvider>()
        ..loadSettings(),
      child: const _AdminGeneralSettingsView(),
    );
  }
}

class _AdminGeneralSettingsView extends StatefulWidget {
  const _AdminGeneralSettingsView();

  @override
  State<_AdminGeneralSettingsView> createState() =>
      _AdminGeneralSettingsViewState();
}

class _AdminGeneralSettingsViewState
    extends State<_AdminGeneralSettingsView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _appNameController;
  late final TextEditingController _minimumOrderController;
  late final TextEditingController _maxCartQuantityController;
  late final TextEditingController _maintenanceMessageController;

  bool _controllersInitialized = false;

  bool _maintenanceMode = false;
  bool _registrationEnabled = true;
  bool _shoppingEnabled = true;
  bool _showUnavailableProducts = true;
  bool _reviewsEnabled = true;
  bool _verifiedPurchaseReviewsOnly = false;

  @override
  void initState() {
    super.initState();

    _appNameController = TextEditingController();
    _minimumOrderController = TextEditingController();
    _maxCartQuantityController = TextEditingController();
    _maintenanceMessageController = TextEditingController();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _minimumOrderController.dispose();
    _maxCartQuantityController.dispose();
    _maintenanceMessageController.dispose();
    super.dispose();
  }

  void _initializeControllers(
      AdminGeneralSettingsEntity settings,
      ) {
    if (_controllersInitialized) {
      return;
    }

    _controllersInitialized = true;

    _appNameController.text = settings.appName;
    _minimumOrderController.text =
        settings.minimumOrderAmount.toString();
    _maxCartQuantityController.text =
        settings.maxCartQuantity.toString();
    _maintenanceMessageController.text =
        settings.maintenanceMessage;

    _maintenanceMode = settings.maintenanceMode;
    _registrationEnabled = settings.registrationEnabled;
    _shoppingEnabled = settings.shoppingEnabled;
    _showUnavailableProducts =
        settings.showUnavailableProducts;
    _reviewsEnabled = settings.reviewsEnabled;
    _verifiedPurchaseReviewsOnly =
        settings.verifiedPurchaseReviewsOnly;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
    context.read<AdminGeneralSettingsProvider>();

    final currentSettings = provider.settings;

    if (currentSettings == null) {
      return;
    }

    final minimumOrderAmount =
        int.tryParse(
          _minimumOrderController.text.trim(),
        ) ??
            0;

    final maxCartQuantity =
        int.tryParse(
          _maxCartQuantityController.text.trim(),
        ) ??
            20;

    final updatedSettings =
    AdminGeneralSettingsEntity(
      id: currentSettings.id,
      appName: _appNameController.text.trim(),
      maintenanceMode: _maintenanceMode,
      registrationEnabled: _registrationEnabled,
      shoppingEnabled: _shoppingEnabled,
      showUnavailableProducts:
      _showUnavailableProducts,
      reviewsEnabled: _reviewsEnabled,
      verifiedPurchaseReviewsOnly:
      _verifiedPurchaseReviewsOnly,
      minimumOrderAmount:
      minimumOrderAmount,
      maxCartQuantity:
      maxCartQuantity,
      maintenanceMessage:
      _maintenanceMessageController.text.trim(),
      createdAt: currentSettings.createdAt,
      updatedAt: currentSettings.updatedAt,
      singleton: currentSettings.singleton,
    );

    final success =
    await provider.saveSettings(
      settings: updatedSettings,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تنظیمات عمومی با موفقیت ذخیره شد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'تنظیمات عمومی سیستم',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<AdminGeneralSettingsProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoading &&
              provider.settings == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.settings == null) {
            return _ErrorView(
              message:
              provider.error ??
                  'تنظیمات عمومی سیستم دریافت نشد.',
              onRetry: provider.loadSettings,
            );
          }

          _initializeControllers(
            provider.settings!,
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _SectionCard(
                  title: 'تنظیمات اصلی',
                  icon: Icons.settings_outlined,
                  children: [
                    _TextField(
                      controller:
                      _appNameController,
                      label: 'نام اپلیکیشن',
                      hint: 'SupaStore',
                      icon:
                      Icons.apps_outlined,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'نام اپلیکیشن را وارد کنید.';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),
                    _SwitchTile(
                      title: 'حالت تعمیرات',
                      subtitle:
                      'فروشگاه موقتاً از دسترس کاربران خارج شود.',
                      value: _maintenanceMode,
                      onChanged: (value) {
                        setState(() {
                          _maintenanceMode = value;
                        });
                      },
                    ),

                    _SwitchTile(
                      title: 'خرید کاربران',
                      subtitle:
                      'اجازه ثبت سفارش جدید.',
                      value: _shoppingEnabled,
                      onChanged: (value) {
                        setState(() {
                          _shoppingEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                _SectionCard(
                  title: 'سفارش‌ها',
                  icon:
                  Icons.receipt_long_outlined,
                  children: [
                    _TextField(
                      controller:
                      _minimumOrderController,
                      label:
                      'حداقل مبلغ سفارش',
                      hint: '0',
                      icon:
                      Icons.payments_outlined,
                      keyboardType:
                      TextInputType.number,
                      suffixText: 'تومان',
                      validator: (value) {
                        final number =
                        int.tryParse(
                          value?.trim() ?? '',
                        );

                        if (number == null ||
                            number < 0) {
                          return 'مبلغ معتبر وارد کنید.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'حالت تعمیرات',
                  icon:
                  Icons.build_outlined,
                  children: [
                    _TextField(
                      controller:
                      _maintenanceMessageController,
                      label:
                      'پیام حالت تعمیرات',
                      hint:
                      'فروشگاه در حال بروزرسانی است.',
                      icon:
                      Icons.message_outlined,
                      maxLines: 4,
                      validator: (value) {
                        if (_maintenanceMode &&
                            (value == null ||
                                value
                                    .trim()
                                    .isEmpty)) {
                          return 'پیام حالت تعمیرات را وارد کنید.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed:
                    provider.isSaving
                        ? null
                        : _save,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor:
                      Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                      ),
                    ),
                    child: provider.isSaving
                        ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : Text(
                      'ذخیره تنظیمات',
                      style:
                      AppTextStyles.button,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color:
          Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style:
                AppTextStyles.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.body,
      ),
      subtitle: Padding(
        padding:
        EdgeInsets.only(top: 4.h),
        child: Text(
          subtitle,
          style: AppTextStyles.body,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor:
      AppColors.primary,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixText,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? suffixText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12.r),
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
        padding:
        EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              AppTextStyles.body,
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