
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';

import '../../domain/entities/admin_banner_entity.dart';
import '../providers/admin_banner_provider.dart';

class AdminBannerFormPage extends StatelessWidget {
  const AdminBannerFormPage({
    super.key,
    this.banner,
  });

  final AdminBannerEntity? banner;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminBannerProvider>(
      create: (_) => getIt<AdminBannerProvider>(),
      child: _AdminBannerFormView(
        banner: banner,
      ),
    );
  }
}

class _AdminBannerFormView extends StatefulWidget {
  const _AdminBannerFormView({
    required this.banner,
  });

  final AdminBannerEntity? banner;

  @override
  State<_AdminBannerFormView> createState() =>
      _AdminBannerFormViewState();
}

class _AdminBannerFormViewState
    extends State<_AdminBannerFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _actionValueController;
  late final TextEditingController _sortOrderController;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;

  late String _bannerType;
  late String _actionType;

  bool _isActive = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isProcessingImage = false;

  static const List<String> _validBannerTypes = [
    'hero',
    'promotional',
    'bottom_home',
  ];

  static const List<String> _validActionTypes = [
    'none',
    'product',
    'category',
    'url',
  ];

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  @override
  void initState() {
    super.initState();

    final banner = widget.banner;

    _titleController = TextEditingController(
      text: banner?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: banner?.description ?? '',
    );

    _actionValueController = TextEditingController(
      text: banner?.actionValue ?? '',
    );

    _sortOrderController = TextEditingController(
      text: '${banner?.sortOrder ?? 0}',
    );

    final databaseBannerType = banner?.bannerType;

    _bannerType = databaseBannerType != null &&
        _validBannerTypes.contains(databaseBannerType)
        ? databaseBannerType
        : 'hero';

    final databaseActionType = banner?.actionType;

    _actionType = databaseActionType != null &&
        _validActionTypes.contains(databaseActionType)
        ? databaseActionType
        : 'none';

    _isActive = banner?.isActive ?? true;
    _startDate = banner?.startDate;
    _endDate = banner?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _actionValueController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  int get _targetWidth => 1700;

  int get _targetHeight {
    switch (_bannerType) {
      case 'promotional':
        return 1200;
      case 'hero':
      case 'bottom_home':
      default:
        return 850;
    }
  }

  String get _bannerSizeText =>
      '$_targetWidth × $_targetHeight px';

  String get _bannerTypeTitle {
    switch (_bannerType) {
      case 'hero':
        return 'بنر هیرو';
      case 'promotional':
        return 'بنر تبلیغاتی';
      case 'bottom_home':
        return 'بنر پایین صفحه';
      default:
        return 'بنر';
    }
  }

  // ============================================================
  // IMAGE PICK
  // ============================================================

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final processedImage = await _processBannerImage(picked);

      if (!mounted) return;

      if (processedImage == null) {
        _showMessage('پردازش تصویر انجام نشد.');
        return;
      }

      setState(() {
        _selectedImage = processedImage;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('خطا در پردازش تصویر.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  // ============================================================
  // IMAGE PROCESS
  // ============================================================

  Future<XFile?> _processBannerImage(XFile source) async {
    final bytes = await source.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) return null;

    final sourceWidth = decoded.width;
    final sourceHeight = decoded.height;

    final targetWidth = _targetWidth;
    final targetHeight = _targetHeight;

    final targetRatio = targetWidth / targetHeight;
    final sourceRatio = sourceWidth / sourceHeight;

    late img.Image cropped;

    if (sourceRatio > targetRatio) {
      final cropWidth =
      (sourceHeight * targetRatio).round();

      final offsetX =
      ((sourceWidth - cropWidth) / 2).round();

      cropped = img.copyCrop(
        decoded,
        x: offsetX,
        y: 0,
        width: cropWidth,
        height: sourceHeight,
      );
    } else {
      final cropHeight =
      (sourceWidth / targetRatio).round();

      final offsetY =
      ((sourceHeight - cropHeight) / 2).round();

      cropped = img.copyCrop(
        decoded,
        x: 0,
        y: offsetY,
        width: sourceWidth,
        height: cropHeight,
      );
    }

    final resized = img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.cubic,
    );

    final Uint8List webpBytes = Uint8List.fromList(
      img.encodeWebP(
        resized,
        quality: 82,
      ),
    );

    final tempDirectory = Directory.systemTemp;

    final fileName =
        'banner_${DateTime.now().millisecondsSinceEpoch}.webp';

    final file = File(
      '${tempDirectory.path}/$fileName',
    );

    await file.writeAsBytes(
      webpBytes,
      flush: true,
    );

    return XFile(
      file.path,
      name: fileName,
      mimeType: 'image/webp',
      bytes: webpBytes,
    );
  }

  // ============================================================
  // DATE PICKERS
  // ============================================================

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );

    if (picked == null || !mounted) return;

    final pickedTime = _startDate != null
        ? TimeOfDay(
      hour: _startDate!.hour,
      minute: _startDate!.minute,
    )
        : const TimeOfDay(hour: 0, minute: 0);

    setState(() {
      _startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );

    if (picked == null || !mounted) return;

    final pickedTime = _endDate != null
        ? TimeOfDay(
      hour: _endDate!.hour,
      minute: _endDate!.minute,
    )
        : const TimeOfDay(hour: 23, minute: 59);

    setState(() {
      _endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.banner != null;

    final provider = context.read<AdminBannerProvider>();

    if (_bannerType == 'promotional') {
      final promotionalCount = provider.banners
          .where((item) => item.bannerType == 'promotional')
          .where((item) => item.id != widget.banner?.id)
          .length;

      if (promotionalCount >= 4) {
        _showMessage(
          'حداکثر ۴ بنر تبلیغاتی می‌توانید داشته باشید.',
        );
        return;
      }
    }

    if (!isEditing && _selectedImage == null) {
      _showMessage('برای بنر جدید تصویر انتخاب کنید.');
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _showMessage(
        'تاریخ پایان نمی‌تواند قبل از تاریخ شروع باشد.',
      );
      return;
    }

    final actionType =
    _actionType == 'none' ? null : _actionType;

    final actionValue = actionType == null
        ? null
        : _actionValueController.text.trim().isEmpty
        ? null
        : _actionValueController.text.trim();

    if (actionType != null &&
        (actionValue == null || actionValue.isEmpty)) {
      _showMessage('مقدار عملکرد بنر را وارد کنید.');
      return;
    }

    final sortOrder = int.tryParse(
      _sortOrderController.text.trim(),
    );

    if (sortOrder == null) {
      _showMessage('ترتیب نمایش معتبر نیست.');
      return;
    }

    bool success;

    if (isEditing) {
      final banner = widget.banner!;

      success = await provider.updateBanner(
        bannerId: banner.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        newImage: _selectedImage,
        currentImagePath: banner.imagePath,
        bannerType: _bannerType,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      success = await provider.createBanner(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        image: _selectedImage!,
        bannerType: _bannerType,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    if (!mounted) return;

    if (!success) {
      _showMessage(
        provider.errorMessage ?? 'ذخیره بنر انجام نشد.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'انتخاب نشده';

    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildSection({
    required Widget child,
  }) {
    return _SectionContainer(child: child);
  }

  Widget _buildImageSection(
      AdminBannerProvider provider,
      bool isEditing,
      double width,
      ) {
    final imageHeight = width < 600 ? 175.0 : 230.0;

    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تصویر بنر',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_bannerTypeTitle • سایز نهایی $_bannerSizeText',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: _primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تصویر پس از انتخاب به صورت خودکار برش داده شده، '
                'به این ابعاد تبدیل و با فرمت WebP ذخیره می‌شود.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: _buildImagePreview(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: provider.isSaving || _isProcessingImage
                ? null
                : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              isEditing ? 'جایگزینی تصویر' : 'انتخاب تصویر',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isProcessingImage) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (widget.banner != null) {
      return Image.network(
        widget.banner!.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 44,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _SectionContainer(
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'عنوان بنر',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'عنوان بنر را وارد کنید.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            textDirection: TextDirection.rtl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'توضیحات',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerTypeSection(AdminBannerProvider provider) {
    return Column(
      children: [
        _SectionContainer(
          child: DropdownButtonFormField<String>(
            value: _bannerType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'نوع بنر',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'hero',
                child: Text('هیرو'),
              ),
              DropdownMenuItem(
                value: 'promotional',
                child: Text('تبلیغاتی'),
              ),
              DropdownMenuItem(
                value: 'bottom_home',
                child: Text('بنر پایین صفحه'),
              ),
            ],
            onChanged: provider.isSaving
                ? null
                : (value) {
              if (value == null) return;
              setState(() {
                _bannerType = value;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        _BannerInfoBox(bannerType: _bannerType),
      ],
    );
  }

  Widget _buildActionSection(AdminBannerProvider provider) {
    return _SectionContainer(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _actionType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'عملکرد هنگام کلیک',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'none',
                child: Text('بدون عملکرد'),
              ),
              DropdownMenuItem(
                value: 'product',
                child: Text('باز کردن محصول'),
              ),
              DropdownMenuItem(
                value: 'category',
                child: Text('باز کردن دسته‌بندی'),
              ),
              DropdownMenuItem(
                value: 'url',
                child: Text('لینک'),
              ),
            ],
            onChanged: provider.isSaving
                ? null
                : (value) {
              if (value == null) return;
              setState(() {
                _actionType = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _actionValueController,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'مقدار عملکرد',
              hintText: 'شناسه محصول / دسته‌بندی / URL',
              border: OutlineInputBorder(),
            ),
          ),
          if (_actionType == 'url') ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'توجه: در حال حاضر Navigation لینک در اپ فعال نشده است.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSortOrderSection() {
    return _SectionContainer(
      child: TextFormField(
        controller: _sortOrderController,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'ترتیب نمایش',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatesSection(AdminBannerProvider provider) {
    return _SectionContainer(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تاریخ شروع'),
            subtitle: Text(_formatDate(_startDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: provider.isSaving ? null : _pickStartDate,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تاریخ پایان'),
            subtitle: Text(_formatDate(_endDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: provider.isSaving ? null : _pickEndDate,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
      AdminBannerProvider provider,
      bool isEditing,
      ) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: provider.isSaving || _isProcessingImage
            ? null
            : _submit,
        child: provider.isSaving
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(
          isEditing ? 'ذخیره تغییرات' : 'افزودن بنر',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.banner != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(

          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        body: Consumer<AdminBannerProvider>(
          builder: (context, provider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isWide = screenWidth >= 900;
                final horizontalPadding =
                screenWidth < 600 ? 14.0 : 24.0;

                return Form(
                  key: _formKey,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1250,
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          30,
                        ),
                        children: [
                          _buildImageSection(
                            provider,
                            isEditing,
                            screenWidth,
                          ),
                          const SizedBox(height: 16),

                          if (isWide) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildBasicInfoSection(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildBannerTypeSection(provider),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildActionSection(provider),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildSortOrderSection(),
                                      const SizedBox(height: 16),
                                      _buildDatesSection(provider),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildBasicInfoSection(),
                            const SizedBox(height: 14),
                            _buildBannerTypeSection(provider),
                            const SizedBox(height: 14),
                            _buildActionSection(provider),
                            const SizedBox(height: 14),
                            _buildSortOrderSection(),
                            const SizedBox(height: 14),
                            _buildDatesSection(provider),
                          ],

                          const SizedBox(height: 20),
                          _buildSaveButton(provider, isEditing),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// BANNER INFO BOX
// ================================================================

class _BannerInfoBox extends StatelessWidget {
  const _BannerInfoBox({
    required this.bannerType,
  });

  final String bannerType;

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    String size;

    switch (bannerType) {
      case 'promotional':
        title = 'بنر تبلیغاتی';
        description =
        'برای بنرهای تبلیغاتی صفحه اصلی استفاده می‌شود. '
            'حداکثر ۴ بنر تبلیغاتی قابل ثبت است.';
        size = '1700 × 1200 px';
        break;

      case 'bottom_home':
        title = 'بنر پایین صفحه';
        description =
        'برای نمایش یک بنر ثابت در قسمت پایین صفحه اصلی استفاده می‌شود.';
        size = '1700 × 850 px';
        break;

      case 'hero':
      default:
        title = 'بنر هیرو';
        description =
        'بنر اصلی و بزرگ بالای صفحه اصلی فروشگاه.';
        size = '1700 × 850 px';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD8E8FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF03045E),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03045E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'سایز نهایی تصویر: $size',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF03045E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SECTION CONTAINER
// ================================================================

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFECEEF1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
