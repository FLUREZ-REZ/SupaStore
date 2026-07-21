import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:supastore/core/theme/app_colors.dart';
import 'package:supastore/core/theme/app_text_styles.dart';



class IntroItem extends StatelessWidget {

  final String image;
  final String title;
  final String description;


  const IntroItem({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });


  @override
  Widget build(BuildContext context) {


    return Column(

      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [


        Lottie.asset(
          image,
          height: 280.h,
          repeat: true,
          fit: BoxFit.contain,
        ),


        SizedBox(height:30.h),


        Text(
          title,
          style: AppTextStyles.intro_title.copyWith(

            color: AppColors.intro_title

          )
        ),


        SizedBox(height:15.h),


        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            description,
            textAlign:TextAlign.center,
            style:TextStyle(
              fontSize:13.sp,
            ),
          ),
        ),


      ],


    );


  }

}