import 'package:flutter/material.dart';

class AppColors {

  AppColors._();

//Splash screen Colors Theme :)
  static const Color splash_try_again =
  Color(0xFFFFFFFF);

  static const Color splash_no_internet =
  Color(0xFFe5e5e5);

  static const Color splash_logo_text =
  Color(0xFFFFFFFF);

  static const Color splash_background =
  Color(0xFFda1e37);

  //Intro page Colors Theme :)

  static const LinearGradient intro_background_gradiant =
  LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFFf1faee),
      Color(0xFFd90429),
    ],
  );

  static const Color intro_title =
  Color(0xFF000000);

  static const Color intro_background =
  Color(0xFFe5e5e5);

  static const Color intro_description =
  Color(0xFF000000);

  static const Color intro_skip_text =
  Color(0xFFFFFFFF);

  static const Color intro_indicator_dots =
  Color(0xFFE6123D);

  static const Color intro_next_text =
  Color(0xFFE6123D);

  // auth Theme_Colors

  static const Color auth_title_text =
  Color(0xFFE6123D);

  static const Color auth_background =
  Color(0x80e5e5e5);

  static const Color auth_textfield_background =
  Color(0xFFffffff);

  static const Color inputBackground =
  Color(0xFFE6123D);

  static const Color auth_rules =
  Color(0xFF2C3947);

  static const Color auth_continue =
  Color(0xFF000000);

  static const Color primary =
  Color(0xFFE6123D);

  static const Color white =
      Colors.white;

  static const Color black =
  Color(0xFF1A1A1A);

  static const Color border =
  Color(0xFFEAEAEA);

  static const Color background =
  Color(0xFFF8F8F8);

}