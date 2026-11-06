
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/settings/data/models/admin_store_settings_model.dart';
import 'package:supastore/features/admin_feature/settings/domain/entities/admin_store_settings_entity.dart';
import 'package:supastore/features/admin_feature/settings/presentation/provider/admin_store_settings_provider.dart';

class AdminStoreInfoPage extends StatelessWidget {
  const AdminStoreInfoPage({super.key});

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

class _AdminStoreInfoViewState extends State<_AdminStoreInfoView> {
  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF023E8A);
  static const Color _accentColor = Color(0xFF0077B6);
  static const Color _backgroundColor = Color(0xFFF7F7F8);
  static const Color _dangerColor = Color(0xFFE21B23);

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

  void _fillControllers(AdminStoreSettingsEntity settings) {
    if (_controllersInitialized) {
      return;
    }

    _storeNameController.text = settings.storeName;
    _taglineController.text = settings.tagline ?? '';
    _descriptionController.text = settings.description ?? '';

    _phoneController.text = settings.phone ?? '';
    _emailController.text = settings.email ?? '';

    _addressController.text = settings.address ?? '';
    _postalCodeController.text = settings.postalCode ?? '';

    _instagramController.text = settings.instagram ?? '';
    _telegramController.text = settings.telegram ?? '';
    _websiteController.text = settings.website ?? '';

    _legalNameController.text = settings.legalName ?? '';
    _nationalIdController.text = settings.nationalId ?? '';

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
      description: _descriptionController.text.trim().isEmpty
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
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      instagram: _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      telegram: _telegramController.text.trim().isEmpty
          ? null
          : _telegramController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      legalName: _legalNameController.text.trim().isEmpty
          ? null
          : _legalNameController.text.trim(),
      nationalId: _nationalIdController.text.trim().isEmpty
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
      _showMessage(
        context,
        'اطلاعات فروشگاه با موفقیت ذخیره شد.',
      );
    } else if (provider.error != null) {
      _showMessage(context, provider.error!);
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

      _showMessage(
        context,
        'حجم لوگو نباید بیشتر از 5 مگابایت باشد.',
      );

      return;
    }

    final extension = _getImageExtension(file.path);
    final contentType = _getContentType(extension);

    final success = await provider.updateLogo(
      bytes: Uint8List.fromList(bytes),
      extension: extension,
      contentType: contentType,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      _showMessage(
        context,
        'لوگوی فروشگاه با موفقیت تغییر کرد.',
      );
    } else if (provider.error != null) {
      _showMessage(context, provider.error!);
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
          title: const Text('حذف لوگو'),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید لوگوی فروشگاه حذف شود؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
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
      _showMessage(context, 'لوگوی فروشگاه حذف شد.');
    } else if (provider.error != null) {
      _showMessage(context, provider.error!);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _getImageExtension(String path) {
    final value = path.toLowerCase();

    if (value.endsWith('.png')) {
      return 'png';
    }

    if (value.endsWith('.webp')) {
      return 'webp';
    }

    if (value.endsWith('.jpg') || value.endsWith('.jpeg')) {
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
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'اطلاعات فروشگاه',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Consumer<AdminStoreSettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.settings == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                ),
              );
            }

            if (provider.error != null && provider.settings == null) {
              return _buildErrorState(provider);
            }

            final settings = provider.settings;

            if (settings == null) {
              return _buildEmptyState(provider);
            }

            _fillControllers(settings);

