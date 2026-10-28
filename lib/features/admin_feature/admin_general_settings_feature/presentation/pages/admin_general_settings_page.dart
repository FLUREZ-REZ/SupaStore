import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';
import 'package:supastore/core/di/injector.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/domain/entities/admin_general_settings_entity.dart';
import 'package:supastore/features/admin_feature/admin_general_settings_feature/presentation/providers/admin_general_settings_provider.dart';

class AdminGeneralSettingsPage extends StatelessWidget {
const AdminGeneralSettingsPage({super.key});

@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => getIt<AdminGeneralSettingsProvider>()..loadSettings(),
child: const _AdminGeneralSettingsView(),
);
}
}

class _AdminGeneralSettingsView extends StatefulWidget {
const _AdminGeneralSettingsView();

@override
State<_AdminGeneralSettingsView> createState() =>
_AdminGeneralSettingsViewState();
}

class _AdminGeneralSettingsViewState
extends State<_AdminGeneralSettingsView> {
final _formKey = GlobalKey<FormState>();

late final TextEditingController _appNameController;
late final TextEditingController _minimumOrderController;
late final TextEditingController _maxCartQuantityController;
late final TextEditingController _maintenanceMessageController;

bool _controllersInitialized = false;

bool _maintenanceMode = false;
bool _registrationEnabled = true;
bool _shoppingEnabled = true;
bool _showUnavailableProducts = true;
bool _reviewsEnabled = true;
bool _verifiedPurchaseReviewsOnly = false;

static const Color _primaryColor = Color(0xFF03045E);
static const Color _backgroundColor = Color(0xFFF7F8FA);

@override
void initState() {
super.initState();

_appNameController = TextEditingController();
_minimumOrderController = TextEditingController();
_maxCartQuantityController = TextEditingController();
_maintenanceMessageController = TextEditingController();
}

@override
void dispose() {
_appNameController.dispose();
_minimumOrderController.dispose();
_maxCartQuantityController.dispose();
_maintenanceMessageController.dispose();
super.dispose();
}

void _initializeControllers(AdminGeneralSettingsEntity settings) {
if (_controllersInitialized) return;

_controllersInitialized = true;

_appNameController.text = settings.appName;
_minimumOrderController.text =
settings.minimumOrderAmount.toString();
_maxCartQuantityController.text =
settings.maxCartQuantity.toString();
_maintenanceMessageController.text =
settings.maintenanceMessage;

_maintenanceMode = settings.maintenanceMode;
_registrationEnabled = settings.registrationEnabled;
_shoppingEnabled = settings.shoppingEnabled;
_showUnavailableProducts = settings.showUnavailableProducts;
_reviewsEnabled = settings.reviewsEnabled;
_verifiedPurchaseReviewsOnly =
settings.verifiedPurchaseReviewsOnly;
}

Future<void> _save() async {
if (!_formKey.currentState!.validate()) return;

final provider = context.read<AdminGeneralSettingsProvider>();
final currentSettings = provider.settings;

if (currentSettings == null) return;

final minimumOrderAmount =
int.tryParse(_minimumOrderController.text.trim()) ?? 0;

final maxCartQuantity =
int.tryParse(_maxCartQuantityController.text.trim()) ?? 20;

final updatedSettings = AdminGeneralSettingsEntity(
id: currentSettings.id,
appName: _appNameController.text.trim(),
maintenanceMode: _maintenanceMode,
registrationEnabled: _registrationEnabled,
shoppingEnabled: _shoppingEnabled,
showUnavailableProducts: _showUnavailableProducts,
reviewsEnabled: _reviewsEnabled,
verifiedPurchaseReviewsOnly: _verifiedPurchaseReviewsOnly,
minimumOrderAmount: minimumOrderAmount,
maxCartQuantity: maxCartQuantity,
maintenanceMessage: _maintenanceMessageController.text.trim(),
createdAt: currentSettings.createdAt,
updatedAt: currentSettings.updatedAt,
singleton: currentSettings.singleton,
);

final success = await provider.saveSettings(
settings: updatedSettings,
);

if (!mounted) return;

if (success) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('تنظیمات با موفقیت ذخیره شد.'),
behavior: SnackBarBehavior.floating,
),
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('ذخیره تنظیمات انجام نشد. دوباره تلاش کنید.'),
behavior: SnackBarBehavior.floating,
),
);
}
}

