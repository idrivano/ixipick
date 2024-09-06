import 'package:flutter/material.dart';

import 'app_style.dart';

class AppTheme {
  const AppTheme._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppStyle.primaryColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: AppStyle.fontColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppStyle.whiteColor,
      foregroundColor: AppStyle.infoColor,
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppStyle.infoColor)
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppStyle.primaryColor,
      onSurface: AppStyle.blackColor.withOpacity(.7),
      onBackground: AppStyle.blackColor.withOpacity(.3),
    ),
  );
}