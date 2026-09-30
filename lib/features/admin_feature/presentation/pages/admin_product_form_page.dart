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

  static const _primary = Color(0xFF03045E);
  static const _red = Color(0xFFE21B23);
  static const _background = Color(0xFFF6F7F9);
  static const _border = Color(0xFFE5E7EB);
  static const _text = Color(0xFF17181A);
  static const _muted = Color(0xFF73777D);

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
      minWidth: 1600,
      minHeight: 1600,
      quality: 80,
      autoCorrectionAngle: true,
      format: CompressFormat.webp,
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

    final price = int.parse(
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
      if (_selectedImage != null) {
        final extension = _selectedImage!
            .path
            .split('.')
            .last
            .toLowerCase();

        if (extension != 'webp') {
          _showError(
            'فقط فایل WebP مجاز است.',
          );
          return;
        }

        thumbnail = await provider.uploadImage(
          filePath: _selectedImage!.path,
        );
      }

      if (thumbnail == null ||
          thumbnail.trim().isEmpty) {
        _showError(
          'لطفاً تصویر محصول را انتخاب کنید.',
        );
        return;
      }

      final discountPercent =
      _calculateDiscountPercent(
        price: price,
        discountPrice: discountPrice,
      );

      final data = <String, dynamic>{
        'category_id': _categoryId,
        'brand_id': _brandId,
        'title': _titleController.text.trim(),
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
      } else {
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

      _showError(
        'خطا در ذخیره محصول:\n$e',
      );
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

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<AdminProductProvider>();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Color(0xFF03045e),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
          ),
        ),
        title: Text(
          widget.isEditing
              ? 'ویرایش محصول'
              : 'محصول جدید',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            30.h,
          ),
          children: [
            _section(
              title: 'اطلاعات محصول',
              icon: Icons.inventory_2_outlined,
              children: [
                _textField(
                  controller: _titleController,
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

                SizedBox(height: 14.h),

                _textField(
                  controller: _slugController,
                  label: 'Slug',
                  hint: 'iphone-15-pro',
                  icon: Icons.link_rounded,
                ),

                SizedBox(height: 14.h),

                _textField(
                  controller: _descriptionController,
                  label: 'توضیحات محصول',
                  hint: 'توضیحات کامل محصول را وارد کنید...',
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

            SizedBox(height: 14.h),

            _section(
              title: 'دسته‌بندی',
              icon: Icons.category_outlined,
              children: [
                _dropdown(
                  value: _categoryId,
                  label: 'دسته‌بندی',
                  items: provider.categories,
                  icon: Icons.category_outlined,
                  onChanged: (value) {
                    setState(() {
                      _categoryId = value;
                    });
                  },
                ),

                SizedBox(height: 14.h),

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

            SizedBox(height: 14.h),

            _section(
              title: 'قیمت‌گذاری',
              icon: Icons.payments_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller:
                        _priceController,
                        label: 'قیمت اصلی',
                        hint: '0',
                        icon:
                        Icons.payments_outlined,
                        keyboardType:
                        TextInputType.number,
                        validator: (value) {
                          final price =
                          int.tryParse(
                            value?.trim() ?? '',
                          );

                          if (price == null ||
                              price <= 0) {
                            return 'قیمت معتبر نیست';
                          }

                          return null;
                        },
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: _textField(
                        controller:
                        _discountPriceController,
                        label: 'قیمت با تخفیف',
                        hint: 'اختیاری',
                        icon:
                        Icons
                            .local_offer_outlined,
                        keyboardType:
                        TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 14.h),

            _section(
              title: 'تصویر محصول',
              icon: Icons.image_outlined,
              children: [
                _imagePicker(),

                if (_selectedImage != null)
                  Padding(
                    padding:
                    EdgeInsets.only(top: 10.h),
                    child:
                    FutureBuilder<int>(
                      future:
                      _selectedImage!.length(),
                      builder:
                          (context, snapshot) {
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
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons
                                  .check_circle_outline_rounded,
                              size: 15.sp,
                              color:
                              Colors.green,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'تصویر آماده است • $sizeText',
                              style: TextStyle(
                                fontSize: 11.sp,
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

            SizedBox(height: 14.h),

            _section(
              title: 'وضعیت',
              icon: Icons.tune_rounded,
              children: [
                _statusTile(
                  icon:
                  Icons.inventory_2_outlined,
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

                SizedBox(height: 8.h),

                _statusTile(
                  icon:
                  Icons.star_border_rounded,
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

                SizedBox(height: 8.h),

                _statusTile(
                  icon:
                  Icons.fiber_new_rounded,
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

            SizedBox(height: 20.h),

            SizedBox(
              height: 54.h,
              child: ElevatedButton(
                onPressed:
                provider.isSaving ||
                    _isProcessingImage
                    ? null
                    : _save,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  disabledBackgroundColor:
                  _red.withValues(
                    alpha: 0.55,
                  ),
                  foregroundColor:
                  Colors.white,
                  disabledForegroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14.r,
                    ),
                  ),
                ),
                child: provider.isSaving
                    ? Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color:
                        Colors.white,
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
                    : Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Icon(
                      widget.isEditing
                          ? Icons
                          .save_outlined
                          : Icons.add_rounded,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      widget.isEditing
                          ? 'ذخیره تغییرات'
                          : 'افزودن محصول',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFECEDEF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color:
                  _primary.withValues(
                    alpha: 0.07,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10.r,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: _primary,
                ),
              ),

              SizedBox(width: 10.w),

              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                  FontWeight.w800,
                  color: _text,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          ...children,
        ],
      ),
    );
  }

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
      style: TextStyle(
        fontSize: 13.sp,
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
          size: 19.sp,
          color: _muted,
        ),
        floatingLabelBehavior:
        FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 15.h,
        ),
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: const Color(
            0xFFA1A5AA,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 12.sp,
          color: _muted,
        ),
        floatingLabelStyle:
        TextStyle(
          fontSize: 12.sp,
          color: _primary,
          fontWeight:
          FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _border,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _primary,
            width: 1.3,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _red,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _red,
            width: 1.3,
          ),
        ),
        errorStyle: TextStyle(
          fontSize: 10.sp,
          color: _red,
        ),
      ),
    );
  }

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
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 22.sp,
        color: _muted,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 19.sp,
          color: _muted,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 5.h,
        ),
        labelStyle: TextStyle(
          fontSize: 12.sp,
          color: _muted,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _border,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          const BorderSide(
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
            ),
          ),
        ...items.map(
              (item) =>
              DropdownMenuItem<String>(
                value: item.id,
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _isProcessingImage
          ? null
          : _pickImage,
      child: Container(
        height: 210.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(
            0xFFF8F9FA,
          ),
          borderRadius:
          BorderRadius.circular(
            14.r,
          ),
          border: Border.all(
            color: _border,
          ),
        ),
        child: _isProcessingImage
            ? const Center(
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        )
            : _selectedImage != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius
                  .circular(
                14.r,
              ),
              child:
              Image.file(
                _selectedImage!,
                width:
                double.infinity,
                height:
                double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 10.w,
              top: 10.h,
              child:
              Container(
                padding:
                EdgeInsets
                    .symmetric(
                  horizontal: 10.w,
                  vertical: 7.h,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.black
                      .withValues(
                    alpha: 0.65,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    10.r,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .edit_outlined,
                      size: 15.sp,
                      color:
                      Colors.white,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      'تغییر تصویر',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        11.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration:
              BoxDecoration(
                color:
                _primary
                    .withValues(
                  alpha: 0.07,
                ),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .add_photo_alternate_outlined,
                size: 28.sp,
                color: _primary,
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            Text(
              _thumbnailPath !=
                  null
                  ? 'تغییر تصویر محصول'
                  : 'انتخاب تصویر محصول',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight:
                FontWeight.w700,
                color: _text,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'JPG / PNG / WebP',
              style: TextStyle(
                fontSize: 10.sp,
                color: _muted,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Text(
              'خروجی WebP • کیفیت 80٪',
              style: TextStyle(
                fontSize: 10.sp,
                color:
                const Color(
                  0xFF9CA0A6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8F9FA,
        ),
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
      ),
      child: Row(
        children: [
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign:
                  TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight:
                    FontWeight.w700,
                    color: _text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  textAlign:
                  TextAlign.right,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                10.r,
              ),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}