import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید.',
          ),
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
  State<_AddEditAddressView> createState() =>
      _AddEditAddressViewState();
}

class _AddEditAddressViewState
    extends State<_AddEditAddressView> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _titleController;

  late final TextEditingController
  _receiverNameController;

  late final TextEditingController
  _phoneController;

  late final TextEditingController
  _provinceController;

  late final TextEditingController
  _cityController;

  late final TextEditingController
  _addressController;

  late final TextEditingController
  _postalCodeController;

  bool _isDefault = false;

  bool get isEdit =>
      widget.address != null;

  @override
  void initState() {
    super.initState();

    final address =
        widget.address;

    _titleController =
        TextEditingController(
          text: address?.title ?? '',
        );

    _receiverNameController =
        TextEditingController(
          text: address?.receiverName ?? '',
        );

    _phoneController =
        TextEditingController(
          text: address?.phone ?? '',
        );

    _provinceController =
        TextEditingController(
          text: address?.province ?? '',
        );

    _cityController =
        TextEditingController(
          text: address?.city ?? '',
        );

    _addressController =
        TextEditingController(
          text: address?.address ?? '',
        );

    _postalCodeController =
        TextEditingController(
          text: address?.postalCode ?? '',
        );

    _isDefault =
        address?.isDefault ?? false;
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
    final provider =
    context.watch<AddressProvider>();

    return Directionality(
      textDirection:
      TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Colors.grey.shade50,

        appBar: AppBar(
          title: Text(
            isEdit
                ? 'ویرایش آدرس'
                : 'افزودن آدرس',
          ),
          centerTitle: true,
        ),

        body: Form(
          key: _formKey,
          child: ListView(
            padding:
            EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              30.h,
            ),
            children: [
              _SectionCard(
                children: [
                  _AppTextField(
                    controller:
                    _titleController,
                    label: 'عنوان آدرس',
                    hint:
                    'مثلاً خانه یا محل کار',
                    icon:
                    Icons.bookmark_outline,
                    textInputAction:
                    TextInputAction.next,
                    validator:
                    _requiredValidator(
                      'عنوان آدرس',
                    ),
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  _AppTextField(
                    controller:
                    _receiverNameController,
                    label: 'نام گیرنده',
                    hint:
                    'نام و نام خانوادگی',
                    icon:
                    Icons.person_outline,
                    textInputAction:
                    TextInputAction.next,
                    validator:
                    _requiredValidator(
                      'نام گیرنده',
                    ),
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  _AppTextField(
                    controller:
                    _phoneController,
                    label: 'شماره تماس',
                    hint:
                    '09123456789',
                    icon:
                    Icons.phone_outlined,
                    keyboardType:
                    TextInputType.phone,
                    textInputAction:
                    TextInputAction.next,
                    validator:
                    _phoneValidator,
                  ),
                ],
              ),

              SizedBox(
                height: 14.h,
              ),

              _SectionCard(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                        _AppTextField(
                          controller:
                          _provinceController,
                          label: 'استان',
                          hint: 'استان',
                          icon: Icons
                              .map_outlined,
                          textInputAction:
                          TextInputAction.next,
                          validator:
                          _requiredValidator(
                            'استان',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12.w,
                      ),
                      Expanded(
                        child:
                        _AppTextField(
                          controller:
                          _cityController,
                          label: 'شهر',
                          hint: 'شهر',
                          icon: Icons
                              .location_city_outlined,
                          textInputAction:
                          TextInputAction.next,
                          validator:
                          _requiredValidator(
                            'شهر',
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  _AppTextField(
                    controller:
                    _addressController,
                    label: 'آدرس کامل',
                    hint:
                    'خیابان، کوچه، پلاک، واحد و ...',
                    icon:
                    Icons.home_outlined,
                    maxLines: 4,
                    textInputAction:
                    TextInputAction.newline,
                    validator:
                    _addressValidator,
                  ),

                  SizedBox(
                    height: 14.h,
                  ),

                  _AppTextField(
                    controller:
                    _postalCodeController,
                    label: 'کد پستی',
                    hint: '۱۰ رقمی',
                    icon: Icons
                        .markunread_mailbox_outlined,
                    keyboardType:
                    TextInputType.number,
                    textInputAction:
                    TextInputAction.done,
                    validator:
                    _postalCodeValidator,
                  ),
                ],
              ),

              SizedBox(
                height: 14.h,
              ),

              _SectionCard(
                children: [
                  SwitchListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    value: _isDefault,
                    onChanged:
                    provider.isUpdating
                        ? null
                        : (value) {
                      setState(() {
                        _isDefault =
                            value;
                      });
                    },
                    title: Text(
                      'آدرس پیش‌فرض',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'این آدرس برای سفارش‌ها به صورت پیش‌فرض انتخاب شود.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                    secondary: Icon(
                      Icons
                          .check_circle_outline,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 20.h,
              ),

              if (provider.error != null)
                _ErrorMessage(
                  message:
                  provider.error!,
                ),

              if (provider.error != null)
                SizedBox(
                  height: 12.h,
                ),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed:
                  provider.isUpdating
                      ? null
                      : _submit,
                  style:
                  ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14.r,
                      ),
                    ),
                  ),
                  child:
                  provider.isUpdating
                      ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child:
                    const CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : Text(
                    isEdit
                        ? 'ذخیره تغییرات'
                        : 'ذخیره آدرس',
                    style:
                    TextStyle(
                      fontSize:
                      15.sp,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
    context.read<AddressProvider>();

    provider.clearError();

    final now =
    DateTime.now();

    final oldAddress =
        widget.address;

    final address =
    AddressEntity(
      id: oldAddress?.id ?? '',
      userId: widget.userId,
      title:
      _titleController.text.trim(),
      receiverName:
      _receiverNameController.text
          .trim(),
      phone:
      _phoneController.text.trim(),
      province:
      _provinceController.text
          .trim(),
      city:
      _cityController.text.trim(),
      address:
      _addressController.text
          .trim(),
      postalCode:
      _postalCodeController.text
          .trim(),
      isDefault: _isDefault,
      createdAt:
      oldAddress?.createdAt ?? now,
      updatedAt: now,
    );

    final bool success;

    if (isEdit) {
      success =
      await provider.updateAddress(
        address: address,
      );
    } else {
      success =
      await provider.addAddress(
        address: address,
      );
    }

    if (!mounted) {
      return;
    }

    if (!success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? 'آدرس با موفقیت ویرایش شد.'
              : 'آدرس با موفقیت اضافه شد.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  // =========================================================
  // VALIDATORS
  // =========================================================

  String? Function(String?)
  _requiredValidator(
      String field,
      ) {
    return (value) {
      if (value == null ||
          value.trim().isEmpty) {
        return '$field را وارد کنید';
      }

      return null;
    };
  }

  String? _phoneValidator(
      String? value,
      ) {
    final phone =
        value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'شماره تماس را وارد کنید';
    }

    if (phone.length != 11 ||
        !phone.startsWith('09')) {
      return 'شماره تماس معتبر نیست';
    }

    return null;
  }

  String? _addressValidator(
      String? value,
      ) {
    final address =
        value?.trim() ?? '';

    if (address.isEmpty) {
      return 'آدرس کامل را وارد کنید';
    }

    if (address.length < 10) {
      return 'آدرس وارد شده کوتاه است';
    }

    return null;
  }

  String? _postalCodeValidator(
      String? value,
      ) {
    final postalCode =
        value?.trim() ?? '';

    if (postalCode.isEmpty) {
      return 'کد پستی را وارد کنید';
    }

    if (postalCode.length != 10) {
      return 'کد پستی باید ۱۰ رقم باشد';
    }

    return null;
  }
}

// =========================================================
// SECTION CARD
// =========================================================

class _SectionCard
    extends StatelessWidget {
  const _SectionCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      EdgeInsets.all(14.w),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          16.r,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// =========================================================
// TEXT FIELD
// =========================================================

class _AppTextField
    extends StatelessWidget {
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

  final String? Function(String?)?
  validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
      keyboardType,
      textInputAction:
      textInputAction,
      maxLines: maxLines,
      validator: validator,
      textDirection:
      TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
        Icon(icon),
        alignLabelWithHint:
        maxLines > 1,
        filled: true,
        fillColor:
        Colors.grey.shade50,
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide(
            color: Theme.of(
              context,
            )
                .colorScheme
                .primary,
            width: 1.5,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide(
            color:
            Colors.red.shade300,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          borderSide:
          BorderSide(
            color:
            Colors.red.shade400,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// =========================================================
// ERROR
// =========================================================

class _ErrorMessage
    extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      EdgeInsets.all(12.w),
      decoration:
      BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        border: Border.all(
          color:
          Colors.red.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Icon(
            Icons.error_outline,
            size: 20.sp,
            color:
            Colors.red.shade600,
          ),
          SizedBox(
            width: 8.w,
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.5,
                color:
                Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}