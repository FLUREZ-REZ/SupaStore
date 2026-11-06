
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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

  static const Color _primaryColor = Color(0xFF03045E);
  static const Color _secondaryColor = Color(0xFF023E8A);
  static const Color _accentColor = Color(0xFF0096C7);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

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

    _estimatedDaysController = TextEditingController(
      text: method?.estimatedDays ?? '',
    );

    _sortOrderController = TextEditingController(
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
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1100;
            final horizontalPadding = width < 600
                ? 16.0
                : width < 1100
                ? 28.0
                : 36.0;

            return Consumer<AdminShippingProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1050,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(isEditing),
                            const SizedBox(height: 22),

                            if (isDesktop)
                              _buildDesktopContent(
                                provider,
                                isEditing,
                              )
                            else
                              _buildMobileContent(
                                provider,
                                isEditing,
                              ),
                          ],
                        ),
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

  Widget _buildDesktopContent(
      AdminShippingProvider provider,
      bool isEditing,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _buildFormCard(provider),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildActiveCard(),
              const SizedBox(height: 20),
              _buildSaveButton(provider, isEditing),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(
      AdminShippingProvider provider,
      bool isEditing,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFormCard(provider),
        const SizedBox(height: 18),
        _buildActiveCard(),
        const SizedBox(height: 24),
        _buildSaveButton(provider, isEditing),
      ],
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isEditing
                  ? Icons.edit_location_alt_outlined
                  : Iconsax.truck_fast_copy,
              color: _secondaryColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'ویرایش روش ارسال' : 'روش ارسال جدید',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEditing
                      ? 'اطلاعات روش ارسال را ویرایش کنید.'
                      : 'اطلاعات روش ارسال جدید را وارد کنید.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
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

  Widget _buildFormCard(AdminShippingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('اطلاعات روش ارسال'),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _titleController,
            label: 'عنوان روش ارسال',
            hint: 'مثلاً پست پیشتاز',
            icon: Iconsax.truck_copy,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'عنوان روش ارسال را وارد کنید.';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _descriptionController,
            label: 'توضیحات',
            hint: 'مثلاً ارسال با پست پیشتاز',
            icon: Iconsax.message_copy,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _costController,
            label: 'هزینه ارسال',
            hint: 'مثلاً 70000',
            icon: Iconsax.card_copy,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textInputAction: TextInputAction.next,
            suffixText: 'تومان',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هزینه ارسال را وارد کنید.';
              }

              final cost = int.tryParse(value.trim());

              if (cost == null) {
                return 'هزینه واردشده معتبر نیست.';
              }

              if (cost < 0) {
                return 'هزینه نمی‌تواند منفی باشد.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _estimatedDaysController,
            label: 'زمان تقریبی ارسال',
            hint: 'مثلاً 2 تا 4 روز کاری',
            icon: Iconsax.clock_copy,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _sortOrderController,
            label: 'ترتیب نمایش',
            hint: 'مثلاً 1',
            icon: Iconsax.sort_copy,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'ترتیب نمایش را وارد کنید.';
              }

              final sortOrder = int.tryParse(value.trim());

              if (sortOrder == null) {
                return 'ترتیب واردشده معتبر نیست.';
              }

              return null;
            },
          ),

          if (provider.error != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(provider.error!),
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
        borderRadius: BorderRadius.circular(18),
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
        activeTrackColor: Colors.green.withValues(alpha: 0.25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isActive
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isActive
                ? Iconsax.eye_copy
                : Iconsax.eye_slash_copy,
            color: _isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: const Text(
          'وضعیت روش ارسال',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _isActive
              ? 'این روش در Checkout به کاربران نمایش داده می‌شود.'
              : 'این روش در Checkout نمایش داده نمی‌شود.',
          style: TextStyle(
            fontSize: 11,
            height: 1.6,
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
      height: 54,
      child: ElevatedButton(
        onPressed: provider.isSaving
            ? null
            : () => _submit(provider, isEditing),
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          _secondaryColor.withValues(alpha: 0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: provider.isSaving
            ? const SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEditing
                  ? Icons.check_circle_outline
                  : Icons.add_rounded,
              size: 22,
            ),
            const SizedBox(width: 9),
            Text(
              isEditing
                  ? 'ذخیره تغییرات'
                  : 'افزودن روش ارسال',
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 21,
          color: Colors.grey.shade500,
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
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
            color: _accentColor,
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

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.warning_2_copy,
            color: Colors.red.shade600,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
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

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final cost = int.parse(_costController.text.trim());
    final estimatedDays = _estimatedDaysController.text.trim();
    final sortOrder = int.parse(_sortOrderController.text.trim());

    final success = isEditing
        ? await provider.updateShippingMethod(
      id: widget.shippingMethod!.id,
      title: title,
      description: description.isEmpty ? null : description,
      cost: cost,
      estimatedDays:
      estimatedDays.isEmpty ? null : estimatedDays,
      isActive: _isActive,
      sortOrder: sortOrder,
    )
        : await provider.createShippingMethod(
      title: title,
      description: description.isEmpty ? null : description,
      cost: cost,
      estimatedDays:
      estimatedDays.isEmpty ? null : estimatedDays,
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
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.of(context).pop(true);
    }
  }
}
