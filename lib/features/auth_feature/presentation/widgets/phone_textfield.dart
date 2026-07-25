import 'package:flutter/cupertino.dart';
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

          final phone =
          value.toEnglishDigit();

          onChanged(phone);

        },


        style:
        AppTextStyles.auth_textfield,


        decoration: InputDecoration(

          counterText: '',


          hintText:
          '۹۱۲۳۴۵۶۷۸۹',
          hintStyle: TextStyle(
            color: Colors.black38
          ),


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

              child: Icon(
                CupertinoIcons.device_phone_portrait
              )
            ),
          ),

          filled: true,

          fillColor:
          AppColors.auth_textfield_background,


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