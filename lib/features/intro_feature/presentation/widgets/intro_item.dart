import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



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


        Image.asset(
          image,
          height:250.h,
        ),


        SizedBox(height:30.h),


        Text(
          title,
          style: TextStyle(
            fontSize:24.sp,
            fontWeight:FontWeight.bold,
          ),
        ),


        SizedBox(height:15.h),


        Text(
          description,
          textAlign:TextAlign.center,
          style:TextStyle(
            fontSize:15.sp,
          ),
        ),


      ],


    );


  }

}