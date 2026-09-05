import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _AdminProductFormPageState
    extends State<AdminProductFormPage> {
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

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    if (product != null) {
      _titleController.text =
          product['title'] as String? ?? '';

      _slugController.text =
          product['slug'] as String? ?? '';

      _descriptionController.text =
          product['description'] as String? ?? '';

      _priceController.text =
      '${product['price'] ?? ''}';

      _discountPriceController.text =
      product['discount_price'] == null
          ? ''
          : '${product['discount_price']}';

      _categoryId =
      product['category_id'] as String?;

      _brandId =
      product['brand_id'] as String?;

      _isAvailable =
          product['is_available'] as bool? ?? true;

      _isFeatured =
          product['is_featured'] as bool? ?? false;

      _isNew =
          product['is_new'] as bool? ?? false;

      _thumbnailPath =
      product['thumbnail'] as String?;
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

  // ===========================================================================
  // IMAGE PICKER
  // ===========================================================================

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

      final compressedFile =
      await _convertToWebP(
        File(image.path),
      );

      if (!mounted) return;

      setState(() {
        _selectedImage = compressedFile;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        'خطا در پردازش تصویر:\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  // ===========================================================================
  // WEBP CONVERSION + COMPRESSION
  // ===========================================================================

  Future<File> _convertToWebP(
      File sourceFile,
      ) async {
    final tempDirectory =
    await getTemporaryDirectory();

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.webp';

    final targetPath =
        '${tempDirectory.path}/$fileName';

    final result =
    await FlutterImageCompress.compressAndGetFile(
      sourceFile.absolute.path,
      targetPath,

      // حداکثر ابعاد خروجی
      minWidth: 1600,
      minHeight: 1600,

      // کیفیت WebP
      quality: 80,

      // اصلاح چرخش EXIF
      autoCorrectionAngle: true,

      // خروجی WebP
      format: CompressFormat.webp,

      // اطلاعات EXIF را نگه نمی‌داریم
      keepExif: false,
    );

    if (result == null) {
      throw Exception(
        'تبدیل تصویر به WebP ناموفق بود.',
      );
    }

    final webpFile = File(result.path);

    if (!await webpFile.exists()) {
      throw Exception(
        'فایل WebP ایجاد نشد.',
      );
    }

    return webpFile;
  }

  // ===========================================================================
  // SLUG
  // ===========================================================================

  String _createSlug(String title) {
    return title
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[^\w\s-]'),
      '',
    )
        .replaceAll(
      RegExp(r'\s+'),
      '-',
    )
        .replaceAll(
      RegExp(r'-+'),
      '-',
    );
  }

  // ===========================================================================
  // DISCOUNT
  // ===========================================================================

  int _calculateDiscountPercent({
    required int price,
    required int? discountPrice,
  }) {
    if (discountPrice == null ||
        discountPrice <= 0 ||
        discountPrice >= price) {
      return 0;
    }

    return (((price - discountPrice) / price) * 100)
        .round();
  }

  // ===========================================================================
  // SAVE PRODUCT
  // ===========================================================================

  Future<void> _save() async {
    if (_isProcessingImage) {
      _showError(
        'لطفاً صبر کنید تا تصویر آماده شود.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
    context.read<AdminProductProvider>();

    final price =
    int.parse(
      _priceController.text.trim(),
    );

    final discountText =
    _discountPriceController.text.trim();

    final discountPrice =
    discountText.isEmpty
        ? null
        : int.tryParse(discountText);

    if (discountPrice != null &&
        discountPrice >= price) {
      _showError(
        'قیمت تخفیف‌خورده باید کمتر از قیمت اصلی باشد.',
      );
      return;
    }

    String? thumbnail = _thumbnailPath;

    try {
      // =======================================================================
      // UPLOAD NEW IMAGE
      // =======================================================================

      if (_selectedImage != null) {
        final extension = _selectedImage!
            .path
            .split('.')
            .last
            .toLowerCase();

        // امنیت اضافه
        if (extension != 'webp') {
          _showError(
            'فقط فایل WebP مجاز است.',
          );
          return;
        }

        thumbnail =
        await provider.uploadImage(
          filePath: _selectedImage!.path,
        );
      }

      // =======================================================================
      // IMAGE REQUIRED
      // =======================================================================

      if (thumbnail == null ||
          thumbnail.trim().isEmpty) {
        _showError(
          'لطفاً تصویر محصول را انتخاب کنید.',
        );
        return;
      }

      // =======================================================================
      // DISCOUNT
      // =======================================================================

      final discountPercent =
      _calculateDiscountPercent(
        price: price,
        discountPrice: discountPrice,
      );

      // =======================================================================
      // PRODUCT DATA
      // =======================================================================

      final data = <String, dynamic>{
        'category_id': _categoryId,
        'brand_id': _brandId,
        'title':
        _titleController.text.trim(),
        'slug':
        _slugController.text.trim().isEmpty
            ? _createSlug(
          _titleController.text,
        )
            : _slugController.text.trim(),
        'description':
        _descriptionController.text.trim(),
        'thumbnail': thumbnail,
        'price': price,
        'discount_price': discountPrice,
        'discount_percent': discountPercent,
        'is_available': _isAvailable,
        'is_featured': _isFeatured,
        'is_new': _isNew,
      };

      // =======================================================================
      // UPDATE
      // =======================================================================

      if (widget.isEditing) {
        await provider.updateProduct(
          productId:
          widget.product!['id'] as String,
          data: {
            ...data,
            'updated_at':
            DateTime.now().toIso8601String(),
          },
        );
      }

      // =======================================================================
      // CREATE
      // =======================================================================

      else {
        await provider.createProduct(
          data: {
            ...data,
            'sold_count': 0,
            'rating': 0,
            'review_count': 0,
            'created_at':
            DateTime.now().toIso8601String(),
          },
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'محصول با موفقیت ویرایش شد.'
                : 'محصول با موفقیت ایجاد شد.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        'خطا در ذخیره محصول:\n$e',
      );
    }
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<AdminProductProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F7F8),

      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'ویرایش محصول'
              : 'محصول جدید',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // =================================================================
            // BASIC INFORMATION
            // =================================================================

            _section(
              title: 'اطلاعات اصلی',
              children: [
                _textField(
                  controller:
                  _titleController,
                  label: 'عنوان محصول',
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'عنوان محصول الزامی است';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller:
                  _slugController,
                  label: 'Slug',
                  hint:
                  'مثلاً iphone-15-pro',
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller:
                  _descriptionController,
                  label: 'توضیحات',
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

            SizedBox(height: 16.h),

            // =================================================================
            // CATEGORY + BRAND
            // =================================================================

            _section(
              title: 'دسته‌بندی و برند',
              children: [
                _dropdown(
                  value: _categoryId,
                  label: 'دسته‌بندی',
                  items:
                  provider.categories,
                  onChanged: (value) {
                    setState(() {
                      _categoryId = value;
                    });
                  },
                ),

                SizedBox(height: 12.h),

                _dropdown(
                  value: _brandId,
                  label: 'برند',
                  allowNull: true,
                  items: provider.brands,
                  onChanged: (value) {
                    setState(() {
                      _brandId = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // =================================================================
            // PRICE
            // =================================================================

            _section(
              title: 'قیمت',
              children: [
                _textField(
                  controller:
                  _priceController,
                  label: 'قیمت اصلی',
                  keyboardType:
                  TextInputType.number,
                  validator: (value) {
                    final price =
                    int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (price == null ||
                        price <= 0) {
                      return 'قیمت معتبر وارد کنید';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                _textField(
                  controller:
                  _discountPriceController,
                  label: 'قیمت با تخفیف',
                  hint: 'اختیاری',
                  keyboardType:
                  TextInputType.number,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // =================================================================
            // IMAGE
            // =================================================================

            _section(
              title: 'تصویر محصول',
              children: [
                GestureDetector(
                  onTap: _isProcessingImage
                      ? null
                      : _pickImage,
                  child: Container(
                    height: 180.h,
                    width: double.infinity,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFF1F1F1,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        14.r,
                      ),
                    ),
                    child: _isProcessingImage
                        ? const Center(
                      child:
                      CircularProgressIndicator(),
                    )
                        : _selectedImage !=
                        null
                        ? ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(
                        14.r,
                      ),
                      child:
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize
                            .min,
                        children: [
                          Icon(
                            Icons
                                .add_photo_alternate_rounded,
                            size: 42.sp,
                            color: Colors
                                .black45,
                          ),

                          SizedBox(
                            height: 8.h,
                          ),

                          Text(
                            _thumbnailPath !=
                                null
                                ? 'تغییر تصویر'
                                : 'انتخاب تصویر',
                          ),

                          SizedBox(
                            height: 5.h,
                          ),

                          Text(
                            'JPG / PNG / WebP',
                            style:
                            TextStyle(
                              fontSize:
                              10.sp,
                              color: Colors
                                  .black45,
                            ),
                          ),

                          SizedBox(
                            height: 2.h,
                          ),

                          Text(
                            'خروجی: WebP • کیفیت 80٪',
                            style:
                            TextStyle(
                              fontSize:
                              10.sp,
                              color: Colors
                                  .black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_selectedImage != null)
                  Padding(
                    padding:
                    EdgeInsets.only(
                      top: 8.h,
                    ),
                    child: FutureBuilder<int>(
                      future:
                      _selectedImage!
                          .length(),
                      builder:
                          (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final sizeInKb =
                            snapshot.data! /
                                1024;

                        final sizeText =
                        sizeInKb >= 1024
                            ? '${(sizeInKb / 1024).toStringAsFixed(2)} MB'
                            : '${sizeInKb.toStringAsFixed(0)} KB';

                        return Text(
                          'حجم تصویر نهایی: $sizeText',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                            Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16.h),

            // =================================================================
            // STATUS
            // =================================================================

            _section(
              title: 'وضعیت محصول',
              children: [
                SwitchListTile(
                  contentPadding:
                  EdgeInsets.zero,
                  title: const Text(
                    'محصول موجود است',
                  ),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),

                SwitchListTile(
                  contentPadding:
                  EdgeInsets.zero,
                  title: const Text(
                    'محصول ویژه',
                  ),
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() {
                      _isFeatured = value;
                    });
                  },
                ),

                SwitchListTile(
                  contentPadding:
                  EdgeInsets.zero,
                  title: const Text(
                    'محصول جدید',
                  ),
                  value: _isNew,
                  onChanged: (value) {
                    setState(() {
                      _isNew = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // =================================================================
            // SAVE BUTTON
            // =================================================================

            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed:
                provider.isSaving ||
                    _isProcessingImage
                    ? null
                    : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFE21B23),
                  disabledBackgroundColor:
                  const Color(0xFFE21B23).withValues(
                    alpha: 0.65,
                  ),
                  foregroundColor: Colors.white,
                  disabledForegroundColor:
                  Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14.r),
                  ),
                ),
                child: provider.isSaving
                    ? Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 21.w,
                      height: 21.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      widget.isEditing
                          ? 'در حال ذخیره تغییرات...'
                          : 'در حال افزودن محصول...',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                )
                    : Text(
                  widget.isEditing
                      ? 'ذخیره تغییرات'
                      : 'افزودن محصول',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION
  // ===========================================================================

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          SizedBox(height: 16.h),

          ...children,
        ],
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _textField({
    required TextEditingController
    controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textDirection:
      TextDirection.rtl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor:
        const Color(0xFFF8F8F8),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12.r),
          borderSide:
          BorderSide.none,
        ),
      ),
    );
  }

  // ===========================================================================
  // DROPDOWN
  // ===========================================================================

  Widget _dropdown({
    required String? value,
    required String label,
    required List<AdminProductOption>
    items,
    required ValueChanged<String?>
    onChanged,
    bool allowNull = false,
  }) {
    final validValue = items.any(
          (item) => item.id == value,
    )
        ? value
        : null;

    return DropdownButtonFormField<
        String>(
      value: validValue,
      isExpanded: true,

      decoration:
      InputDecoration(
        labelText: label,
        filled: true,
        fillColor:
        const Color(0xFFF8F8F8),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide.none,
        ),
      ),

      items: [
        if (allowNull)
          const DropdownMenuItem<String>(
            value: null,
            child: Text(
              'بدون برند',
            ),
          ),

        ...items.map(
              (item) =>
              DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  item.name,
                ),
              ),
        ),
      ],

      onChanged: onChanged,
    );
  }
}