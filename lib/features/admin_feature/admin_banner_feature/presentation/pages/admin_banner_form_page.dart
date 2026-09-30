import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // ============================================================
  // VALID VALUES
  // ============================================================

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

    // ----------------------------------------------------------
    // IMPORTANT:
    // مقدارهای دیتابیس را قبل از قرار دادن داخل Dropdown
    // بررسی می‌کنیم تا اگر مقدار قدیمی/نامعتبر بود
    // Flutter assertion ندهد.
    // ----------------------------------------------------------

    final databaseBannerType = banner?.bannerType;

    if (databaseBannerType != null &&
        _validBannerTypes.contains(
          databaseBannerType,
        )) {
      _bannerType = databaseBannerType;
    } else {
      _bannerType = 'hero';
    }

    final databaseActionType = banner?.actionType;

    if (databaseActionType != null &&
        _validActionTypes.contains(
          databaseActionType,
        )) {
      _actionType = databaseActionType;
    } else {
      _actionType = 'none';
    }

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

  // ============================================================
  // BANNER SIZE
  // ============================================================

  int get _targetWidth {
    return 1700;
  }

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

  String get _bannerSizeText {
    return '$_targetWidth × $_targetHeight px';
  }

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

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final processedImage =
      await _processBannerImage(
        picked,
      );

      if (!mounted) {
        return;
      }

      if (processedImage == null) {
        _showMessage(
          'پردازش تصویر انجام نشد.',
        );
        return;
      }

      setState(() {
        _selectedImage = processedImage;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'خطا در پردازش تصویر.',
      );
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

  Future<XFile?> _processBannerImage(
      XFile source,
      ) async {
    final bytes = await source.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return null;
    }

    final sourceWidth = decoded.width;
    final sourceHeight = decoded.height;

    final targetWidth = _targetWidth;
    final targetHeight = _targetHeight;

    final targetRatio =
        targetWidth / targetHeight;

    final sourceRatio =
        sourceWidth / sourceHeight;

    late img.Image cropped;

    // ----------------------------------------------------------
    // تصویر عریض‌تر از نسبت مقصد است.
    // از چپ و راست Crop می‌کنیم.
    // ----------------------------------------------------------

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
    }

    // ----------------------------------------------------------
    // تصویر بلندتر از نسبت مقصد است.
    // از بالا و پایین Crop می‌کنیم.
    // ----------------------------------------------------------

    else {
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

    // ----------------------------------------------------------
    // RESIZE
    // ----------------------------------------------------------

    final resized = img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation:
      img.Interpolation.cubic,
    );

    // ----------------------------------------------------------
    // WEBP
    // ----------------------------------------------------------

    final Uint8List webpBytes =
    Uint8List.fromList(
      img.encodeWebP(
        resized,
        quality: 82,
      ),
    );

    final tempDirectory =
        Directory.systemTemp;

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
  // START DATE
  // ============================================================

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );

    if (picked == null || !mounted) {
      return;
    }

    final pickedTime =
    _startDate != null
        ? TimeOfDay(
      hour: _startDate!.hour,
      minute: _startDate!.minute,
    )
        : const TimeOfDay(
      hour: 0,
      minute: 0,
    );

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

  // ============================================================
  // END DATE
  // ============================================================

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      _endDate ??
          _startDate ??
          DateTime.now(),
      firstDate:
      _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );

    if (picked == null || !mounted) {
      return;
    }

    final pickedTime =
    _endDate != null
        ? TimeOfDay(
      hour: _endDate!.hour,
      minute: _endDate!.minute,
    )
        : const TimeOfDay(
      hour: 23,
      minute: 59,
    );

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isEditing =
        widget.banner != null;

    final provider =
    context.read<AdminBannerProvider>();

    // ==========================================================
    // PROMOTIONAL LIMIT
    // ==========================================================

    if (_bannerType == 'promotional') {
      final promotionalCount =
          provider.banners
              .where(
                (item) =>
            item.bannerType ==
                'promotional',
          )
              .where(
                (item) =>
            item.id !=
                widget.banner?.id,
          )
              .length;

      if (promotionalCount >= 4) {
        _showMessage(
          'حداکثر ۴ بنر تبلیغاتی می‌توانید داشته باشید.',
        );
        return;
      }
    }

    // ==========================================================
    // NEW IMAGE
    // ==========================================================

    if (!isEditing &&
        _selectedImage == null) {
      _showMessage(
        'برای بنر جدید تصویر انتخاب کنید.',
      );
      return;
    }

    // ==========================================================
    // DATES
    // ==========================================================

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(
          _startDate!,
        )) {
      _showMessage(
        'تاریخ پایان نمی‌تواند قبل از تاریخ شروع باشد.',
      );
      return;
    }

    // ==========================================================
    // ACTION
    // ==========================================================

    final actionType =
    _actionType == 'none'
        ? null
        : _actionType;

    final actionValue =
    actionType == null
        ? null
        : _actionValueController
        .text
        .trim()
        .isEmpty
        ? null
        : _actionValueController
        .text
        .trim();

    if (actionType != null &&
        (actionValue == null ||
            actionValue.isEmpty)) {
      _showMessage(
        'مقدار عملکرد بنر را وارد کنید.',
      );
      return;
    }

    // ==========================================================
    // SORT ORDER
    // ==========================================================

    final sortOrder = int.tryParse(
      _sortOrderController.text.trim(),
    );

    if (sortOrder == null) {
      _showMessage(
        'ترتیب نمایش معتبر نیست.',
      );
      return;
    }

    // ==========================================================
    // UPDATE
    // ==========================================================

    bool success;

    if (isEditing) {
      final banner =
      widget.banner!;

      success =
      await provider.updateBanner(
        bannerId: banner.id,
        title:
        _titleController.text.trim(),
        description:
        _descriptionController
            .text
            .trim()
            .isEmpty
            ? null
            : _descriptionController
            .text
            .trim(),
        newImage:
        _selectedImage,
        currentImagePath:
        banner.imagePath,
        bannerType:
        _bannerType,
        actionType:
        actionType,
        actionValue:
        actionValue,
        sortOrder:
        sortOrder,
        isActive:
        _isActive,
        startDate:
        _startDate,
        endDate:
        _endDate,
      );
    } else {
      success =
      await provider.createBanner(
        title:
        _titleController.text.trim(),
        description:
        _descriptionController
            .text
            .trim()
            .isEmpty
            ? null
            : _descriptionController
            .text
            .trim(),
        image:
        _selectedImage!,
        bannerType:
        _bannerType,
        actionType:
        actionType,
        actionValue:
        actionValue,
        sortOrder:
        sortOrder,
        isActive:
        _isActive,
        startDate:
        _startDate,
        endDate:
        _endDate,
      );
    }

    if (!mounted) {
      return;
    }

    if (!success) {
      _showMessage(
        provider.errorMessage ??
            'ذخیره بنر انجام نشد.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'انتخاب نشده';
    }

    return '${date.year}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final isEditing =
        widget.banner != null;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'ویرایش بنر'
              : 'بنر جدید',
        ),
        backgroundColor:
        const Color(0xFF03045e),
        foregroundColor:
        Colors.white,
      ),
      body:
      Consumer<AdminBannerProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return Form(
            key: _formKey,
            child: ListView(
              padding:
              EdgeInsets.all(16.w),
              children: [

                // ==================================================
                // IMAGE
                // ==================================================

                _SectionContainer(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [

                      Text(
                        'تصویر بنر',
                        style:
                        TextStyle(
                          fontSize:
                          15.sp,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      SizedBox(
                        height: 6.h,
                      ),

                      Text(
                        '$_bannerTypeTitle • '
                            'سایز نهایی $_bannerSizeText',
                        textAlign:
                        TextAlign.right,
                        style:
                        TextStyle(
                          fontSize:
                          12.sp,
                          color:
                          const Color(
                            0xFF03045e,
                          ),
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      SizedBox(
                        height: 6.h,
                      ),

                      Text(
                        'تصویر پس از انتخاب به صورت خودکار '
                            'برش داده شده، به این ابعاد تبدیل '
                            'و با فرمت WebP ذخیره می‌شود.',
                        textAlign:
                        TextAlign.right,
                        style:
                        TextStyle(
                          fontSize:
                          11.sp,
                          color:
                          Colors
                              .grey
                              .shade700,
                          height:
                          1.6,
                        ),
                      ),

                      SizedBox(
                        height: 12.h,
                      ),

                      ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14.r,
                        ),
                        child:
                        _isProcessingImage
                            ? Container(
                          height:
                          _bannerType ==
                              'promotional'
                              ? 190.h
                              : 150.h,
                          color:
                          Colors
                              .grey
                              .shade200,
                          child:
                          const Center(
                            child:
                            CircularProgressIndicator(),
                          ),
                        )
                            : _selectedImage !=
                            null
                            ? Image.file(
                          File(
                            _selectedImage!
                                .path,
                          ),
                          height:
                          _bannerType ==
                              'promotional'
                              ? 190.h
                              : 150.h,
                          width:
                          double
                              .infinity,
                          fit:
                          BoxFit.cover,
                        )
                            : widget.banner !=
                            null
                            ? Image.network(
                          widget
                              .banner!
                              .imageUrl,
                          height:
                          _bannerType ==
                              'promotional'
                              ? 190.h
                              : 150.h,
                          width:
                          double.infinity,
                          fit:
                          BoxFit.cover,
                        )
                            : Container(
                          height:
                          _bannerType ==
                              'promotional'
                              ? 190.h
                              : 150.h,
                          color:
                          Colors
                              .grey
                              .shade200,
                          child:
                          const Center(
                            child:
                            Icon(
                              Icons
                                  .image_outlined,
                              size:
                              42,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 12.h,
                      ),

                      OutlinedButton.icon(
                        onPressed:
                        provider.isSaving ||
                            _isProcessingImage
                            ? null
                            : _pickImage,
                        icon:
                        const Icon(
                          Icons
                              .photo_library_outlined,
                        ),
                        label:
                        Text(
                          isEditing
                              ? 'جایگزینی تصویر'
                              : 'انتخاب تصویر',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // BASIC INFO
                // ==================================================

                _SectionContainer(
                  child: Column(
                    children: [

                      TextFormField(
                        controller:
                        _titleController,
                        textDirection:
                        TextDirection.rtl,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'عنوان بنر',
                          border:
                          OutlineInputBorder(),
                        ),
                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'عنوان بنر را وارد کنید.';
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: 12.h,
                      ),

                      TextFormField(
                        controller:
                        _descriptionController,
                        textDirection:
                        TextDirection.rtl,
                        maxLines: 3,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'توضیحات',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // BANNER TYPE
                // ==================================================

                _SectionContainer(
                  child:
                  DropdownButtonFormField<
                      String>(
                    value:
                    _bannerType,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'نوع بنر',
                      border:
                      OutlineInputBorder(),
                    ),
                    items:
                    const [
                      DropdownMenuItem(
                        value:
                        'hero',
                        child:
                        Text(
                          'هیرو',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'promotional',
                        child:
                        Text(
                          'تبلیغاتی',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                        'bottom_home',
                        child:
                        Text(
                          'بنر پایین صفحه',
                        ),
                      ),
                    ],
                    onChanged:
                    provider.isSaving
                        ? null
                        : (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        _bannerType =
                            value;
                      });
                    },
                  ),
                ),

                SizedBox(
                  height: 10.h,
                ),

                _BannerInfoBox(
                  bannerType:
                  _bannerType,
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // ACTION
                // ==================================================

                _SectionContainer(
                  child: Column(
                    children: [

                      DropdownButtonFormField<
                          String>(
                        value:
                        _actionType,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'عملکرد هنگام کلیک',
                          border:
                          OutlineInputBorder(),
                        ),
                        items:
                        const [
                          DropdownMenuItem(
                            value:
                            'none',
                            child:
                            Text(
                              'بدون عملکرد',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            'product',
                            child:
                            Text(
                              'باز کردن محصول',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            'category',
                            child:
                            Text(
                              'باز کردن دسته‌بندی',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            'url',
                            child:
                            Text(
                              'لینک',
                            ),
                          ),
                        ],
                        onChanged:
                        provider.isSaving
                            ? null
                            : (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            _actionType =
                                value;
                          });
                        },
                      ),

                      SizedBox(
                        height: 12.h,
                      ),

                      TextFormField(
                        controller:
                        _actionValueController,
                        textDirection:
                        TextDirection.ltr,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'مقدار عملکرد',
                          hintText:
                          'شناسه محصول / دسته‌بندی / URL',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),

                      if (_actionType ==
                          'url') ...[
                        SizedBox(
                          height: 8.h,
                        ),
                        Align(
                          alignment:
                          Alignment
                              .centerRight,
                          child:
                          Text(
                            'توجه: در حال حاضر Navigation لینک در اپ فعال نشده است.',
                            textAlign:
                            TextAlign
                                .right,
                            style:
                            TextStyle(
                              fontSize:
                              11.sp,
                              color:
                              Colors
                                  .orange
                                  .shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // SORT ORDER
                // ==================================================

                _SectionContainer(
                  child:
                  TextFormField(
                    controller:
                    _sortOrderController,
                    textDirection:
                    TextDirection.ltr,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'ترتیب نمایش',
                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                ),

                SizedBox(
                  height: 14.h,
                ),

                // ==================================================
                // DATES
                // ==================================================

                _SectionContainer(
                  child: Column(
                    children: [

                      ListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        title:
                        const Text(
                          'تاریخ شروع',
                        ),
                        subtitle:
                        Text(
                          _formatDate(
                            _startDate,
                          ),
                        ),
                        trailing:
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                        ),
                        onTap:
                        provider.isSaving
                            ? null
                            : _pickStartDate,
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        title:
                        const Text(
                          'تاریخ پایان',
                        ),
                        subtitle:
                        Text(
                          _formatDate(
                            _endDate,
                          ),
                        ),
                        trailing:
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                        ),
                        onTap:
                        provider.isSaving
                            ? null
                            : _pickEndDate,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 24.h,
                ),

                // ==================================================
                // SAVE
                // ==================================================

                SizedBox(
                  height: 52.h,
                  child:
                  FilledButton(
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF03045e,
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
                    provider.isSaving ||
                        _isProcessingImage
                        ? null
                        : _submit,
                    child:
                    provider.isSaving
                        ? const SizedBox(
                      width:
                      22,
                      height:
                      22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2.5,
                        color:
                        Colors.white,
                      ),
                    )
                        : Text(
                      isEditing
                          ? 'ذخیره تغییرات'
                          : 'افزودن بنر',
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
          );
        },
      ),
    );
  }
}

// ================================================================
// BANNER INFO BOX
// ================================================================

class _BannerInfoBox
    extends StatelessWidget {
  const _BannerInfoBox({
    required this.bannerType,
  });

  final String bannerType;

  @override
  Widget build(
      BuildContext context,
      ) {
    String title;
    String description;
    String size;

    switch (bannerType) {
      case 'promotional':
        title =
        'بنر تبلیغاتی';

        description =
        'برای بنرهای تبلیغاتی صفحه اصلی استفاده می‌شود. '
            'حداکثر ۴ بنر تبلیغاتی قابل ثبت است.';

        size =
        '1700 × 1200 px';

        break;

      case 'bottom_home':
        title =
        'بنر پایین صفحه';

        description =
        'برای نمایش یک بنر ثابت در قسمت پایین صفحه اصلی استفاده می‌شود.';

        size =
        '1700 × 850 px';

        break;

      case 'hero':
      default:
        title =
        'بنر هیرو';

        description =
        'بنر اصلی و بزرگ بالای صفحه اصلی فروشگاه.';

        size =
        '1700 × 850 px';

        break;
    }

    return Container(
      padding:
      EdgeInsets.all(12.w),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFEFF6FF,
        ),
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        border:
        Border.all(
          color:
          const Color(
            0xFFD8E8FF,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Icon(
            Icons.info_outline,
            color:
            Color(
              0xFF03045e,
            ),
          ),

          SizedBox(
            width: 10.w,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [

                Text(
                  title,
                  textAlign:
                  TextAlign.right,
                  style:
                  TextStyle(
                    fontSize:
                    12.sp,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    const Color(
                      0xFF03045e,
                    ),
                  ),
                ),

                SizedBox(
                  height: 4.h,
                ),

                Text(
                  description,
                  textAlign:
                  TextAlign.right,
                  style:
                  TextStyle(
                    fontSize:
                    11.sp,
                    color:
                    Colors
                        .grey
                        .shade700,
                    height:
                    1.5,
                  ),
                ),

                SizedBox(
                  height: 6.h,
                ),

                Text(
                  'سایز نهایی تصویر: $size',
                  textAlign:
                  TextAlign.right,
                  style:
                  TextStyle(
                    fontSize:
                    11.sp,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF03045e,
                    ),
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

class _SectionContainer
    extends StatelessWidget {
  const _SectionContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.all(14.w),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          16.r,
        ),
      ),
      child: child,
    );
  }
}