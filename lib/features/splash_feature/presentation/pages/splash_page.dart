import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/splash_provider.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({
    super.key,
  });

  @override
  State<SplashPage> createState() =>
      _SplashPageState();

}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      _initialize();

    });

  }

  Future<void> _initialize() async {


    final provider =
    context.read<SplashProvider>();

    await provider.checkConnection();

    if (!mounted) return;


    if (!provider.hasInternet) {

      return;

    }

    await Future.delayed(
      const Duration(seconds: 2),
    );


    final prefs =
    await SharedPreferences
        .getInstance();

    final seenIntro =
        prefs.getBool(
          'show_intro',
        ) ??
            false;

    if (!mounted) return;

    if (seenIntro) {

      context.go('/auth');

    } else {

      context.go('/intro');

    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:

          AppColors.splash_background,



      body: Consumer<SplashProvider>(

        builder:
            (context, provider, child) {


          return SafeArea(

            child: Stack(

              alignment:
              Alignment.center,


              children: [
                Center(

                  child: Column(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      Container(
                        width:  120.w,
                        height: 120.w,
                        decoration:
                        BoxDecoration(

                          borderRadius:
                          BorderRadius
                              .circular(
                              24.r),

                        ),
                        child: SvgPicture.asset(
                          'assets/logo/logo.svg',
                          width: 120.w,
                          height: 120.w,
                        ),
                      ),

                      SizedBox(
                        height: 20.h,
                      ),

                      Text(

                        "SupaStore",

                        style:
                        AppTextStyles
                            .splashTitle.copyWith(

                          color: AppColors.splash_logo_text

                        ),



                      ),

                      SizedBox(
                        height: 40.h,
                      ),

                      if(provider.isLoading)

                        SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child:
                          CircularProgressIndicator(

                            strokeWidth: 2,
                            color:
                            AppColors.primary,

                          ),
                        ),
                    ],
                  ),
                ),

                if(!provider.isLoading &&
                    !provider.hasInternet)

                  Positioned(

                    bottom:
                    40.h,

                    child: Column(
                      children: [

                        Text(

                          "اتصال اینترنت برقرار نیست",

                          style:
                          AppTextStyles.splash_no_internet
                              .copyWith(

                            color:
                            AppColors.splash_no_internet,

                          ),
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        GestureDetector(

                          onTap: () {

                            _initialize();

                          },

                          child: Text(

                            "تلاش مجدد",

                            style:
                            AppTextStyles
                                .splash_try_again
                                .copyWith(

                              color:
                              AppColors.splash_try_again,
                            ),
                          ),
                        ),
                      ],
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