import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/features/profile_feature/presentation/providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
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

    _fullNameController =
        TextEditingController();

    _phoneController =
        TextEditingController();
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

  void _initializeData(
      ProfileProvider provider,
      ) {
    if (_initialized) {
      return;
    }

    final profile = provider.profile;

    if (profile == null) {
      return;
    }

    // Full name

    _fullNameController.text =
        profile.fullName ?? '';

    // Phone

    _phoneController.text =
        profile.phone ?? '';

    // Avatar

    if (profile.avatarUrl != null &&
        profile.avatarUrl!.isNotEmpty) {
      _selectedAvatar =
          profile.avatarUrl;
    }

    _initialized = true;
  }

  // ============================================================
  // SELECT AVATAR
  // ============================================================

  void _selectAvatar(
      String avatar,
      ) {
    if (context
        .read<ProfileProvider>()
        .isUpdating) {
      return;
    }

    setState(() {
      _selectedAvatar = avatar;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveProfile() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'لطفاً ابتدا وارد حساب کاربری شوید.',
          ),
        ),
      );

      return;
    }

    final provider =
    context.read<ProfileProvider>();

    if (provider.isUpdating) {
      return;
    }

    // اگر کاربر هیچ آواتاری انتخاب نکرده
    // همان قبلی را نگه می‌داریم.

    final avatarUrl =
        _selectedAvatar ??
            provider.profile?.avatarUrl;

    final success =
    await provider.updateProfile(
      userId: user.id,

      phone:
      _phoneController.text.trim(),

      fullName:
      _fullNameController.text.trim(),

      avatarUrl: avatarUrl,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                'خطا در ذخیره اطلاعات پروفایل',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'پروفایل با موفقیت ذخیره شد',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  // ============================================================
  // AVATAR SELECTOR
  // ============================================================

  Widget _buildAvatarSelector(
      ProfileProvider provider,
      ) {
    return Column(
      children: [
        Text(
          'عکس پروفایل',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          'یکی از آواتارهای زیر را انتخاب کنید',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),

        SizedBox(height: 20.h),

        GridView.builder(
          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          itemCount: _avatars.length,

          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,

            crossAxisSpacing: 14.w,

            mainAxisSpacing: 14.h,

            childAspectRatio: 1,
          ),

          itemBuilder: (
              context,
              index,
              ) {
            final avatar =
            _avatars[index];

            final isSelected =
                _selectedAvatar == avatar;

            return GestureDetector(
              onTap: provider.isUpdating
                  ? null
                  : () {
                _selectAvatar(
                  avatar,
                );
              },

              child: AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 200,
                ),

                padding:
                EdgeInsets.all(
                  isSelected ? 3.w : 0,
                ),

                decoration:
                BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 3.w,
                  ),
                ),

                child: Stack(
                  children: [
                    // Avatar

                    ClipOval(
                      child: Image.asset(
                        avatar,

                        width: double.infinity,

                        height: double.infinity,

                        fit: BoxFit.cover,
                      ),
                    ),

                    // Selected icon

                    if (isSelected)
                      Positioned(
                        right: 2.w,
                        bottom: 2.h,
                        child: Container(
                          width: 25.w,
                          height: 25.w,

                          decoration:
                          BoxDecoration(
                            color:
                            AppColors.primary,
                            shape:
                            BoxShape.circle,

                            border:
                            Border.all(
                              color:
                              Colors.white,
                              width: 2,
                            ),
                          ),

                          child: Icon(
                            Icons.check,
                            size: 15.sp,
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14.r),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14.r),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14.r),

        borderSide: BorderSide(
          color: AppColors.primary,

          width: 1.5,
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
      builder: (
          context,
          provider,
          child,
          ) {
        _initializeData(provider);

        // ========================================================
        // LOADING
        // ========================================================

        if (provider.isLoading &&
            provider.profile == null) {
          return const Scaffold(
            body: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        // ========================================================
        // PAGE
        // ========================================================

        return Directionality(
          textDirection:
          TextDirection.rtl,

          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'ویرایش پروفایل',
              ),

              centerTitle: true,
            ),

            body: SafeArea(
              child:
              SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),

                padding:
                EdgeInsets.all(20.w),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [
                    // ==================================================
                    // AVATAR SELECTOR
                    // ==================================================

                    _buildAvatarSelector(
                      provider,
                    ),

                    SizedBox(
                      height: 35.h,
                    ),

                    // ==================================================
                    // FULL NAME
                    // ==================================================

                    Text(
                      'نام و نام خانوادگی',

                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 8.h,
                    ),

                    TextField(
                      controller:
                      _fullNameController,

                      enabled:
                      !provider.isUpdating,

                      textDirection:
                      TextDirection.rtl,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      _inputDecoration(
                        hint:
                        'نام و نام خانوادگی',

                        icon:
                        Icons.person_outline,
                      ),
                    ),

                    SizedBox(
                      height: 20.h,
                    ),

                    // ==================================================
                    // PHONE
                    // ==================================================

                    Text(
                      'شماره موبایل',

                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 8.h,
                    ),

                    TextField(
                      controller:
                      _phoneController,

                      enabled:
                      !provider.isUpdating,

                      keyboardType:
                      TextInputType.phone,

                      textDirection:
                      TextDirection.ltr,

                      textInputAction:
                      TextInputAction.done,

                      decoration:
                      _inputDecoration(
                        hint:
                        'شماره موبایل',

                        icon:
                        Icons.phone_outlined,
                      ),
                    ),

                    SizedBox(
                      height: 35.h,
                    ),

                    // ==================================================
                    // SAVE BUTTON
                    // ==================================================

                    SizedBox(
                      height: 52.h,

                      child:
                      ElevatedButton(
                        onPressed:
                        provider.isUpdating
                            ? null
                            : _saveProfile,

                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          AppColors.primary,

                          foregroundColor:
                          Colors.white,

                          disabledBackgroundColor:
                          Colors.grey
                              .shade300,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14.r,
                            ),
                          ),
                        ),

                        child:
                        provider.isUpdating
                            ? SizedBox(
                          width:
                          24.w,

                          height:
                          24.w,

                          child:
                          const CircularProgressIndicator(
                            strokeWidth:
                            2.5,

                            color:
                            Colors.white,
                          ),
                        )
                            : Text(
                          'ذخیره تغییرات',

                          style:
                          TextStyle(
                            fontSize:
                            14.sp,

                            fontWeight:
                            FontWeight
                                .bold,
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
      },
    );
  }
}