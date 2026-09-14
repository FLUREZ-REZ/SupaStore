import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:supastore/features/admin_feature/shipping/domain/entities/admin_shipping_method_entity.dart';
import 'package:supastore/features/admin_feature/shipping/presentation/providers/admin_shipping_provider.dart';

class AddEditShippingMethodPage extends StatefulWidget {
  const AddEditShippingMethodPage({
    super.key,
    this.shippingMethod,
  });

  final AdminShippingMethodEntity? shippingMethod;

  bool get isEditing => shippingMethod != null;

  @override
  State<AddEditShippingMethodPage> createState() =>
      _AddEditShippingMethodPageState();
}

class _AddEditShippingMethodPageState
    extends State<AddEditShippingMethodPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _estimatedDaysController;
  late final TextEditingController _sortOrderController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    final method = widget.shippingMethod;

    _titleController = TextEditingController(
      text: method?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: method?.description ?? '',
    );

    _costController = TextEditingController(
      text: method?.cost.toString() ?? '',
    );

    _estimatedDaysController =
        TextEditingController(
          text: method?.estimatedDays ?? '',
        );

    _sortOrderController =
        TextEditingController(
          text: method?.sortOrder.toString() ?? '0',
        );

    _isActive = method?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _estimatedDaysController.dispose();
    _sortOrderController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

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
            isEditing
                ? 'ویرایش روش ارسال'
                : 'افزودن روش ارسال',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Consumer<AdminShippingProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
              child: ListView(
                physics:
                const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  18.h,
                  16.w,
                  30.h,
                ),
                children: [
                  _buildHeader(isEditing),
                  SizedBox(height: 18.h),
                  _buildFormCard(provider),
                  SizedBox(height: 18.h),
                  _buildActiveCard(),
                  SizedBox(height: 24.h),
                  _buildSaveButton(
                    provider,
                    isEditing,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(15.r),
            ),
            child: Icon(
              isEditing
                  ? Icons.edit_location_alt_outlined
                  : Icons.local_shipping_outlined,
              color: Colors.indigo,
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
                  isEditing
                      ? 'ویرایش روش ارسال'
                      : 'روش ارسال جدید',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  isEditing
                      ? 'اطلاعات روش ارسال را ویرایش کنید.'
                      : 'اطلاعات روش ارسال جدید را وارد کنید.',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.5,
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

  Widget _buildFormCard(
      AdminShippingProvider provider,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'اطلاعات روش ارسال',
          ),
          SizedBox(height: 16.h),

          _buildTextField(
            controller: _titleController,
            label: 'عنوان روش ارسال',
            hint: 'مثلاً پست پیشتاز',
            icon: Icons.local_shipping_outlined,
            textInputAction:
            TextInputAction.next,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'عنوان روش ارسال را وارد کنید.';
              }

              return null;
            },
          ),

          SizedBox(height: 14.h),

          _buildTextField(
            controller:
            _descriptionController,
            label: 'توضیحات',
            hint:
            'مثلاً ارسال با پست پیشتاز',
            icon: Icons.description_outlined,
            maxLines: 3,
            textInputAction:
            TextInputAction.newline,
          ),

          SizedBox(height: 14.h),

          _buildTextField(
            controller: _costController,
            label: 'هزینه ارسال',
            hint: 'مثلاً 70000',
            icon: Icons.payments_outlined,
            keyboardType:
            TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            textInputAction:
            TextInputAction.next,
            suffixText: 'تومان',
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'هزینه ارسال را وارد کنید.';
              }

              final cost =
              int.tryParse(value.trim());

              if (cost == null) {
                return 'هزینه واردشده معتبر نیست.';
              }

              if (cost < 0) {
                return 'هزینه نمی‌تواند منفی باشد.';
              }

              return null;
            },
          ),

          SizedBox(height: 14.h),

          _buildTextField(
            controller:
            _estimatedDaysController,
            label: 'زمان تقریبی ارسال',
            hint:
            'مثلاً 2 تا 4 روز کاری',
            icon: Icons.schedule_outlined,
            textInputAction:
            TextInputAction.next,
          ),

          SizedBox(height: 14.h),

          _buildTextField(
            controller:
            _sortOrderController,
            label: 'ترتیب نمایش',
            hint: 'مثلاً 1',
            icon: Icons.sort_rounded,
            keyboardType:
            TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            textInputAction:
            TextInputAction.done,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'ترتیب نمایش را وارد کنید.';
              }

              final sortOrder =
              int.tryParse(value.trim());

              if (sortOrder == null) {
                return 'ترتیب واردشده معتبر نیست.';
              }

              return null;
            },
          ),

          if (provider.error != null) ...[
            SizedBox(height: 14.h),
            _buildErrorMessage(
              provider.error!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeThumbColor: Colors.green,
        activeTrackColor:
        Colors.green.withValues(
          alpha: 0.25,
        ),
        contentPadding:
        EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 4.h,
        ),
        secondary: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: _isActive
                ? Colors.green.withValues(
              alpha: 0.08,
            )
                : Colors.grey.withValues(
              alpha: 0.08,
            ),
            borderRadius:
            BorderRadius.circular(12.r),
          ),
          child: Icon(
            _isActive
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _isActive
                ? Colors.green
                : Colors.grey,
          ),
        ),
        title: Text(
          'وضعیت روش ارسال',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _isActive
              ? 'این روش در Checkout به کاربران نمایش داده می‌شود.'
              : 'این روش در Checkout نمایش داده نمی‌شود.',
          style: TextStyle(
            fontSize: 10.sp,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      AdminShippingProvider provider,
      bool isEditing,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: provider.isSaving
            ? null
            : () => _submit(
          provider,
          isEditing,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          Colors.red.withValues(
            alpha: 0.45,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14.r),
          ),
        ),
        child: provider.isSaving
            ? SizedBox(
          width: 22.w,
          height: 22.w,
          child:
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isEditing
                  ? Icons.save_outlined
                  : Icons.add_rounded,
              size: 21.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isEditing
                  ? 'ذخیره تغییرات'
                  : 'افزودن روش ارسال',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    int maxLines = 1,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 21.sp,
          color: Colors.grey.shade500,
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontSize: 10.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: TextStyle(
          fontSize: 11.sp,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontSize: 10.5.sp,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
        EdgeInsets.symmetric(
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
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13.r),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
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
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.06,
        ),
        borderRadius:
        BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 10.5.sp,
                height: 1.5,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
      AdminShippingProvider provider,
      bool isEditing,
      ) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title =
    _titleController.text.trim();

    final description =
    _descriptionController.text.trim();

    final cost =
    int.parse(_costController.text.trim());

    final estimatedDays =
    _estimatedDaysController.text.trim();

    final sortOrder =
    int.parse(_sortOrderController.text.trim());

    final success = isEditing
        ? await provider.updateShippingMethod(
      id: widget.shippingMethod!.id,
      title: title,
      description: description.isEmpty
          ? null
          : description,
      cost: cost,
      estimatedDays:
      estimatedDays.isEmpty
          ? null
          : estimatedDays,
      isActive: _isActive,
      sortOrder: sortOrder,
    )
        : await provider.createShippingMethod(
      title: title,
      description: description.isEmpty
          ? null
          : description,
      cost: cost,
      estimatedDays:
      estimatedDays.isEmpty
          ? null
          : estimatedDays,
      isActive: _isActive,
      sortOrder: sortOrder,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'تغییرات با موفقیت ذخیره شد.'
                  : 'روش ارسال با موفقیت اضافه شد.',
              textDirection:
              TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
            behavior:
            SnackBarBehavior.floating,
          ),
        );

      Navigator.of(context).pop(true);
    }
  }
}