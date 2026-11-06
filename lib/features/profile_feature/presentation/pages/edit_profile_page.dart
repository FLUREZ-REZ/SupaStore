
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // ============================================================
  // AVATARS
  // ============================================================

  static const List<String> _avatars = [
    'assets/avatars/blueman.webp',
    'assets/avatars/graywoman.webp',
    'assets/avatars/greenwoman.webp',
    'assets/avatars/greenman.webp',
    'assets/avatars/redman.webp',
    'assets/avatars/redwoman.webp',
  ];

  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;

  // ============================================================
  // SELECTED AVATAR
  // ============================================================

  String? _selectedAvatar;
  bool _initialized = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // INITIALIZE DATA
  // ============================================================

  void _initializeData(ProfileProvider provider) {
    if (_initialized) return;

    final profile = provider.profile;

    if (profile == null) return;

    _fullNameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phone ?? '';

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      _selectedAvatar = profile.avatarUrl;
    }

    _initialized = true;
  }

  // ============================================================
  // SELECT AVATAR
  // ============================================================

  void _selectAvatar(String avatar) {
    if (context.read<ProfileProvider>().isUpdating) return;

    setState(() {
      _selectedAvatar = avatar;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً ابتدا وارد حساب کاربری شوید.'),
        ),
      );

      return;
    }

    final provider = context.read<ProfileProvider>();

    if (provider.isUpdating) return;

    final avatarUrl =
        _selectedAvatar ?? provider.profile?.avatarUrl;

    final success = await provider.updateProfile(
      userId: user.id,
      phone: _phoneController.text.trim(),
      fullName: _fullNameController.text.trim(),
      avatarUrl: avatarUrl,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'خطا در ذخیره اطلاعات پروفایل',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('پروفایل با موفقیت ذخیره شد'),
      ),
    );

    Navigator.of(context).pop();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR SELECTOR
  // ============================================================

  Widget _buildAvatarSelector(
      ProfileProvider provider, {
        required double avatarSize,
        required double spacing,
        required double titleSize,
        required double descriptionSize,
      }) {
    return Column(
      children: [
        Text(
          'عکس پروفایل',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'یکی از آواتارهای زیر را انتخاب کنید',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: descriptionSize,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 24),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _avatars.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final avatar = _avatars[index];
              final isSelected = _selectedAvatar == avatar;

              return Center(
                child: SizedBox(
                  width: avatarSize,
                  height: avatarSize,
                  child: GestureDetector(
                    onTap: provider.isUpdating
                        ? null
                        : () => _selectAvatar(avatar),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(
                        isSelected ? 3 : 0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipOval(
                              child: Image.asset(
                                avatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM FIELD
  // ============================================================

  Widget _buildFormField({
    required String title,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    required double fontSize,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textDirection: textDirection,
          textInputAction: textInputAction,
          style: TextStyle(
            fontSize: fontSize,
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton(
      ProfileProvider provider, {
        required double height,
        required double fontSize,
      }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: provider.isUpdating ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: provider.isUpdating
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(
          'ذخیره تغییرات',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        _initializeData(provider);

        if (provider.isLoading && provider.profile == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F7F8),

            appBar: AppBar(
              backgroundColor: const Color(0xFFd90429),
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),

            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1100;
                  final isTablet = width >= 650 && width < 1100;

                  final horizontalPadding = isDesktop
                      ? 32.0
                      : isTablet
                      ? 24.0
                      : 16.0;

                  final maxContentWidth = isDesktop ? 720.0 : 560.0;

                  final avatarSize = isDesktop
                      ? 92.0
                      : isTablet
                      ? 82.0
                      : 76.0;

                  final avatarSpacing = isDesktop
                      ? 24.0
                      : isTablet
                      ? 18.0
                      : 14.0;

                  final titleSize = isDesktop
                      ? 19.0
                      : isTablet
                      ? 18.0
                      : 16.0;

                  final descriptionSize = isDesktop ? 14.0 : 12.0;

                  final fieldFontSize = isDesktop
                      ? 15.0
                      : isTablet
                      ? 14.0
                      : 13.0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isDesktop ? 32 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxContentWidth,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                            isDesktop ? 32 : isTablet ? 26 : 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // AVATAR

                              _buildAvatarSelector(
                                provider,
                                avatarSize: avatarSize,
                                spacing: avatarSpacing,
                                titleSize: titleSize,
                                descriptionSize: descriptionSize,
                              ),

                              SizedBox(
                                height: isDesktop ? 40 : 32,
                              ),

                              // FULL NAME

                              _buildFormField(
                                title: 'نام و نام خانوادگی',
                                hint: 'نام و نام خانوادگی',
                                icon: Iconsax.user_copy,
                                controller: _fullNameController,
                                enabled: !provider.isUpdating,
                                fontSize: fieldFontSize,
                              ),

                              SizedBox(
                                height: isDesktop ? 26 : 20,
                              ),

                              // PHONE

                              _buildFormField(
                                title: 'شماره موبایل',
                                hint: 'شماره موبایل',
                                icon: Iconsax.call_copy,
                                controller: _phoneController,
                                enabled: !provider.isUpdating,
                                fontSize: fieldFontSize,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                textInputAction: TextInputAction.done,
                              ),

                              SizedBox(
                                height: isDesktop ? 36 : 30,
                              ),

                              // SAVE BUTTON

                              _buildSaveButton(
                                provider,
                                height: isDesktop ? 56 : 52,
                                fontSize: fieldFontSize + 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
