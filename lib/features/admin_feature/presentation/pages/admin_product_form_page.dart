
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/admin_product_option.dart';
import '../providers/admin_product_provider.dart';

class AdminProductFormPage extends StatefulWidget {
  const AdminProductFormPage({
    super.key,
    this.product,
  });

  final Map<String, dynamic>? product;

  bool get isEditing => product != null;

  @override
  State<AdminProductFormPage> createState() =>
      _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  String? _categoryId;
  String? _brandId;

  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _isNew = false;

  String? _thumbnailPath;
  File? _selectedImage;
  bool _isProcessingImage = false;

  static const Color _primary = Color(0xFF03045E);
  static const Color _red = Color(0xFFE21B23);
  static const Color _background = Color(0xFFF6F7F9);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF17181A);
  static const Color _muted = Color(0xFF73777D);

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    if (product != null) {
      _titleController.text = product['title'] as String? ?? '';
      _slugController.text = product['slug'] as String? ?? '';
      _descriptionController.text =
          product['description'] as String? ?? '';

      _priceController.text = '${product['price'] ?? ''}';

      _discountPriceController.text =
      product['discount_price'] == null
          ? ''
          : '${product['discount_price']}';

      _categoryId = product['category_id'] as String?;
      _brandId = product['brand_id'] as String?;

      _isAvailable = product['is_available'] as bool? ?? true;
      _isFeatured = product['is_featured'] as bool? ?? false;
      _isNew = product['is_new'] as bool? ?? false;

      _thumbnailPath = product['thumbnail'] as String?;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  // =====================================================
  // IMAGE PICKER
  // =====================================================

  Future<void> _pickImage() async {
    if (_isProcessingImage) return;

    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        _isProcessingImage = true;
      });

      final compressedFile = await _convertToWebP(
        File(image.path),
      );

      if (!mounted) return;

      setState(() {
        _selectedImage = compressedFile;
      });
    } catch (e) {
      if (!mounted) return;

      _showError('خطا در پردازش تصویر:\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  Future<File> _convertToWebP(File sourceFile) async {
    final tempDirectory = await getTemporaryDirectory();

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.webp';

    final targetPath = '${tempDirectory.path}/$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      sourceFile.absolute.path,
      targetPath,
      minWidth: 1600,
      minHeight: 1600,
      quality: 80,
      autoCorrectionAngle: true,
      format: CompressFormat.webp,
      keepExif: false,
    );

    if (result == null) {
      throw Exception('تبدیل تصویر به WebP ناموفق بود.');
    }

    final webpFile = File(result.path);

    if (!await webpFile.exists()) {
      throw Exception('فایل WebP ایجاد نشد.');
    }

    return webpFile;
  }

  // =====================================================
  // SLUG
  // =====================================================

  String _createSlug(String title) {
    return title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  // =====================================================
  // DISCOUNT
  // =====================================================

  int _calculateDiscountPercent({
    required int price,
    required int? discountPrice,
  }) {
    if (discountPrice == null ||
        discountPrice <= 0 ||
        discountPrice >= price) {
      return 0;
    }

    return (((price - discountPrice) / price) * 100).round();
  }

  // =====================================================
  // SAVE
  // =====================================================

  Future<void> _save() async {
    if (_isProcessingImage) {
      _showError('لطفاً صبر کنید تا تصویر آماده شود.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminProductProvider>();

    final price = int.parse(
      _priceController.text.trim(),
    );

    final discountText = _discountPriceController.text.trim();

    final discountPrice = discountText.isEmpty
        ? null
        : int.tryParse(discountText);

    if (discountText.isNotEmpty && discountPrice == null) {
      _showError('قیمت تخفیف‌خورده معتبر نیست.');
      return;
    }

    if (discountPrice != null && discountPrice >= price) {
      _showError(
        'قیمت تخفیف‌خورده باید کمتر از قیمت اصلی باشد.',
      );
      return;
    }

    String? thumbnail = _thumbnailPath;

    try {
      if (_selectedImage != null) {
        final extension = _selectedImage!.path
            .split('.')
            .last
            .toLowerCase();

        if (extension != 'webp') {
          _showError('فقط فایل WebP مجاز است.');
          return;
        }

        thumbnail = await provider.uploadImage(
          filePath: _selectedImage!.path,
        );
      }

      if (thumbnail == null || thumbnail.trim().isEmpty) {
        _showError('لطفاً تصویر محصول را انتخاب کنید.');
        return;
      }

      final discountPercent = _calculateDiscountPercent(
        price: price,
        discountPrice: discountPrice,
      );

      final data = <String, dynamic>{
        'category_id': _categoryId,
        'brand_id': _brandId,
        'title': _titleController.text.trim(),
        'slug': _slugController.text.trim().isEmpty
            ? _createSlug(_titleController.text)
            : _slugController.text.trim(),
        'description': _descriptionController.text.trim(),
        'thumbnail': thumbnail,
        'price': price,
        'discount_price': discountPrice,
        'discount_percent': discountPercent,
        'is_available': _isAvailable,
        'is_featured': _isFeatured,
        'is_new': _isNew,
      };

      if (widget.isEditing) {
        await provider.updateProduct(
          productId: widget.product!['id'] as String,
          data: {
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      } else {
        await provider.createProduct(
          data: {
            ...data,
            'sold_count': 0,
            'rating': 0,
            'review_count': 0,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.isEditing
                ? 'محصول با موفقیت ویرایش شد.'
                : 'محصول با موفقیت ایجاد شد.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showError('خطا در ذخیره محصول:\n$e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _red,
        content: Text(message),
      ),
    );
  }

  // =====================================================
  // MAIN BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
          ),

        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            final isWide = screenWidth >= 850;

            final horizontalPadding = screenWidth < 600
                ? 14.0
                : screenWidth < 1000
                ? 22.0
                : 30.0;

            return Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          30,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              // -------------------------
                              // PAGE HEADER
                              // -------------------------

                              _buildPageHeader(),

                              const SizedBox(height: 20),

                              // -------------------------
                              // RESPONSIVE FORM SECTIONS
                              // -------------------------

                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final availableWidth =
                                      innerConstraints.maxWidth;

                                  final columns = isWide ? 2 : 1;

                                  final itemWidth = columns == 2
                                      ? (availableWidth - 16) / 2
                                      : availableWidth;

                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: itemWidth,
                                        child: _section(
                                          title: 'اطلاعات محصول',
                                          icon: Icons.inventory_2_outlined,
                                          children: [
                                            _textField(
                                              controller:
                                              _titleController,
                                              label: 'عنوان محصول',
                                              hint: 'مثلاً iPhone 15 Pro',
                                              icon: Icons.title_rounded,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'عنوان محصول الزامی است';
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 14),

                                            _textField(
                                              controller:
                                              _slugController,
                                              label: 'Slug',
                                              hint: 'iphone-15-pro',
                                              icon: Icons.link_rounded,
                                            ),

                                            const SizedBox(height: 14),

                                            _textField(
                                              controller:
                                              _descriptionController,
                                              label: 'توضیحات محصول',
                                              hint:
                                              'توضیحات کامل محصول را وارد کنید...',
                                              icon: Icons.notes_rounded,
                                              maxLines: 5,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'توضیحات الزامی است';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        width: itemWidth,
                                        child: _section(
                                          title: 'دسته‌بندی و برند',
                                          icon: Icons.category_outlined,
                                          children: [
                                            _dropdown(
                                              value: _categoryId,
                                              label: 'دسته‌بندی',
                                              items: provider.categories,
                                              icon:
                                              Icons.category_outlined,
                                              onChanged: (value) {
                                                setState(() {
                                                  _categoryId = value;
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 14),

                                            _dropdown(
                                              value: _brandId,
                                              label: 'برند',
                                              allowNull: true,
                                              items: provider.brands,
                                              icon: Icons.sell_outlined,
                                              onChanged: (value) {
                                                setState(() {
                                                  _brandId = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        width: itemWidth,
                                        child: _section(
                                          title: 'قیمت‌گذاری',
                                          icon: Icons.payments_outlined,
                                          children: [
                                            LayoutBuilder(
                                              builder: (
                                                  context,
                                                  priceConstraints,
                                                  ) {
                                                final stacked =
                                                    priceConstraints
                                                        .maxWidth <
                                                        390;

                                                if (stacked) {
                                                  return Column(
                                                    children: [
                                                      _textField(
                                                        controller:
                                                        _priceController,
                                                        label: 'قیمت اصلی',
                                                        hint: '0',
                                                        icon: Icons
                                                            .payments_outlined,
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        validator: _priceValidator,
                                                      ),
                                                      const SizedBox(
                                                        height: 14,
                                                      ),
                                                      _discountField(),
                                                    ],
                                                  );
                                                }

                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: _textField(
                                                        controller:
                                                        _priceController,
                                                        label: 'قیمت اصلی',
                                                        hint: '0',
                                                        icon: Icons
                                                            .payments_outlined,
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        validator:
                                                        _priceValidator,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: _discountField(),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        width: itemWidth,
                                        child: _section(
                                          title: 'تصویر محصول',
                                          icon: Icons.image_outlined,
                                          children: [
                                            _imagePicker(),

                                            if (_selectedImage != null)
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                child: FutureBuilder<int>(
                                                  future:
                                                  _selectedImage!.length(),
                                                  builder: (
                                                      context,
                                                      snapshot,
                                                      ) {
                                                    if (!snapshot.hasData) {
                                                      return const SizedBox();
                                                    }

                                                    final sizeInKb =
                                                        snapshot.data! / 1024;

                                                    final sizeText =
                                                    sizeInKb >= 1024
                                                        ? '${(sizeInKb / 1024).toStringAsFixed(2)} MB'
                                                        : '${sizeInKb.toStringAsFixed(0)} KB';

                                                    return Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .check_circle_outline_rounded,
                                                          size: 15,
                                                          color: Colors.green,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          'تصویر آماده است • $sizeText',
                                                          style:
                                                          const TextStyle(
                                                            fontSize: 11,
                                                            color: _muted,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        width: itemWidth,
                                        child: _section(
                                          title: 'وضعیت محصول',
                                          icon: Icons.tune_rounded,
                                          children: [
                                            _statusTile(
                                              icon: Icons
                                                  .inventory_2_outlined,
                                              title: 'موجودی محصول',
                                              subtitle:
                                              'محصول برای خرید فعال باشد',
                                              value: _isAvailable,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isAvailable = value;
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 8),

                                            _statusTile(
                                              icon: Icons.star_border_rounded,
                                              title: 'محصول ویژه',
                                              subtitle:
                                              'نمایش در بخش محصولات ویژه',
                                              value: _isFeatured,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isFeatured = value;
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 8),

                                            _statusTile(
                                              icon: Icons.fiber_new_rounded,
                                              title: 'محصول جدید',
                                              subtitle:
                                              'نمایش به عنوان محصول جدید',
                                              value: _isNew,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isNew = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 22),

                              // -------------------------
                              // SUBMIT BUTTON
                              // -------------------------

                              Align(
                                alignment: Alignment.center,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 520,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: _buildSubmitButton(provider),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Center(
                                child: Text(
                                  'لطفاً قبل از ثبت، اطلاعات محصول را بررسی کنید.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // =====================================================
  // PAGE HEADER
  // =====================================================

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.isEditing
                  ? Icons.edit_outlined
                  : Icons.add_box_outlined,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing
                      ? 'ویرایش اطلاعات محصول'
                      : 'افزودن محصول جدید',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.isEditing
                      ? 'اطلاعات محصول را تغییر دهید و ذخیره کنید.'
                      : 'اطلاعات محصول جدید را برای ثبت در فروشگاه وارد کنید.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PRICE FIELD
  // =====================================================

  String? _priceValidator(String? value) {
    final price = int.tryParse(value?.trim() ?? '');

    if (price == null || price <= 0) {
      return 'قیمت معتبر نیست';
    }

    return null;
  }

  Widget _discountField() {
    return _textField(
      controller: _discountPriceController,
      label: 'قیمت با تخفیف',
      hint: 'اختیاری',
      icon: Icons.local_offer_outlined,
      keyboardType: TextInputType.number,
    );
  }

  // =====================================================
  // SECTION
  // =====================================================

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEDEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  // =====================================================
  // TEXT FIELD
  // =====================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _text,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(
          icon,
          size: 19,
          color: _muted,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFA1A5AA),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: _muted,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: _primary,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _red,
            width: 1.3,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 10,
          color: _red,
        ),
      ),
    );
  }

  // =====================================================
  // DROPDOWN
  // =====================================================

  Widget _dropdown({
    required String? value,
    required String label,
    required List<AdminProductOption> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    bool allowNull = false,
  }) {
    final validValue = items.any(
          (item) => item.id == value,
    )
        ? value
        : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 22,
        color: _muted,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 19,
          color: _muted,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: _muted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.3,
          ),
        ),
      ),
      items: [
        if (allowNull)
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              'بدون برند',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ...items.map(
              (item) => DropdownMenuItem<String>(
            value: item.id,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  // =====================================================
  // IMAGE PICKER
  // =====================================================

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _isProcessingImage ? null : _pickImage,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: _isProcessingImage
            ? const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _primary,
          ),
        )
            : _selectedImage != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'تغییر تصویر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 28,
                color: _primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _thumbnailPath != null
                  ? 'تغییر تصویر محصول'
                  : 'انتخاب تصویر محصول',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'JPG / PNG / WebP',
              style: TextStyle(
                fontSize: 10,
                color: _muted,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'خروجی WebP • کیفیت 80٪',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA0A6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STATUS TILE
  // =====================================================

  Widget _statusTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SUBMIT BUTTON
  // =====================================================

  Widget _buildSubmitButton(AdminProductProvider provider) {
    final isBusy = provider.isSaving || _isProcessingImage;

    return ElevatedButton(
      onPressed: isBusy ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: _red,
        disabledBackgroundColor: _red.withValues(alpha: 0.55),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isBusy
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _isProcessingImage
                ? 'در حال آماده‌سازی تصویر...'
                : widget.isEditing
                ? 'در حال ذخیره تغییرات...'
                : 'در حال افزودن محصول...',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isEditing
                ? Icons.save_outlined
                : Icons.add_rounded,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isEditing
                ? 'ذخیره تغییرات'
                : 'افزودن محصول',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
