import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supastore/core/theme/app_colors.dart';


class AuthButton extends StatelessWidget {


  final bool loading;

  final bool enabled;

  final VoidCallback onTap;



  const AuthButton({

    super.key,

    required this.loading,

    required this.enabled,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return SizedBox(

      width: double.infinity,

      height: 54.h,


      child: ElevatedButton(


        onPressed:
        enabled && !loading
            ? onTap
            : null,



        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          AppColors.primary,


          disabledBackgroundColor:
          Colors.grey.shade300,


          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(
              16.r,
            ),

          ),

        ),



        child:

        loading

            ?

        const CircularProgressIndicator(
          color: Colors.white,
        )


            :

        const Text(
          'ارسال کد تایید',
        ),

      ),

    );

  }

}