@override
Widget build(BuildContext context) {
return Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
backgroundColor: _backgroundColor,
appBar: AppBar(
backgroundColor: _primaryColor,
foregroundColor: Colors.white,
elevation: 0,
centerTitle: false,
title: Text(
'تنظیمات عمومی',
style: AppTextStyles.titleMedium.copyWith(
color: Colors.white,
),
),
),
body: Consumer<AdminGeneralSettingsProvider>(
builder: (context, provider, child) {
if (provider.isLoading && provider.settings == null) {
return const Center(
child: CircularProgressIndicator(
color: _primaryColor,
),
);
}

if (provider.settings == null) {
return _ErrorView(
message: provider.error ??
'دریافت تنظیمات با خطا مواجه شد.',
onRetry: provider.loadSettings,
);
}

_initializeControllers(provider.settings!);

return Form(
key: _formKey,
child: ListView(
padding: EdgeInsets.all(16.w),
children: [
_SectionCard(
title: 'تنظیمات اصلی',
subtitle: 'نام و وضعیت فعالیت فروشگاه',
icon: Iconsax.setting_2_copy,
children: [
_SettingsTextField(
controller: _appNameController,
label: 'نام فروشگاه',
hint: 'SupaStore',
icon: Iconsax.shop_copy,
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'نام فروشگاه را وارد کنید.';
}
return null;
},
),
SizedBox(height: 8.h),
_SettingsSwitch(
title: 'حالت تعمیرات',
subtitle: 'نمایش پیام تعمیرات به کاربران',
value: _maintenanceMode,
onChanged: (value) {
setState(() => _maintenanceMode = value);
},
),
const Divider(height: 1),
_SettingsSwitch(
title: 'فعال بودن خرید',
subtitle: 'امکان ثبت سفارش جدید',
value: _shoppingEnabled,
onChanged: (value) {
setState(() => _shoppingEnabled = value);
},
),
const Divider(height: 1),
_SettingsSwitch(
title: 'ثبت‌نام کاربران',
subtitle: 'اجازه ساخت حساب کاربری جدید',
value: _registrationEnabled,
onChanged: (value) {
setState(() => _registrationEnabled = value);
},
),
],
),
SizedBox(height: 14.h),
_SectionCard(
title: 'تنظیمات سفارش',
subtitle: 'محدودیت‌های ثبت سفارش',
icon: Iconsax.bill_copy,
children: [
_SettingsTextField(
controller: _minimumOrderController,
label: 'حداقل مبلغ سفارش',
hint: '0',
icon: Icons.payments_outlined,
keyboardType: TextInputType.number,
suffixText: 'تومان',
validator: (value) {
final number =
int.tryParse(value?.trim() ?? '');

if (number == null || number < 0) {
return 'مبلغ معتبر وارد کنید.';
}

return null;
},
),
SizedBox(height: 12.h),
_SettingsTextField(
controller: _maxCartQuantityController,
label: 'حداکثر تعداد کالا در سبد',
hint: '20',
icon: Iconsax.bag_2_copy,
keyboardType: TextInputType.number,
validator: (value) {
final number =
int.tryParse(value?.trim() ?? '');

if (number == null || number < 1) {
return 'تعداد باید حداقل ۱ باشد.';
}

return null;
},
),
],
),
SizedBox(height: 14.h),
_SectionCard(
title: 'تنظیمات محصولات',
subtitle: 'نمایش محصولات و مدیریت نظرات',
icon: Iconsax.back_square_copy,
children: [
_SettingsSwitch(
title: 'نمایش محصولات ناموجود',
subtitle: 'نمایش کالاهای اتمام موجودی',
value: _showUnavailableProducts,
onChanged: (value) {
setState(() {
_showUnavailableProducts = value;
});
},
),
const Divider(height: 1),
_SettingsSwitch(
title: 'فعال بودن نظرات',
subtitle: 'امکان ثبت نظر برای محصولات',
value: _reviewsEnabled,
onChanged: (value) {
setState(() => _reviewsEnabled = value);
},
),
const Divider(height: 1),
_SettingsSwitch(
title: 'نظرات خریداران تأییدشده',
subtitle: 'محدود کردن نظرات به خریداران تأییدشده',
value: _verifiedPurchaseReviewsOnly,
onChanged: (value) {
setState(() {
_verifiedPurchaseReviewsOnly = value;
});
},
),
],
),
SizedBox(height: 14.h),
_SectionCard(
title: 'پیام تعمیرات',
subtitle: 'متن نمایش داده‌شده هنگام تعمیرات',
icon: Iconsax.box_1_copy,
children: [
_SettingsTextField(
controller: _maintenanceMessageController,
label: 'پیام تعمیرات',
hint: 'فروشگاه در حال به‌روزرسانی است.',
icon: Icons.edit_note_rounded,
maxLines: 3,
validator: (value) {
if (_maintenanceMode &&
(value == null ||
value.trim().isEmpty)) {
return 'پیام حالت تعمیرات را وارد کنید.';
}
return null;
},
),
],
),
SizedBox(height: 22.h),
SizedBox(
height: 50.h,
child: ElevatedButton(
onPressed: provider.isSaving ? null : _save,
style: ElevatedButton.styleFrom(
backgroundColor: _primaryColor,
foregroundColor: Colors.white,
disabledBackgroundColor: Colors.grey.shade400,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10.r),
),
),
child: provider.isSaving
? SizedBox(
width: 21.w,
height: 21.w,
child: const CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : Text(
'ذخیره تنظیمات',
style: AppTextStyles.button,
),
),
),
SizedBox(height: 20.h),
],
),
);
},
),
),
);
}
}

