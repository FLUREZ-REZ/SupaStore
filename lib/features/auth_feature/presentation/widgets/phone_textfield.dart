import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';


class PhoneTextField extends StatelessWidget {

  final TextEditingController controller;
  final Function(String) onChanged;


  const PhoneTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,

      child: TextField(

        controller: controller,

        keyboardType:
        TextInputType.phone,

        textAlign:
        TextAlign.right,

        maxLength: 10,


        onChanged: (value) {

          // تبدیل عدد فارسی به انگلیسی
          final phone =
          value.toEnglishDigit();


          // ارسال مقدار استاندارد به Provider
          onChanged(phone);

        },


        style:
        AppTextStyles.bodyLarge,


        decoration: InputDecoration(

          counterText: '',


          hintText:
          '۹۱۲۳۴۵۶۷۸۹',


          hintTextDirection:
          TextDirection.rtl,


          prefixIcon:

          Padding(

            padding:
            EdgeInsets.symmetric(
              horizontal: 16.w,
            ),

            child:

            Center(

              widthFactor: 1,

              child: Text(
                '+۹۸',
                style:
                AppTextStyles.bodyLarge,
              ),

            ),
          ),



          filled: true,


          fillColor:
          AppColors.inputBackground,



          border:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(
              16.r,
            ),

            borderSide:
            BorderSide.none,

          ),

        ),
      ),
    );
  }
}