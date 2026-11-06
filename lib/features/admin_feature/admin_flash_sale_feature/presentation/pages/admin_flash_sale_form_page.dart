
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_entity.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/domain/entities/admin_flash_sale_product_option.dart';
import 'package:supastore/features/admin_feature/admin_flash_sale_feature/presentation/providers/admin_flash_sales_provider.dart';

class AdminFlashSaleFormPage extends StatelessWidget {
  const AdminFlashSaleFormPage({
    super.key,
    this.flashSale,
  });

  final AdminFlashSaleEntity? flashSale;

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

class _AdminFlashSaleFormView extends StatefulWidget {
  const _AdminFlashSaleFormView({
    required this.flashSale,
  });

  final AdminFlashSaleEntity? flashSale;

  @override
  State<_AdminFlashSaleFormView> createState() =>
      _AdminFlashSaleFormViewState();
}

class _AdminFlashSaleFormViewState
    extends State<_AdminFlashSaleFormView> {
  static const Color primaryColor = Color(0xFF03045E);
  static const Color secondaryColor = Color(0xFF023E8A);
  static const Color dangerColor = Color(0xFFE21B23);
  static const Color backgroundColor = Color(0xFFF7F7F8);

  final _formKey = GlobalKey<FormState>();

  final _discountController = TextEditingController();
  final _sortOrderController = TextEditingController();

  AdminFlashSaleProductOption? _selectedProduct;

  DateTime? _startAt;
  DateTime? _endAt;

  bool _isActive = true;

  bool get _isEditing => widget.flashSale != null;

  @override
  void initState() {
    super.initState();

    final flashSale = widget.flashSale;

    if (flashSale != null) {
      _discountController.text =
          flashSale.discountPrice.toString();

      _sortOrderController.text =
          flashSale.sortOrder.toString();

      _startAt = flashSale.startAt;
      _endAt = flashSale.endAt;
      _isActive = flashSale.isActive;

      _selectedProduct = AdminFlashSaleProductOption(
        id: flashSale.productId,
        title: flashSale.product.title,
        thumbnail: flashSale.product.thumbnail,
        price: flashSale.product.price,
      );
    } else {
      final now = DateTime.now();

      _startAt = now;
      _endAt = now.add(const Duration(hours: 2));

      _sortOrderController.text = '0';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _sortOrderController.dispose();

    super.dispose();
  }

  // =========================================================
  // PRODUCT PICKER
  // =========================================================

  Future<void> _selectProduct() async {
    final provider = context.read<AdminFlashSalesProvider>();

    await provider.searchProducts();

    if (!mounted) return;

    final width = MediaQuery.sizeOf(context).width;

    final AdminFlashSaleProductOption? selected;

    if (width >= 700) {
      selected = await showDialog<AdminFlashSaleProductOption>(
        context: context,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.white,
            clipBehavior: Clip.antiAlias,
            insetPadding: const EdgeInsets.all(24),
            child: ChangeNotifierProvider.value(
              value: provider,
              child: const SizedBox(
                width: 650,
                height: 650,
                child: _ProductPicker(),
              ),
            ),
          );
        },
      );
    } else {
      selected = await showModalBottomSheet<
          AdminFlashSaleProductOption>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: provider,
            child: const _ProductPicker(),
          );
        },
      );
    }

    if (selected == null || !mounted) return;

    setState(() {
      _selectedProduct = selected;
    });

    if (_discountController.text.trim().isEmpty) {
      final defaultDiscount = (selected.price * 0.9).round();

      _discountController.text = defaultDiscount.toString();
    }
  }

  // =========================================================
  // DATE PICKERS
  // =========================================================

  Future<void> _pickStartDate() async {
    final date = await _pickDateTime(
      initialDate: _startAt ?? DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() {
        _startAt = date;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await _pickDateTime(
      initialDate: _endAt ??
          (_startAt ?? DateTime.now()).add(
            const Duration(hours: 2),
          ),
    );

    if (date != null && mounted) {
      setState(() {
        _endAt = date;
      });
    }
  }

  Future<DateTime?> _pickDateTime({
    required DateTime initialDate,
  }) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now.subtract(
        const Duration(days: 1),
      ))
          ? now
          : initialDate,
      firstDate: now.subtract(
        const Duration(days: 1),
      ),
      lastDate: now.add(
        const Duration(days: 365),
      ),
      locale: const Locale('fa'),
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'انتخاب نشده';

    final date = '${value.year}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.day.toString().padLeft(2, '0')}';

    final time = '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';

    return '$date - $time';
  }

  int? _parseInt(String value) {
    return int.tryParse(
      value.trim().replaceAll(',', ''),
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProduct == null) {
      _showError('لطفاً یک محصول انتخاب کنید.');
      return;
    }

    if (_startAt == null || _endAt == null) {
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

    final discountPrice = _parseInt(
      _discountController.text,
    );

    if (discountPrice == null || discountPrice <= 0) {
      _showError('قیمت فروش ویژه معتبر نیست.');
      return;
    }

    if (discountPrice >= _selectedProduct!.price) {
      _showError(
        'قیمت فروش ویژه باید کمتر از قیمت اصلی محصول باشد.',
      );
      return;
    }

    final sortOrder = _parseInt(
      _sortOrderController.text,
    ) ??
        0;

    if (sortOrder < 0) {
      _showError('اولویت نمی‌تواند منفی باشد.');
      return;
    }

    final provider = context.read<AdminFlashSalesProvider>();

    bool success;

    if (_isEditing) {
      success = await provider.updateFlashSale(
        id: widget.flashSale!.id,
        productId: _selectedProduct!.id,
        discountPrice: discountPrice,
        startAt: _startAt!,
        endAt: _endAt!,
        isActive: _isActive,
        sortOrder: sortOrder,
      );
    } else {
      success = await provider.createFlashSale(
        productId: _selectedProduct!.id,
        discountPrice: discountPrice,
        startAt: _startAt!,
        endAt: _endAt!,
        isActive: _isActive,
        sortOrder: sortOrder,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    _showError(
      provider.errorMessage ?? 'عملیات انجام نشد.',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final double maxWidth;
            final bool twoColumns;

            if (width < 600) {
              maxWidth = 600;
              twoColumns = false;
            } else if (width < 1100) {
              maxWidth = 850;
              twoColumns = true;
            } else {
              maxWidth = 1100;
              twoColumns = true;
            }

            return Consumer<AdminFlashSalesProvider>(
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal: width < 600 ? 16 : 24,
                              vertical: 24,
                            ),
                            children: [
                              _buildHeader(),

                              const SizedBox(height: 24),

                              _buildSectionTitle(
                                'اطلاعات محصول',
                                Iconsax.box_copy,
                              ),

                              const SizedBox(height: 12),

                              _buildProductSelector(),

                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                'قیمت و اولویت',
                                Iconsax.money_copy,
                              ),

                              const SizedBox(height: 12),

                              _buildResponsiveWrap(
                                twoColumns: twoColumns,
                                children: [
                                  _buildDiscountField(),
                                  _buildSortOrderField(),
                                ],
                              ),

                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                'زمان‌بندی فروش ویژه',
                                Iconsax.calendar_copy,
                              ),

                              const SizedBox(height: 12),

                              _buildResponsiveWrap(
                                twoColumns: twoColumns,
                                children: [
                                  _buildDateTimeTile(
                                    title: 'شروع فروش ویژه',
                                    value: _formatDateTime(_startAt),
                                    icon: Iconsax.play_circle_copy,
                                    onTap: _pickStartDate,
                                  ),
                                  _buildDateTimeTile(
                                    title: 'پایان فروش ویژه',
                                    value: _formatDateTime(_endAt),
                                    icon: Iconsax.calendar_2_copy,
                                    onTap: _pickEndDate,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                'وضعیت فروش ویژه',
                                Iconsax.setting_2_copy,
                              ),

                              const SizedBox(height: 12),

                              _buildStatusCard(),

                              const SizedBox(height: 32),

                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ),
                                  child: _buildSubmitButton(
                                    provider.isSubmitting,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.flash_1_copy,
              color: primaryColor,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'ویرایش فروش ویژه'
                      : 'ایجاد فروش ویژه جدید',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _isEditing
                      ? 'اطلاعات فروش ویژه را ویرایش کنید.'
                      : 'محصول و شرایط فروش ویژه را مشخص کنید.',
                  style: TextStyle(
                    fontSize: 11,
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

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: secondaryColor,
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // RESPONSIVE WRAP
  // =========================================================

  Widget _buildResponsiveWrap({
    required bool twoColumns,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }

  // =========================================================
  // PRODUCT SELECTOR
  // =========================================================

  Widget _buildProductSelector() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _selectProduct,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (_selectedProduct != null)
                _buildProductImage(
                  _selectedProduct!.thumbnail,
                  70,
                )
              else
                _buildProductPlaceholder(70),

              const SizedBox(width: 14),

              Expanded(
                child: _selectedProduct == null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'انتخاب محصول',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'برای انتخاب محصول کلیک کنید.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProduct!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '${_selectedProduct!.price} تومان',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'برای تغییر محصول کلیک کنید',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade600,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
      String url,
      double size,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildProductPlaceholder(size);
        },
      ),
    );
  }

  Widget _buildProductPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Iconsax.image_copy,
        color: Colors.grey.shade400,
        size: 25,
      ),
    );
  }

  // =========================================================
  // DISCOUNT FIELD
  // =========================================================

  Widget _buildDiscountField() {
    return TextFormField(
      controller: _discountController,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      decoration: _inputDecoration(
        label: 'قیمت فروش ویژه',
        hint: 'مثلاً 1500000',
        suffix: 'تومان',
      ),
      validator: (value) {
        final price = _parseInt(value ?? '');

        if (price == null || price <= 0) {
          return 'قیمت را وارد کنید.';
        }

        if (_selectedProduct != null &&
            price >= _selectedProduct!.price) {
          return 'باید کمتر از قیمت اصلی باشد.';
        }

        return null;
      },
    );
  }

  // =========================================================
  // SORT ORDER FIELD
  // =========================================================

  Widget _buildSortOrderField() {
    return TextFormField(
      controller: _sortOrderController,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      decoration: _inputDecoration(
        label: 'اولویت نمایش',
        hint: 'مثلاً 0',
        prefixIcon: Iconsax.sort_copy,
      ),
      validator: (value) {
        final number = _parseInt(value ?? '');

        if (number == null || number < 0) {
          return 'اولویت معتبر نیست.';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    String? suffix,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 19)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: dangerColor,
        ),
      ),
    );
  }

  // =========================================================
  // DATE TIME TILE
  // =========================================================

  Widget _buildDateTimeTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_left_rounded,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATUS CARD
  // =========================================================

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        title: const Text(
          'فعال بودن فروش ویژه',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'در صورت فعال بودن و رسیدن زمان شروع، فروش ویژه نمایش داده می‌شود.',
            style: TextStyle(
              fontSize: 11,
              height: 1.7,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        value: _isActive,
        activeTrackColor: primaryColor,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
      ),
    );
  }

  // =========================================================
  // SUBMIT BUTTON
  // =========================================================

  Widget _buildSubmitButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: dangerColor,
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.tick_circle_copy,
              size: 19,
            ),

            const SizedBox(width: 9),

            Text(
              _isEditing
                  ? 'ذخیره تغییرات'
                  : 'ایجاد فروش ویژه',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT PICKER
// ============================================================

class _ProductPicker extends StatefulWidget {
  const _ProductPicker();

  @override
  State<_ProductPicker> createState() =>
      _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  static const Color primaryColor = Color(0xFF03045E);

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await context.read<AdminFlashSalesProvider>().searchProducts(
      query: _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // HEADER

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.box_copy,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'انتخاب محصول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // SEARCH

                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'جستجوی محصول...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.search_normal_copy,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _search,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PRODUCT LIST

                Expanded(
                  child: Consumer<AdminFlashSalesProvider>(
                    builder: (context, provider, child) {
                      if (provider.isSearchingProducts) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        );
                      }

                      if (provider.productOptions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.box_remove_copy,
                                size: 45,
                                color: Colors.grey.shade400,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'محصولی پیدا نشد.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, listConstraints) {
                          final columns =
                          listConstraints.maxWidth >= 550 ? 2 : 1;

                          if (columns == 1) {
                            return ListView.separated(
                              itemCount: provider.productOptions.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final product =
                                provider.productOptions[index];

                                return _ProductOptionTile(
                                  product: product,
                                  onTap: () {
                                    Navigator.pop(context, product);
                                  },
                                );
                              },
                            );
                          }

                          return GridView.builder(
                            itemCount: provider.productOptions.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 100,
                            ),
                            itemBuilder: (context, index) {
                              final product =
                              provider.productOptions[index];

                              return _ProductOptionTile(
                                product: product,
                                onTap: () {
                                  Navigator.pop(context, product);
                                },
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
          );
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT OPTION TILE
// ============================================================

class _ProductOptionTile extends StatelessWidget {
  const _ProductOptionTile({
    required this.product,
    required this.onTap,
  });

  final AdminFlashSaleProductOption product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  product.thumbnail,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 58,
                      height: 58,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Iconsax.image_copy,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${product.price} تومان',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              Icon(
                Icons.chevron_left_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