class _SectionCard extends StatelessWidget {
const _SectionCard({
required this.title,
required this.subtitle,
required this.icon,
required this.children,
});

final String title;
final String subtitle;
final IconData icon;
final List<Widget> children;

static const Color _primaryColor = Color(0xFF03045E);

@override
Widget build(BuildContext context) {
return Container(
padding: EdgeInsets.all(14.w),
decoration: BoxDecoration(
color: AppColors.white,
borderRadius: BorderRadius.circular(12.r),
border: Border.all(
color: Colors.grey.withValues(alpha: 0.15),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 38.w,
height: 38.w,
decoration: BoxDecoration(
color: _primaryColor.withValues(alpha: 0.07),
borderRadius: BorderRadius.circular(9.r),
),
child: Icon(
icon,
color: _primaryColor,
size: 21.sp,
),
),
SizedBox(width: 10.w),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: AppTextStyles.titleMedium,
),
SizedBox(height: 3.h),
Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: Colors.grey.shade600,
fontSize: 11.sp,
),
),
],
),
),
],
),
SizedBox(height: 14.h),
...children,
],
),
);
}
}

class _SettingsSwitch extends StatelessWidget {
const _SettingsSwitch({
required this.title,
required this.subtitle,
required this.value,
required this.onChanged,
});

final String title;
final String subtitle;
final bool value;
final ValueChanged<bool>? onChanged;

@override
Widget build(BuildContext context) {
return SwitchListTile.adaptive(
contentPadding: EdgeInsets.zero,
dense: true,
title: Text(
title,
style: AppTextStyles.body.copyWith(
fontWeight: FontWeight.w600,
),
),
subtitle: Padding(
padding: EdgeInsets.only(top: 3.h),
child: Text(
subtitle,
style: AppTextStyles.body.copyWith(
color: Colors.grey.shade600,
fontSize: 11.sp,
),
),
),
value: value,
onChanged: onChanged,
activeTrackColor: const Color(0xFF03045E),
);
}
}

class _SettingsTextField extends StatelessWidget {
const _SettingsTextField({
required this.controller,
required this.label,
required this.hint,
required this.icon,
this.keyboardType,
this.maxLines = 1,
this.suffixText,
this.validator,
});

final TextEditingController controller;
final String label;
final String hint;
final IconData icon;
final TextInputType? keyboardType;
final int maxLines;
final String? suffixText;
final String? Function(String?)? validator;

@override
Widget build(BuildContext context) {
return TextFormField(
controller: controller,
keyboardType: keyboardType,
maxLines: maxLines,
validator: validator,
textDirection: TextDirection.rtl,
style: AppTextStyles.body,
decoration: InputDecoration(
labelText: label,
hintText: hint,
suffixText: suffixText,
prefixIcon: Icon(icon, size: 20.sp),
filled: true,
fillColor: const Color(0xFFF8F9FB),
isDense: true,
contentPadding: EdgeInsets.symmetric(
horizontal: 12.w,
vertical: 14.h,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(9.r),
borderSide: BorderSide(
color: Colors.grey.withValues(alpha: 0.2),
),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9.r),
borderSide: BorderSide(
color: Colors.grey.withValues(alpha: 0.2),
),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9.r),
borderSide: const BorderSide(
color: Color(0xFF03045E),
width: 1.3,
),
),
errorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9.r),
borderSide: const BorderSide(color: Colors.red),
),
focusedErrorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(9.r),
borderSide: const BorderSide(color: Colors.red),
),
),
);
}
}

class _ErrorView extends StatelessWidget {
const _ErrorView({
required this.message,
required this.onRetry,
});

final String message;
final VoidCallback onRetry;

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: EdgeInsets.all(24.w),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.error_outline_rounded,
size: 42.sp,
color: AppColors.primary,
),
SizedBox(height: 12.h),
Text(
message,
textAlign: TextAlign.center,
style: AppTextStyles.body,
),
SizedBox(height: 16.h),
OutlinedButton.icon(
onPressed: onRetry,
icon: const Icon(Icons.refresh_rounded),
label: const Text('تلاش مجدد'),
),
],
),
),
);
}
}
