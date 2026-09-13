import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/settings/data/models/admin_store_settings_model.dart';
import 'package:supastore/features/admin_feature/settings/domain/entities/admin_store_settings_entity.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/admin_store_settings_provider.dart';

class AdminStoreInfoPage extends StatelessWidget {
  const AdminStoreInfoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminStoreSettingsProvider>()
        ..loadSettings(),
      child: const _AdminStoreInfoView(),
    );
  }
}

class _AdminStoreInfoView extends StatefulWidget {
  const _AdminStoreInfoView();

  @override
  State<_AdminStoreInfoView> createState() =>
      _AdminStoreInfoViewState();
}

class _AdminStoreInfoViewState
    extends State<_AdminStoreInfoView> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final _instagramController = TextEditingController();
  final _telegramController = TextEditingController();
  final _websiteController = TextEditingController();

  final _legalNameController = TextEditingController();
  final _nationalIdController = TextEditingController();

  bool _controllersInitialized = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();

    _phoneController.dispose();
    _emailController.dispose();

    _addressController.dispose();
    _postalCodeController.dispose();

    _instagramController.dispose();
    _telegramController.dispose();
    _websiteController.dispose();

    _legalNameController.dispose();
    _nationalIdController.dispose();

    super.dispose();
  }

  void _fillControllers(
      AdminStoreSettingsEntity settings,
      ) {
    if (_controllersInitialized) {
      return;
    }

    _storeNameController.text = settings.storeName;
    _taglineController.text = settings.tagline ?? '';
    _descriptionController.text =
        settings.description ?? '';

    _phoneController.text = settings.phone ?? '';
    _emailController.text = settings.email ?? '';

    _addressController.text = settings.address ?? '';
    _postalCodeController.text =
        settings.postalCode ?? '';

    _instagramController.text =
        settings.instagram ?? '';
    _telegramController.text =
        settings.telegram ?? '';
    _websiteController.text =
        settings.website ?? '';

    _legalNameController.text =
        settings.legalName ?? '';
    _nationalIdController.text =
        settings.nationalId ?? '';

    _controllersInitialized = true;
  }

  Future<void> _save(
      BuildContext context,
      AdminStoreSettingsProvider provider,
      ) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final currentSettings = provider.settings;

    if (currentSettings == null) {
      return;
    }

    final updatedSettings = AdminStoreSettingsModel(
      id: currentSettings.id,
      storeName: _storeNameController.text.trim(),
      logoUrl: currentSettings.logoUrl,
      tagline: _taglineController.text.trim().isEmpty
          ? null
          : _taglineController.text.trim(),
      description:
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      postalCode:
      _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      instagram:
      _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      telegram:
      _telegramController.text.trim().isEmpty
          ? null
          : _telegramController.text.trim(),
      website:
      _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      legalName:
      _legalNameController.text.trim().isEmpty
          ? null
          : _legalNameController.text.trim(),
      nationalId:
      _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
      createdAt: currentSettings.createdAt,
      updatedAt: currentSettings.updatedAt,
    );

    final success = await provider.saveSettings(
      settings: updatedSettings,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اطلاعات فروشگاه با موفقیت ذخیره شد.',
          ),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
      );
    }
  }

  Future<void> _pickLogo(
      BuildContext context,
      AdminStoreSettingsProvider provider,
      ) async {
    if (provider.isLogoBusy) {
      return;
    }

    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();

    const maxSize = 5 * 1024 * 1024;

    if (bytes.length > maxSize) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حجم لوگو نباید بیشتر از 5 مگابایت باشد.',
          ),
        ),
      );

      return;
    }

    final extension = _getImageExtension(
      file.path,
    );

    final contentType = _getContentType(
      extension,
    );

    final success = await provider.updateLogo(
      bytes: Uint8List.fromList(bytes),
      extension: extension,
      contentType: contentType,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لوگوی فروشگاه با موفقیت تغییر کرد.',
          ),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
      );
    }
  }

  Future<void> _removeLogo(
      BuildContext context,
      AdminStoreSettingsProvider provider,
      ) async {
    if (provider.isLogoBusy) {
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'حذف لوگو',
          ),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید لوگوی فروشگاه حذف شود؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'انصراف',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'حذف',
              ),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!shouldRemove) {
      return;
    }

    final success = await provider.removeLogo();

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لوگوی فروشگاه حذف شد.',
          ),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error!,
          ),
        ),
      );
    }
  }

  String _getImageExtension(String path) {
    final value = path.toLowerCase();

    if (value.endsWith('.png')) {
      return 'png';
    }

    if (value.endsWith('.webp')) {
      return 'webp';
    }

    if (value.endsWith('.jpg') ||
        value.endsWith('.jpeg')) {
      return 'jpg';
    }

    return 'jpg';
  }

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      default:
        return 'image/jpeg';
    }
  }

  Future<void> _refresh(
      AdminStoreSettingsProvider provider,
      ) async {
    _controllersInitialized = false;
    await provider.loadSettings();
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
            'اطلاعات فروشگاه',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Consumer<AdminStoreSettingsProvider>(
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

            if (provider.error != null &&
                provider.settings == null) {
              return _buildErrorState(provider);
            }

            final settings = provider.settings;

            if (settings == null) {
              return _buildEmptyState(provider);
            }

            _fillControllers(settings);

            return RefreshIndicator(
              onRefresh: () => _refresh(provider),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    18.h,
                    16.w,
                    32.h,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'لوگوی فروشگاه',
                      ),
                      SizedBox(height: 10.h),
                      _buildLogoCard(
                        settings,
                        provider,
                      ),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'اطلاعات اصلی',
                      ),
                      SizedBox(height: 10.h),
                      _buildMainInfoCard(),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'اطلاعات تماس',
                      ),
                      SizedBox(height: 10.h),
                      _buildContactCard(),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'آدرس فروشگاه',
                      ),
                      SizedBox(height: 10.h),
                      _buildAddressCard(),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'شبکه‌های اجتماعی و وب‌سایت',
                      ),
                      SizedBox(height: 10.h),
                      _buildSocialCard(),

                      SizedBox(height: 22.h),

                      _buildSectionTitle(
                        'اطلاعات حقوقی',
                      ),
                      SizedBox(height: 10.h),
                      _buildLegalCard(),

                      SizedBox(height: 28.h),

                      _buildSaveButton(
                        context,
                        provider,
                      ),

                      SizedBox(height: 14.h),

                      _buildInfoText(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: Colors.red,
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
                  'اطلاعات فروشگاه',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'اطلاعاتی که در بخش‌های مختلف فروشگاه به کاربران نمایش داده می‌شود.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.6,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLogoCard(
      AdminStoreSettingsEntity settings,
      AdminStoreSettingsProvider provider,
      ) {
    final hasLogo =
        settings.logoUrl?.trim().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                  BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: hasLogo
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(22.r),
                  child: Image.network(
                    settings.logoUrl!,
                    width: 110.w,
                    height: 110.w,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Icon(
                        Icons
                            .storefront_outlined,
                        size: 50.sp,
                        color:
                        Colors.grey.shade400,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.storefront_outlined,
                  size: 50.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              if (hasLogo)
                Positioned(
                  top: -4.h,
                  right: -4.w,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: provider.isLogoBusy
                          ? null
                          : () => _removeLogo(
                        context,
                        provider,
                      ),
                      customBorder:
                      const CircleBorder(),
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child:
                        provider.isRemovingLogo
                            ? Padding(
                          padding:
                          EdgeInsets.all(
                            7.w,
                          ),
                          child:
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            hasLogo
                ? 'لوگوی فعلی فروشگاه'
                : 'لوگوی فروشگاه هنوز انتخاب نشده است',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'فرمت‌های پیشنهادی: PNG, JPG, WEBP',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: provider.isLogoBusy
                  ? null
                  : () => _pickLogo(
                context,
                provider,
              ),
              icon: provider.isUploadingLogo
                  ? SizedBox(
                width: 18.w,
                height: 18.w,
                child:
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
                  : const Icon(
                Icons.upload_outlined,
              ),
              label: Text(
                provider.isUploadingLogo
                    ? 'در حال آپلود...'
                    : hasLogo
                    ? 'تغییر لوگو'
                    : 'انتخاب لوگو',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(
                  color: Colors.red.withValues(
                    alpha: 0.4,
                  ),
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _storeNameController,
          label: 'نام فروشگاه',
          hint: 'مثلاً SupaStore',
          icon: Icons.storefront_outlined,
          requiredField: true,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _taglineController,
          label: 'شعار فروشگاه',
          hint: 'مثلاً خرید سریع و مطمئن',
          icon: Icons.auto_awesome_outlined,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _descriptionController,
          label: 'توضیحات فروشگاه',
          hint: 'توضیح کوتاهی درباره فروشگاه...',
          icon: Icons.description_outlined,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'شماره تماس',
          hint: '02112345678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _emailController,
          label: 'ایمیل',
          hint: 'info@example.com',
          icon: Icons.email_outlined,
          keyboardType:
          TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'آدرس کامل',
          hint: 'آدرس فروشگاه را وارد کنید',
          icon: Icons.location_on_outlined,
          maxLines: 4,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _postalCodeController,
          label: 'کد پستی',
          hint: '1234567890',
          icon: Icons.markunread_mailbox_outlined,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildSocialCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _instagramController,
          label: 'اینستاگرام',
          hint: '@supastore',
          icon: Icons.camera_alt_outlined,
          textDirection: TextDirection.ltr,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _telegramController,
          label: 'تلگرام',
          hint: '@supastore',
          icon: Icons.send_outlined,
          textDirection: TextDirection.ltr,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _websiteController,
          label: 'وب‌سایت',
          hint: 'https://example.com',
          icon: Icons.language_outlined,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildLegalCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _legalNameController,
          label: 'نام حقوقی / نام شرکت',
          hint: 'نام رسمی مجموعه',
          icon: Icons.business_outlined,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          controller: _nationalIdController,
          label: 'شناسه ملی / کد اقتصادی',
          hint: 'در صورت نیاز وارد کنید',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextDirection? textDirection,
  }) {
    Widget field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 21.sp,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.4,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade400,
        ),
      ),
      validator: requiredField
          ? (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'این فیلد الزامی است';
        }

        return null;
      }
          : null,
    );

    if (textDirection == null) {
      return field;
    }

    return Directionality(
      textDirection: textDirection,
      child: field,
    );
  }

  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        children: children,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18.r),
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
    );
  }

  Widget _buildSaveButton(
      BuildContext context,
      AdminStoreSettingsProvider provider,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: provider.isSaving
            ? null
            : () => _save(
          context,
          provider,
        ),
        icon: provider.isSaving
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child:
          const CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.save_outlined,
        ),
        label: Text(
          provider.isSaving
              ? 'در حال ذخیره...'
              : 'ذخیره اطلاعات',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          Colors.red.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Center(
      child: Text(
        'اطلاعات این بخش در قسمت‌های مختلف فروشگاه استفاده خواهد شد.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.sp,
          height: 1.6,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildErrorState(
      AdminStoreSettingsProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 50.sp,
              color: Colors.red,
            ),
            SizedBox(height: 12.h),
            Text(
              provider.error ??
                  'خطا در دریافت اطلاعات فروشگاه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              onPressed: provider.loadSettings,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'تلاش مجدد',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      AdminStoreSettingsProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 50.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              'اطلاعات فروشگاه پیدا نشد.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              onPressed: provider.loadSettings,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'تلاش مجدد',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}