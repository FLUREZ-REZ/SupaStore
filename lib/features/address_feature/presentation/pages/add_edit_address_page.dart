
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/address_feature/domain/entities/address_entity.dart';
import 'package:supastore/features/address_feature/presentation/providers/address_provider.dart';

class AddEditAddressPage extends StatelessWidget {
  const AddEditAddressPage({
    super.key,
    this.address,
  });

  final AddressEntity? address;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لطفاً ابتدا وارد حساب کاربری شوید.'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => getIt<AddressProvider>(),
      child: _AddEditAddressView(
        address: address,
        userId: user.id,
      ),
    );
  }
}

class _AddEditAddressView extends StatefulWidget {
  const _AddEditAddressView({
    required this.address,
    required this.userId,
  });

  final AddressEntity? address;
  final String userId;

  @override
  State<_AddEditAddressView> createState() => _AddEditAddressViewState();
}

class _AddEditAddressViewState extends State<_AddEditAddressView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _receiverNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _postalCodeController;

  bool _isDefault = false;

  bool get isEdit => widget.address != null;

  static const _primaryColor = Color(0xFFD90429);

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _titleController = TextEditingController(text: address?.title ?? '');
    _receiverNameController =
        TextEditingController(text: address?.receiverName ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _provinceController = TextEditingController(text: address?.province ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _addressController = TextEditingController(text: address?.address ?? '');
    _postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');

    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F8),
        appBar: AppBar(
          title: Text(isEdit ? 'ویرایش آدرس' : 'افزودن آدرس'),
          centerTitle: true,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _sectionTitle('اطلاعات گیرنده'),
              _SectionCard(
                children: [
                  _AppTextField(
                    controller: _titleController,
                    label: 'عنوان آدرس',
                    hint: 'مثلاً خانه یا محل کار',
                    icon: Iconsax.bookmark_copy,
                    validator: _requiredValidator('عنوان آدرس'),
                    textInputAction: TextInputAction.next,
                  ),
                  _AppTextField(
                    controller: _receiverNameController,
                    label: 'نام و نام خانوادگی گیرنده',
                    hint: 'نام گیرنده',
                    icon: Iconsax.user_copy,
                    validator: _requiredValidator('نام گیرنده'),
                    textInputAction: TextInputAction.next,
                  ),
                  _AppTextField(
                    controller: _phoneController,
                    label: 'شماره تماس',
                    hint: '09123456789',
                    icon: Iconsax.call_copy,
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _sectionTitle('نشانی و کد پستی'),
              _SectionCard(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _AppTextField(
                          controller: _provinceController,
                          label: 'استان',
                          hint: 'استان',
                          icon: Iconsax.map_copy,
                          validator: _requiredValidator('استان'),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _AppTextField(
                          controller: _cityController,
                          label: 'شهر',
                          hint: 'شهر',
                          icon: Iconsax.house_2_copy,
                          validator: _requiredValidator('شهر'),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  _AppTextField(
                    controller: _addressController,
                    label: 'آدرس کامل',
                    hint: 'خیابان، کوچه، پلاک، واحد و ...',
                    icon: Iconsax.house_copy,
                    maxLines: 3,
                    validator: _addressValidator,
                    textInputAction: TextInputAction.newline,
                  ),
                  _AppTextField(
                    controller: _postalCodeController,
                    label: 'کد پستی',
                    hint: '۱۰ رقم',
                    icon: Iconsax.code_copy,
                    keyboardType: TextInputType.number,
                    validator: _postalCodeValidator,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _SectionCard(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isDefault,
                    activeColor: _primaryColor,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) {
                      setState(() => _isDefault = value);
                    },
                    title: Text(
                      'آدرس پیش‌فرض',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'برای سفارش‌های بعدی به‌صورت پیش‌فرض انتخاب شود.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    secondary: const Icon(Iconsax.location_copy),
                  ),
                ],
              ),
              if (provider.error != null) ...[
                SizedBox(height: 16.h),
                _ErrorMessage(message: provider.error!),
              ],
              SizedBox(height: 22.h),
              SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: provider.isUpdating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: provider.isUpdating
                      ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    isEdit ? 'ذخیره تغییرات' : 'ذخیره آدرس',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, right: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF292929),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddressProvider>();
    provider.clearError();

    final now = DateTime.now();
    final oldAddress = widget.address;

    final address = AddressEntity(
      id: oldAddress?.id ?? '',
      userId: widget.userId,
      title: _titleController.text.trim(),
      receiverName: _receiverNameController.text.trim(),
      phone: _phoneController.text.trim(),
      province: _provinceController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isDefault: _isDefault,
      createdAt: oldAddress?.createdAt ?? now,
      updatedAt: now,
    );

    final bool success;

    if (isEdit) {
      success = await provider.updateAddress(address: address);
    } else {
      success = await provider.addAddress(address: address);
    }

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit ? 'آدرس با موفقیت ویرایش شد.' : 'آدرس با موفقیت اضافه شد.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  String? Function(String?) _requiredValidator(String field) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$field را وارد کنید';
      }
      return null;
    };
  }

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) return 'شماره تماس را وارد کنید';

    if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
      return 'شماره تماس معتبر نیست';
    }

    return null;
  }

  String? _addressValidator(String? value) {
    final address = value?.trim() ?? '';

    if (address.isEmpty) return 'آدرس کامل را وارد کنید';
    if (address.length < 10) return 'آدرس وارد شده کوتاه است';

    return null;
  }

  String? _postalCodeValidator(String? value) {
    final postalCode = value?.trim() ?? '';

    if (postalCode.isEmpty) return 'کد پستی را وارد کنید';

    if (!RegExp(r'^\d{10}$').hasMatch(postalCode)) {
      return 'کد پستی باید ۱۰ رقم باشد';
    }

    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        validator: validator,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 13.sp),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20.sp),
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 14.h,
          ),
          labelStyle: TextStyle(fontSize: 12.sp),
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
          errorStyle: TextStyle(fontSize: 10.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(
              color: Color(0xFFD90429),
              width: 1.3,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.warning_2_copy,
            size: 19.sp,
            color: Colors.red.shade600,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.5,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
