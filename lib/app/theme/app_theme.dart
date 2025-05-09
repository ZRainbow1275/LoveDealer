import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_theme.dart';
import 'text_theme.dart';

class AppTheme {
  AppTheme._();
  
  // 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ColorTheme.primaryColor,
      primaryColorDark: ColorTheme.primaryDarkColor,
      primaryColorLight: ColorTheme.primaryLightColor,
      colorScheme: ColorScheme.light(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.secondaryColor,
        error: ColorTheme.error,
        background: ColorTheme.background,
        surface: ColorTheme.cardBackground,
      ),
      scaffoldBackgroundColor: ColorTheme.background,
      cardColor: ColorTheme.cardBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTheme.primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextTheme.headline4.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.textHint,
        selectedLabelStyle: TextTheme.caption,
        unselectedLabelStyle: TextTheme.caption,
        elevation: 8,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: ColorTheme.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextTheme.button,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          side: BorderSide(color: ColorTheme.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ColorTheme.cardBackground,
        titleTextStyle: TextTheme.headline4,
        contentTextStyle: TextTheme.bodyText1,
      ),
      textTheme: TextTheme(
        headline1: TextTheme.headline1,
        headline2: TextTheme.headline2,
        headline3: TextTheme.headline3,
        headline4: TextTheme.headline4,
        bodyText1: TextTheme.bodyText1,
        bodyText2: TextTheme.bodyText2,
        subtitle1: TextTheme.subtitle1,
        subtitle2: TextTheme.subtitle2,
        button: TextTheme.button,
        caption: TextTheme.caption,
        overline: TextTheme.overline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.error),
        ),
        labelStyle: TextTheme.bodyText2,
        hintStyle: TextTheme.bodyText2.copyWith(color: ColorTheme.textHint),
        errorStyle: TextTheme.error,
      ),
      dividerTheme: DividerThemeData(
        color: ColorTheme.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardTheme(
        color: ColorTheme.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ColorTheme.primaryColor,
        linearTrackColor: ColorTheme.border,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      fontFamily: TextTheme.fontFamily,
    );
  }
  
  // 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ColorTheme.primaryColor,
      primaryColorDark: ColorTheme.primaryDarkColor,
      primaryColorLight: ColorTheme.primaryLightColor,
      colorScheme: ColorScheme.dark(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.secondaryColor,
        error: ColorTheme.error,
        background: ColorTheme.darkBackground,
        surface: ColorTheme.darkCardBackground,
      ),
      scaffoldBackgroundColor: ColorTheme.darkBackground,
      cardColor: ColorTheme.darkCardBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTheme.darkCardBackground,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextTheme.darkHeadline4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ColorTheme.darkCardBackground,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.darkTextHint,
        selectedLabelStyle: TextTheme.darkCaption,
        unselectedLabelStyle: TextTheme.darkCaption,
        elevation: 8,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: ColorTheme.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextTheme.button,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          side: BorderSide(color: ColorTheme.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ColorTheme.darkCardBackground,
        titleTextStyle: TextTheme.darkHeadline4,
        contentTextStyle: TextTheme.darkBodyText1,
      ),
      textTheme: TextTheme(
        headline1: TextTheme.darkHeadline1,
        headline2: TextTheme.darkHeadline2,
        headline3: TextTheme.darkHeadline3,
        headline4: TextTheme.darkHeadline4,
        bodyText1: TextTheme.darkBodyText1,
        bodyText2: TextTheme.darkBodyText2,
        subtitle1: TextTheme.darkSubtitle1,
        subtitle2: TextTheme.darkSubtitle2,
        button: TextTheme.button,
        caption: TextTheme.darkCaption,
        overline: TextTheme.darkOverline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTheme.darkCardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorTheme.error),
        ),
        labelStyle: TextTheme.darkBodyText2,
        hintStyle: TextTheme.darkBodyText2.copyWith(color: ColorTheme.darkTextHint),
        errorStyle: TextTheme.error,
      ),
      dividerTheme: DividerThemeData(
        color: ColorTheme.darkBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardTheme(
        color: ColorTheme.darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ColorTheme.primaryColor,
        linearTrackColor: ColorTheme.darkBorder,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      fontFamily: TextTheme.fontFamily,
    );
  }
} 