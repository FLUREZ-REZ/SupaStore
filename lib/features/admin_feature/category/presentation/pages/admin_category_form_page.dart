import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_category.dart';
import '../providers/admin_category_provider.dart';

class AdminCategoryFormPage extends StatefulWidget {
  const AdminCategoryFormPage({
    super.key,
    this.category,
  });

  final AdminCategory? category;

  bool get isEdit => category != null;

  @override
  State<AdminCategoryFormPage> createState() =>
      _AdminCategoryFormPageState();
}

class _AdminCategoryFormPageState
    extends State<AdminCategoryFormPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _slugController =
  TextEditingController();

  final TextEditingController _sortOrderController =
  TextEditingController();

  final ImagePicker _imagePicker =
  ImagePicker();

  File? _selectedImage;

  bool _isActive = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final category =
        widget.category;

    if (category != null) {
      _nameController.text =
          category.name;

      _slugController.text =
          category.slug;

      _sortOrderController.text =
          category.sortOrder.toString();

      _isActive =
          category.isActive;
    } else {
      _sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _selectedImage =
            File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'انتخاب تصویر ناموفق بود: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CONVERT WEBP
  // ============================================================

  Future<File> _convertToWebP(
      File sourceFile,
      ) async {
    final tempDirectory =
    await getTemporaryDirectory();

    final fileName =
        'category_${DateTime.now().millisecondsSinceEpoch}.webp';

    final targetPath =
        '${tempDirectory.path}/$fileName';

    final result =
    await FlutterImageCompress
        .compressAndGetFile(
      sourceFile.absolute.path,
      targetPath,
      minWidth: 1200,
      minHeight: 1200,
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

    final webpFile =
    File(result.path);

    if (!await webpFile.exists()) {
      throw Exception(
        'فایل WebP ایجاد نشد.',
      );
    }

    return webpFile;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    final provider =
    context.read<AdminCategoryProvider>();

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imagePath =
          widget.category?.imageUrl;

      // ========================================================
      // UPLOAD NEW IMAGE
      // ========================================================

      if (_selectedImage != null) {
        final webpFile =
        await _convertToWebP(
          _selectedImage!,
        );

        imagePath =
        await provider.uploadImage(
          filePath:
          webpFile.path,
          slug:
          _slugController.text.trim(),
        );
      }

      final sortOrder =
          int.tryParse(
            _sortOrderController
                .text
                .trim(),
          ) ??
              0;

      final data =
      <String, dynamic>{
        'name':
        _nameController.text.trim(),
        'slug':
        _slugController.text.trim(),
        'image_url':
        imagePath,
        'sort_order':
        sortOrder,
        'is_active':
        _isActive,
        'updated_at':
        DateTime.now()
            .toUtc()
            .toIso8601String(),
      };

      // ========================================================
      // CREATE
      // ========================================================

      if (!widget.isEdit) {
        data.remove(
          'updated_at',
        );

        await provider.createCategory(
          data: data,
        );
      }

      // ========================================================
      // UPDATE
      // ========================================================

      else {
        await provider.updateCategory(
          categoryId:
          widget.category!.id,
          data: data,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'دسته‌بندی با موفقیت ویرایش شد.'
                : 'دسته‌بندی با موفقیت ایجاد شد.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(e),
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final category =
        widget.category;

    return Directionality(
      textDirection:
      TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        const Color(0xFFF7F7F8),
        appBar: AppBar(
          backgroundColor:
          const Color(0xFFE21B23),
          foregroundColor:
          Colors.white,
          centerTitle: true,
          title: Text(
            widget.isEdit
                ? 'ویرایش دسته‌بندی'
                : 'افزودن دسته‌بندی',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              16.w,
            ),
            child: Column(
              children: [
                // ==================================================
                // IMAGE
                // ==================================================

                _buildImagePicker(
                  category,
                ),

                SizedBox(height: 24.h),

                // ==================================================
                // NAME
                // ==================================================

                _buildLabel(
                  'نام دسته‌بندی',
                ),

                SizedBox(height: 6.h),

                TextFormField(
                  controller:
                  _nameController,
                  textDirection:
                  TextDirection.rtl,
                  textAlign:
                  TextAlign.right,
                  textInputAction:
                  TextInputAction.next,
                  decoration:
                  _inputDecoration(
                    hint:
                    'مثلاً موبایل',
                  ),
                  validator:
                      (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'نام دسته‌بندی را وارد کنید.';
                    }

                    if (value.trim().length <
                        2) {
                      return 'نام دسته‌بندی خیلی کوتاه است.';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // ==================================================
                // SLUG
                // ==================================================

                _buildLabel(
                  'Slug',
                ),

                SizedBox(height: 6.h),

                TextFormField(
                  controller:
                  _slugController,
                  textDirection:
                  TextDirection.ltr,
                  textAlign:
                  TextAlign.left,
                  textInputAction:
                  TextInputAction.next,
                  decoration:
                  _inputDecoration(
                    hint:
                    'مثلاً mobile',
                  ),
                  validator:
                      (value) {
                    final slug =
                        value?.trim() ??
                            '';

                    if (slug.isEmpty) {
                      return 'Slug را وارد کنید.';
                    }

                    final validSlug =
                    RegExp(
                      r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
                    );

                    if (!validSlug
                        .hasMatch(slug)) {
                      return 'Slug باید انگلیسی باشد؛ مثال: mobile-phone';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // ==================================================
                // SORT ORDER
                // ==================================================

                _buildLabel(
                  'ترتیب نمایش',
                ),

                SizedBox(height: 6.h),

                TextFormField(
                  controller:
                  _sortOrderController,
                  keyboardType:
                  TextInputType.number,
                  textDirection:
                  TextDirection.ltr,
                  textAlign:
                  TextAlign.left,
                  decoration:
                  _inputDecoration(
                    hint:
                    'مثلاً 1',
                  ),
                  validator:
                      (value) {
                    final number =
                    int.tryParse(
                      value?.trim() ??
                          '',
                    );

                    if (number == null) {
                      return 'ترتیب نمایش باید عدد باشد.';
                    }

                    if (number < 0) {
                      return 'ترتیب نمایش نمی‌تواند منفی باشد.';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // ==================================================
                // ACTIVE
                // ==================================================

                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 4.h,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      14.r,
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    title: Text(
                      'وضعیت دسته‌بندی',
                      style:
                      TextStyle(
                        fontSize:
                        13.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _isActive
                          ? 'دسته‌بندی فعال است'
                          : 'دسته‌بندی غیرفعال است',
                      style:
                      TextStyle(
                        fontSize:
                        11.sp,
                        color:
                        Colors.black45,
                      ),
                    ),
                    value:
                    _isActive,
                    activeColor:
                    const Color(
                      0xFFE21B23,
                    ),
                    onChanged:
                        (value) {
                      setState(() {
                        _isActive =
                            value;
                      });
                    },
                  ),
                ),

                SizedBox(height: 28.h),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  width:
                  double.infinity,
                  height: 52.h,
                  child:
                  FilledButton(
                    style:
                    FilledButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFFE21B23,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14.r,
                        ),
                      ),
                    ),
                    onPressed:
                    _isSubmitting
                        ? null
                        : _submit,
                    child:
                    _isSubmitting
                        ? SizedBox(
                      width:
                      22.w,
                      height:
                      22.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Colors.white,
                      ),
                    )
                        : Text(
                      widget.isEdit
                          ? 'ذخیره تغییرات'
                          : 'افزودن دسته‌بندی',
                      style:
                      TextStyle(
                        fontSize:
                        14.sp,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PICKER UI
  // ============================================================

  Widget _buildImagePicker(
      AdminCategory? category,
      ) {
    Widget child;

    if (_selectedImage != null) {
      child = Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (category?.imageUrl !=
        null) {
      child = Image.network(
        _getImageUrl(
          category!.imageUrl!,
        ),
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return _imagePlaceholder();
        },
      );
    } else {
      child =
          _imagePlaceholder();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isSubmitting
              ? null
              : _pickImage,
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              18.r,
            ),
            child: Container(
              width: 150.w,
              height: 150.w,
              color:
              const Color(
                0xFFEDEDED,
              ),
              child: child,
            ),
          ),
        ),

        SizedBox(height: 10.h),

        TextButton.icon(
          onPressed:
          _isSubmitting
              ? null
              : _pickImage,
          icon: const Icon(
            Icons
                .add_photo_alternate_outlined,
          ),
          label: Text(
            _selectedImage == null &&
                category?.imageUrl ==
                    null
                ? 'انتخاب تصویر'
                : 'تغییر تصویر',
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          Icons
              .add_photo_alternate_outlined,
          size: 42.sp,
          color: Colors.black26,
        ),
        SizedBox(height: 8.h),
        Text(
          'تصویر دسته‌بندی',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }

  String _getImageUrl(
      String path,
      ) {
    return Supabase
        .instance
        .client
        .storage
        .from('assets')
        .getPublicUrl(
      path,
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
      String text,
      ) {
    return Align(
      alignment:
      Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(
        fontSize: 12.sp,
        color:
        Colors.black38,
      ),
      filled: true,
      fillColor:
      Colors.white,
      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        borderSide:
        BorderSide.none,
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        borderSide:
        const BorderSide(
          color:
          Color(0xFFE21B23),
          width: 1.2,
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
          color: Colors.red,
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
          color: Colors.red,
        ),
      ),
    );
  }
}