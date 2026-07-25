import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:supastore/features/auth_feature/presentation/widgets/phone_textfield.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (_) =>
          AuthProvider(),

      child:
      Consumer<AuthProvider>(

        builder:
            (context, provider, child){

          return Scaffold(

            body:
            Container(
              decoration: BoxDecoration(
                color: AppColors.auth_background ,
              ),
              child: SafeArea(

                child:
                Padding(

                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 24.w,
                  ),


                  child:
                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.center,

                    children: [

                      SizedBox(
                        height: 80.h,
                      ),

                      SvgPicture.asset(
                        'assets/logo/logo.svg',
                        width: 140.w,
                        height: 140.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.intro_description ,
                          BlendMode.srcIn
                        ),
                        fit: BoxFit.contain,
                      ),

                      Text("SupaStore" ,

                        style: AppTextStyles.auth_title_text.copyWith(
                          color: AppColors.auth_title_text
                        ),
                      ),

                      SizedBox(
                        height: 32.h,
                      ),


                      SizedBox(
                        height: 12.h,
                      ),

                      Text(
                        'برای ادامه شماره موبایل خود را وارد کنید',

                        textAlign:
                        TextAlign.center,

                        style:
                        AppTextStyles.auth_countinue.copyWith(
                          color: AppColors.auth_continue
                        ),

                      ),


                      SizedBox(
                        height: 20.h,
                      ),

                      PhoneTextField(

                        controller:
                        provider.phoneController,
                        onChanged:
                        provider.phoneChanged,

                      ),


                      const Spacer(),

                      AuthButton(

                        loading:
                        provider.isLoading,

                        enabled:
                        provider.isValidPhone,

                        onTap:
                        provider.sendOtp,

                      ),


                      SizedBox(
                        height: 20.h,
                      ),


                      Text(

                        'با ورود، قوانین و حریم خصوصی را می‌پذیرید',

                        style:
                        AppTextStyles.auth_rules.copyWith(
                          color: AppColors.auth_rules
                        ),
                        textAlign:
                        TextAlign.center,

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
      ),
    );
  }
}