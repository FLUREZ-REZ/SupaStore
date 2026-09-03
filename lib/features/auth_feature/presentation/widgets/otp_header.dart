import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class OtpHeader extends StatelessWidget {
  final String phoneNumber;

  const OtpHeader({
    super.key,
    required this.phoneNumber,
  });

  String maskPhoneNumber(String phone) {
    phone = phone.toEnglishDigit();
    phone = phone.replaceAll(' ', '');

    if (phone.length < 10) return phone;

    return '${phone.substring(0, 4)}*******${phone.substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20.h,
        ),

        // --------------------------------------------------
        // Icon
        // --------------------------------------------------

        Container(
          width: 58.w,
          height: 58.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Icon(
            Icons.sms_rounded,
            color: Colors.white,
            size: 27.sp,
          ),
        ),

        SizedBox(
          height: 22.h,
        ),

        // --------------------------------------------------
        // Title
        // --------------------------------------------------



        SizedBox(
          height: 10.h,
        ),

        // --------------------------------------------------
        // Description
        // --------------------------------------------------

        Text(
          'کد تأیید برای شماره موبایل زیر ارسال شد',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.7,
          ),
        ),

        SizedBox(
          height: 18.h,
        ),

        // --------------------------------------------------
        // Phone number
        // --------------------------------------------------

        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            maskPhoneNumber(phoneNumber).toPersianDigit(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              letterSpacing: 1,
            ),
          ),
        ),

        SizedBox(
          height: 8.h,
        ),

        // --------------------------------------------------
        // Small divider
        // --------------------------------------------------

        Container(
          width: 100.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ],
    );
  }
}