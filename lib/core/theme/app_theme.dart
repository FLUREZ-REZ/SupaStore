import 'package:flutter/material.dart';

import 'app_colors.dart';


class AppTheme {

  AppTheme._();
  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    fontFamily: "Vazir",

    scaffoldBackgroundColor:
    AppColors.white,


    colorScheme:
    ColorScheme.fromSeed(
      seedColor:
      AppColors.primary,
    ),


    textTheme: const TextTheme(

      bodyLarge: TextStyle(
        fontFamily: "Vazir",
      ),

      bodyMedium: TextStyle(
        fontFamily: "Vazir",
      ),

      bodySmall: TextStyle(
        fontFamily: "Vazir",
      ),

    ),


    appBarTheme:
    const AppBarTheme(

      centerTitle: true,

      elevation: 0,

      titleTextStyle: TextStyle(
        fontFamily: "Vazir",
        fontSize: 18,
        fontWeight:
        FontWeight.w700,
      ),
    ),

  );
}