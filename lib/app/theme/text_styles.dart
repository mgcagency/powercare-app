import 'package:flutter/material.dart';
import 'colors.dart'; // your AppColors file

String appFont = 'Helvetica';

class AppTextStyles {
  // ---- HEADLINES ----
  static  TextStyle headline1 = TextStyle(
    fontFamily: appFont,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static  TextStyle headline2 = TextStyle(
    fontFamily: appFont,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static  TextStyle headline3 = TextStyle(
    fontFamily: appFont,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  ); static  TextStyle headline4 = TextStyle(
    fontFamily: appFont,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  // ---- BODY TEXT ----
  static  TextStyle bodyLarge = TextStyle(
    fontFamily: appFont,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: appFont,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: appFont,
    fontSize: 13,
    height: 1.6,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static TextStyle bodyMidSmall = TextStyle(
    fontFamily: appFont,
    fontSize: 12,
    height: 1.6,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static TextStyle bodyExtraSmall = TextStyle(
    fontFamily: appFont,
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );

  // ---- BUTTON TEXT ----
  static TextStyle button = TextStyle(
    fontFamily: appFont,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
  );

  // ---- CAPTION / OVERLINE ----
  static TextStyle caption = TextStyle(
    fontFamily: appFont,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
}