            return RefreshIndicator(
              color: _primaryColor,
              onRefresh: () => _refresh(provider),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final horizontalPadding = width >= 1200
                        ? 32.0
                        : width >= 700
                        ? 24.0
                        : 16.0;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        36,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1280,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPageHeader(width),

                              const SizedBox(height: 24),

                              _buildSectionTitle('لوگوی فروشگاه'),
                              const SizedBox(height: 12),

                              _buildLogoCard(settings, provider),

                              const SizedBox(height: 28),

                              _buildResponsiveSections(width),

                              const SizedBox(height: 30),

                              _buildSaveButton(context, provider),

                              const SizedBox(height: 16),

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
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Responsive sections
  // ---------------------------------------------------------------------------

  Widget _buildResponsiveSections(double width) {
    final isWide = width >= 760;

    final sections = [
      _buildSection(
        'اطلاعات اصلی',
        _buildMainInfoCard(),
      ),
      _buildSection(
        'اطلاعات تماس',
        _buildContactCard(),
      ),
      _buildSection(
        'آدرس فروشگاه',
        _buildAddressCard(),
      ),
      _buildSection(
        'شبکه‌های اجتماعی و وب‌سایت',
        _buildSocialCard(),
      ),
      _buildSection(
        'اطلاعات حقوقی',
        _buildLegalCard(),
      ),
    ];

    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < sections.length; i++) ...[
            sections[i],
            if (i != sections.length - 1)
              const SizedBox(height: 22),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 20.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 22,
          children: sections.map((section) {
            return SizedBox(
              width: itemWidth,
              child: section,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        card,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildPageHeader(double width) {
    final isMobile = width < 500;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: _cardDecoration(radius: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 48 : 58,
            height: isMobile ? 48 : 58,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.shop_copy,
              color: _primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اطلاعات فروشگاه',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اطلاعاتی که در بخش‌های مختلف فروشگاه به کاربران نمایش داده می‌شود.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    height: 1.8,
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Logo
  // ---------------------------------------------------------------------------

  Widget _buildLogoCard(
      AdminStoreSettingsEntity settings,
      AdminStoreSettingsProvider provider,
      ) {
    final hasLogo = settings.logoUrl?.trim().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final logoPreview = Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: hasLogo
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    settings.logoUrl!,
                    width: 112,
                    height: 112,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Iconsax.shop_copy,
                        size: 50,
                        color: Colors.grey.shade400,
                      );
                    },
                  ),
                )
                    : Icon(
                  Iconsax.shop_copy,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
              if (hasLogo)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: provider.isLogoBusy
                          ? null
                          : () => _removeLogo(context, provider),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _dangerColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: provider.isRemovingLogo
                            ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );

          final details = Column(
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                hasLogo
                    ? 'لوگوی فعلی فروشگاه'
                    : 'لوگوی فروشگاه هنوز انتخاب نشده است',
                textAlign: isWide ? TextAlign.right : TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'فرمت‌های پیشنهادی: PNG, JPG, WEBP',
                textAlign: isWide ? TextAlign.right : TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: provider.isLogoBusy
                      ? null
                      : () => _pickLogo(context, provider),
                  icon: provider.isUploadingLogo
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _dangerColor,
                    ),
                  )
                      : const Icon(
                    Iconsax.document_upload_copy,
                    size: 19,
                  ),
                  label: Text(
                    provider.isUploadingLogo
                        ? 'در حال آپلود...'
                        : hasLogo
                        ? 'تغییر لوگو'
                        : 'انتخاب لوگو',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _dangerColor,
                    side: BorderSide(
                      color: _dangerColor.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                logoPreview,
                const SizedBox(width: 24),
                Expanded(child: details),
              ],
            );
          }

          return Column(
            children: [
              logoPreview,
              const SizedBox(height: 14),
              details,
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main information
  // ---------------------------------------------------------------------------

  Widget _buildMainInfoCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _storeNameController,
          label: 'نام فروشگاه',
          hint: 'مثلاً SupaStore',
          icon: Iconsax.shop_copy,
          requiredField: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _taglineController,
          label: 'شعار فروشگاه',
          hint: 'مثلاً خرید سریع و مطمئن',
          icon: Iconsax.cloud_lightning_copy,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'توضیحات فروشگاه',
          hint: 'توضیح کوتاهی درباره فروشگاه...',
          icon: Iconsax.message_copy,
          maxLines: 4,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Contact
  // ---------------------------------------------------------------------------

  Widget _buildContactCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'شماره تماس',
          hint: '02112345678',
          icon: Iconsax.call_copy,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'ایمیل',
          hint: 'info@example.com',
          icon: Iconsax.message_2_copy,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Address
  // ---------------------------------------------------------------------------

  Widget _buildAddressCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'آدرس کامل',
          hint: 'آدرس فروشگاه را وارد کنید',
          icon: Iconsax.location_copy,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeController,
          label: 'کد پستی',
          hint: '1234567890',
          icon: Iconsax.code_copy,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Social
  // ---------------------------------------------------------------------------

  Widget _buildSocialCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _instagramController,
          label: 'اینستاگرام',
          hint: '@supastore',
          icon: Iconsax.instagram_copy,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _telegramController,
          label: 'تلگرام',
          hint: '@supastore',
          icon: Iconsax.send_1_copy,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _websiteController,
          label: 'وب‌سایت',
          hint: 'https://example.com',
          icon: Iconsax.link_1_copy,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Legal
  // ---------------------------------------------------------------------------

  Widget _buildLegalCard() {
    return _buildCard(
      children: [
        _buildTextField(
          controller: _legalNameController,
          label: 'نام حقوقی / نام شرکت',
          hint: 'نام رسمی مجموعه',
          icon: Iconsax.house_2_copy,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalIdController,
          label: 'شناسه ملی / کد اقتصادی',
          hint: 'در صورت نیاز وارد کنید',
          icon: Iconsax.code_copy,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Text fields
  // ---------------------------------------------------------------------------

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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 21,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: _primaryColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.4,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
      ),
      validator: requiredField
          ? (value) {
        if (value == null || value.trim().isEmpty) {
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

  // ---------------------------------------------------------------------------
  // Card decoration
  // ---------------------------------------------------------------------------

  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  BoxDecoration _cardDecoration({
    double radius = 18,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
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
    );
  }

  // ---------------------------------------------------------------------------
  // Save button
  // ---------------------------------------------------------------------------

  Widget _buildSaveButton(
      BuildContext context,
      AdminStoreSettingsProvider provider,
      ) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: provider.isSaving
                ? null
                : () => _save(context, provider),
            icon: provider.isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.save_outlined,
              size: 21,
            ),
            label: Text(
              provider.isSaving
                  ? 'در حال ذخیره...'
                  : 'ذخیره اطلاعات',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _secondaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              _secondaryColor.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildInfoText() {
    return Center(
      child: Text(
        'اطلاعات این بخش در قسمت‌های مختلف فروشگاه استفاده خواهد شد.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          height: 1.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(
      AdminStoreSettingsProvider provider,
      ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 440,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: Colors.red,
              ),
              const SizedBox(height: 14),
              Text(
                provider.error ?? 'خطا در دریافت اطلاعات فروشگاه',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: provider.loadSettings,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش مجدد'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(
      AdminStoreSettingsProvider provider,
      ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'اطلاعات فروشگاه پیدا نشد.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: provider.loadSettings,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش مجدد'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
