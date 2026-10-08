import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/providers/admin_flash_sales_provider.dart';

class AdminFlashSaleFormPage
    extends StatelessWidget {
  const AdminFlashSaleFormPage({
    super.key,
    this.flashSale,
  });

  final AdminFlashSaleEntity? flashSale;

  bool get isEditing => flashSale != null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<AdminFlashSalesProvider>(),
      child: _AdminFlashSaleFormView(
        flashSale: flashSale,
      ),
    );
  }
}

class _AdminFlashSaleFormView
    extends StatefulWidget {
  const _AdminFlashSaleFormView({
    required this.flashSale,
  });

  final AdminFlashSaleEntity? flashSale;

  @override
  State<_AdminFlashSaleFormView>
  createState() =>
      _AdminFlashSaleFormViewState();
}

class _AdminFlashSaleFormViewState
    extends State<_AdminFlashSaleFormView> {
  final _formKey =
  GlobalKey<FormState>();

  final _discountController =
  TextEditingController();

  final _sortOrderController =
  TextEditingController();

  AdminFlashSaleProductOption? _selectedProduct;

  DateTime? _startAt;
  DateTime? _endAt;

  bool _isActive = true;

  bool get _isEditing =>
      widget.flashSale != null;

  @override
  void initState() {
    super.initState();

    final flashSale =
        widget.flashSale;

    if (flashSale != null) {
      _discountController.text =
          flashSale.discountPrice.toString();

      _sortOrderController.text =
          flashSale.sortOrder.toString();

      _startAt = flashSale.startAt;
      _endAt = flashSale.endAt;

      _isActive =
          flashSale.isActive;

      _selectedProduct =
          AdminFlashSaleProductOption(
            id: flashSale.productId,
            title: flashSale.product.title,
            thumbnail:
            flashSale.product.thumbnail,
            price:
            flashSale.product.price,
          );
    } else {
      final now = DateTime.now();

      _startAt = now;
      _endAt =
          now.add(const Duration(hours: 2));

      _sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _sortOrderController.dispose();

    super.dispose();
  }

  Future<void> _selectProduct() async {
    final provider =
    context.read<AdminFlashSalesProvider>();

    await provider.searchProducts();

    if (!mounted) {
      return;
    }

    final selected =
    await showModalBottomSheet<
        AdminFlashSaleProductOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: const _ProductPicker(),
        );
      },
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedProduct = selected;
    });

    if (_discountController.text
        .trim()
        .isEmpty) {
      final defaultDiscount =
      (selected.price * 0.9).round();

      _discountController.text =
          defaultDiscount.toString();
    }
  }

  Future<void> _pickStartDate() async {
    final date =
    await _pickDateTime(
      initialDate:
      _startAt ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startAt = date;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date =
    await _pickDateTime(
      initialDate:
      _endAt ??
          (_startAt ??
              DateTime.now()).add(
            const Duration(hours: 2),
          ),
    );

    if (date != null) {
      setState(() {
        _endAt = date;
      });
    }
  }

  Future<DateTime?> _pickDateTime({
    required DateTime initialDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      locale: const Locale('fa'),
    );

    if (date == null ||
        !mounted) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime:
      TimeOfDay.fromDateTime(
        initialDate,
      ),
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String _formatDateTime(
      DateTime? value,
      ) {
    if (value == null) {
      return 'انتخاب نشده';
    }

    final date =
        '${value.year}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.day.toString().padLeft(2, '0')}';

    final time =
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';

    return '$date - $time';
  }

  int? _parseInt(
      String value,
      ) {
    return int.tryParse(
      value.trim().replaceAll(
        ',',
        '',
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedProduct == null) {
      _showError(
        'لطفاً یک محصول انتخاب کنید.',
      );
      return;
    }

    if (_startAt == null ||
        _endAt == null) {
      _showError(
        'لطفاً تاریخ و زمان شروع و پایان را انتخاب کنید.',
      );
      return;
    }

    if (!_endAt!.isAfter(_startAt!)) {
      _showError(
        'زمان پایان باید بعد از زمان شروع باشد.',
      );
      return;
    }

    final discountPrice =
    _parseInt(
      _discountController.text,
    );

    if (discountPrice == null ||
        discountPrice <= 0) {
      _showError(
        'قیمت فروش ویژه معتبر نیست.',
      );
      return;
    }

    if (discountPrice >=
        _selectedProduct!.price) {
      _showError(
        'قیمت فروش ویژه باید کمتر از قیمت اصلی محصول باشد.',
      );
      return;
    }

    final sortOrder =
        _parseInt(
          _sortOrderController.text,
        ) ??
            0;

    if (sortOrder < 0) {
      _showError(
        'اولویت نمی‌تواند منفی باشد.',
      );
      return;
    }

    final provider =
    context.read<AdminFlashSalesProvider>();

    bool success;

    if (_isEditing) {
      success =
      await provider.updateFlashSale(
        id: widget.flashSale!.id,
        productId:
        _selectedProduct!.id,
        discountPrice: discountPrice,
        startAt: _startAt!,
        endAt: _endAt!,
        isActive: _isActive,
        sortOrder: sortOrder,
      );
    } else {
      success =
      await provider.createFlashSale(
        productId:
        _selectedProduct!.id,
        discountPrice: discountPrice,
        startAt: _startAt!,
        endAt: _endAt!,
        isActive: _isActive,
        sortOrder: sortOrder,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(
        context,
        true,
      );

      return;
    }

    _showError(
      provider.errorMessage ??
          'عملیات انجام نشد.',
    );
  }

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03045e),
          foregroundColor: Colors.white,
          title: Text(
            _isEditing
                ? 'ویرایش فروش ویژه'
                : 'فروش ویژه جدید',
          ),
          centerTitle: true,
        ),
        body: Consumer<
            AdminFlashSalesProvider>(
          builder: (
              context,
              provider,
              child,
              ) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildSectionTitle(
                    'محصول',
                  ),
                  SizedBox(height: 8.h),
                  _buildProductSelector(),
                  SizedBox(height: 20.h),
                  _buildSectionTitle(
                    'قیمت',
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller:
                    _discountController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'قیمت فروش ویژه',
                      suffixText: 'تومان',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price =
                      _parseInt(
                        value ?? '',
                      );

                      if (price == null ||
                          price <= 0) {
                        return 'قیمت را وارد کنید.';
                      }

                      if (_selectedProduct !=
                          null &&
                          price >=
                              _selectedProduct!
                                  .price) {
                        return 'باید کمتر از قیمت اصلی باشد.';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller:
                    _sortOrderController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'اولویت نمایش',
                      hintText: 'مثلاً 0',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final number =
                      _parseInt(
                        value ?? '',
                      );

                      if (number == null ||
                          number < 0) {
                        return 'اولویت معتبر نیست.';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionTitle(
                    'زمان‌بندی',
                  ),
                  SizedBox(height: 8.h),
                  _buildDateTimeTile(
                    title: 'شروع فروش ویژه',
                    value:
                    _formatDateTime(
                      _startAt,
                    ),
                    icon: Iconsax.play_circle_copy,
                    onTap:
                    _pickStartDate,
                  ),
                  SizedBox(height: 10.h),
                  _buildDateTimeTile(
                    title: 'پایان فروش ویژه',
                    value:
                    _formatDateTime(
                      _endAt,
                    ),
                    icon: Iconsax.calendar_2_copy,
                    onTap:
                    _pickEndDate,
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionTitle(
                    'وضعیت',
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration:
                    BoxDecoration(
                      border: Border.all(
                        color: Colors
                            .grey.shade300,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        12.r,
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      title: const Text(
                        'فعال بودن فروش ویژه',
                      ),
                      subtitle: const Text(
                        'در صورت فعال بودن و رسیدن زمان شروع، فروش ویژه نمایش داده می‌شود.',
                      ),
                      value: _isActive,
                      activeTrackColor:
                      const Color(
                        0xFF03045e,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isActive =
                              value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed:
                      provider.isSubmitting
                          ? null
                          : _submit,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFFE21B23,
                        ),
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
                      child: provider
                          .isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                          Colors.white,
                        ),
                      )
                          : Text(
                        _isEditing
                            ? 'ذخیره تغییرات'
                            : 'ایجاد فروش ویژه',
                        style: TextStyle(
                          fontSize:
                          14.sp,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(
          0xFF222222,
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return InkWell(
      onTap: _selectProduct,
      borderRadius:
      BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
          BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            if (_selectedProduct != null)
              ClipRRect(
                borderRadius:
                BorderRadius.circular(8.r),
                child: Image.network(
                  _selectedProduct!.thumbnail,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      width: 60.w,
                      height: 60.w,
                      color:
                      Colors.grey.shade100,
                      child: const Icon(
                        Iconsax.image_copy,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color:
                  Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(
                    8.r,
                  ),
                ),
                child: Icon(
                  Iconsax.image_copy,
                  color:
                  Colors.grey.shade500,
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: _selectedProduct == null
                  ? Text(
                'انتخاب محصول',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors
                      .grey.shade700,
                ),
              )
                  : Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    _selectedProduct!
                        .title,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_selectedProduct!.price} تومان',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
          BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(
                0xFF03045e,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPicker
    extends StatefulWidget {
  const _ProductPicker();

  @override
  State<_ProductPicker> createState() =>
      _ProductPickerState();
}

class _ProductPickerState
    extends State<_ProductPicker> {
  final _searchController =
  TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _search() async {
    await context
        .read<AdminFlashSalesProvider>()
        .searchProducts(
      query:
      _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height:
        MediaQuery.of(context)
            .size
            .height *
            0.85,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'انتخاب محصول',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              TextField(
                controller:
                _searchController,
                textInputAction:
                TextInputAction.search,
                onSubmitted: (_) {
                  _search();
                },
                decoration:
                InputDecoration(
                  hintText:
                  'جستجوی محصول...',
                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                  IconButton(
                    onPressed: _search,
                    icon: const Icon(
                      Icons
                          .arrow_forward_rounded,
                    ),
                  ),
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12.r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Consumer<
                    AdminFlashSalesProvider>(
                  builder: (
                      context,
                      provider,
                      child,
                      ) {
                    if (provider
                        .isSearchingProducts) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    if (provider
                        .productOptions
                        .isEmpty) {
                      return Center(
                        child: Text(
                          'محصولی پیدا نشد.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider
                          .productOptions
                          .length,
                      itemBuilder:
                          (context, index) {
                        final product =
                        provider
                            .productOptions[
                        index];

                        return _ProductOptionTile(
                          product: product,
                          onTap: () {
                            Navigator.pop(
                              context,
                              product,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductOptionTile
    extends StatelessWidget {
  const _ProductOptionTile({
    required this.product,
    required this.onTap,
  });

  final AdminFlashSaleProductOption
  product;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12.r),
      child: Padding(
        padding:
        EdgeInsets.symmetric(
          vertical: 8.h,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                8.r,
              ),
              child: Image.network(
                product.thumbnail,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    width: 60.w,
                    height: 60.w,
                    color:
                    Colors.grey.shade100,
                    child: const Icon(
                      Iconsax.image_copy,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '${product.price} تومان',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons
                  .chevron_left_rounded,
              color:
              Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}