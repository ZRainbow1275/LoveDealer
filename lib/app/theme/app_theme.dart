import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'color_theme.dart';
import 'text_theme.dart' as app_text;

class AppTheme {
  AppTheme._();
  
  // 浅色主题
  static material.ThemeData get lightTheme {
    return material.ThemeData(
      primaryColor: ColorTheme.primaryColor,
      primaryColorDark: ColorTheme.primaryDarkColor,
      primaryColorLight: ColorTheme.primaryLightColor,
      colorScheme: const material.ColorScheme.light(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.secondaryColor,
        error: ColorTheme.error,
        background: ColorTheme.background,
        surface: ColorTheme.cardBackground,
      ),
      scaffoldBackgroundColor: ColorTheme.background,
      cardColor: ColorTheme.cardBackground,
      appBarTheme: material.AppBarTheme(
        backgroundColor: ColorTheme.primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: app_text.TextTheme.headline4.copyWith(color: material.Colors.white),
        iconTheme: const material.IconThemeData(color: material.Colors.white),
      ),
      bottomNavigationBarTheme: material.BottomNavigationBarThemeData(
        backgroundColor: material.Colors.white,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.textHint,
        selectedLabelStyle: app_text.TextTheme.caption,
        unselectedLabelStyle: app_text.TextTheme.caption,
        elevation: 8,
      ),
      buttonTheme: material.ButtonThemeData(
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(8)),
        ),
        buttonColor: ColorTheme.primaryColor,
        textTheme: material.ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: material.Colors.white,
          textStyle: app_text.TextTheme.button,
          elevation: 2,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
          padding: const material.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: material.TextButtonThemeData(
        style: material.TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: app_text.TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          padding: const material.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      outlinedButtonTheme: material.OutlinedButtonThemeData(
        style: material.OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: app_text.TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          side: material.BorderSide(color: ColorTheme.primaryColor, width: 1.5),
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
          padding: const material.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      dialogTheme: material.DialogTheme(
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(12)),
        ),
        backgroundColor: ColorTheme.cardBackground,
        titleTextStyle: app_text.TextTheme.headline4,
        contentTextStyle: app_text.TextTheme.bodyText1,
      ),
      textTheme: material.TextTheme(
        displayLarge: app_text.TextTheme.headline1,
        displayMedium: app_text.TextTheme.headline2,
        displaySmall: app_text.TextTheme.headline3,
        headlineMedium: app_text.TextTheme.headline4,
        bodyLarge: app_text.TextTheme.bodyText1,
        bodyMedium: app_text.TextTheme.bodyText2,
        titleMedium: app_text.TextTheme.subtitle1,
        titleSmall: app_text.TextTheme.subtitle2,
        labelLarge: app_text.TextTheme.button,
        bodySmall: app_text.TextTheme.caption,
        labelSmall: app_text.TextTheme.overline,
      ),
      inputDecorationTheme: material.InputDecorationTheme(
        filled: true,
        fillColor: material.Colors.white,
        contentPadding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.border),
        ),
        enabledBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.border),
        ),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.primaryColor, width: 1.5),
        ),
        errorBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.error),
        ),
        labelStyle: app_text.TextTheme.bodyText2,
        hintStyle: app_text.TextTheme.bodyText2.copyWith(color: ColorTheme.textHint),
        errorStyle: app_text.TextTheme.error,
      ),
      dividerTheme: const material.DividerThemeData(
        color: ColorTheme.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: material.CardTheme(
        color: ColorTheme.cardBackground,
        elevation: 2,
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.circular(12),
        ),
        margin: const material.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      progressIndicatorTheme: const material.ProgressIndicatorThemeData(
        color: ColorTheme.primaryColor,
        linearTrackColor: ColorTheme.border,
      ),
      floatingActionButtonTheme: material.FloatingActionButtonThemeData(
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: material.Colors.white,
        elevation: 4,
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(16)),
        ),
      ),
      fontFamily: app_text.TextTheme.fontFamily,
    );
  }
  
  // 深色主题
  static material.ThemeData get darkTheme {
    return material.ThemeData(
      brightness: material.Brightness.dark,
      primaryColor: ColorTheme.primaryColor,
      primaryColorDark: ColorTheme.primaryDarkColor,
      primaryColorLight: ColorTheme.primaryLightColor,
      colorScheme: const material.ColorScheme.dark(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.secondaryColor,
        error: ColorTheme.error,
        background: ColorTheme.darkBackground,
        surface: ColorTheme.darkCardBackground,
      ),
      scaffoldBackgroundColor: ColorTheme.darkBackground,
      cardColor: ColorTheme.darkCardBackground,
      appBarTheme: material.AppBarTheme(
        backgroundColor: ColorTheme.darkCardBackground,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: app_text.TextTheme.darkHeadline4,
        iconTheme: const material.IconThemeData(color: material.Colors.white),
      ),
      bottomNavigationBarTheme: material.BottomNavigationBarThemeData(
        backgroundColor: ColorTheme.darkCardBackground,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.darkTextHint,
        selectedLabelStyle: app_text.TextTheme.darkCaption,
        unselectedLabelStyle: app_text.TextTheme.darkCaption,
        elevation: 8,
      ),
      buttonTheme: material.ButtonThemeData(
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(8)),
        ),
        buttonColor: ColorTheme.primaryColor,
        textTheme: material.ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: material.Colors.white,
          textStyle: app_text.TextTheme.button,
          elevation: 2,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
          padding: const material.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: material.TextButtonThemeData(
        style: material.TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: app_text.TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          padding: const material.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      outlinedButtonTheme: material.OutlinedButtonThemeData(
        style: material.OutlinedButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          textStyle: app_text.TextTheme.button.copyWith(color: ColorTheme.primaryColor),
          side: material.BorderSide(color: ColorTheme.primaryColor, width: 1.5),
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
          padding: const material.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      dialogTheme: material.DialogTheme(
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(12)),
        ),
        backgroundColor: ColorTheme.darkCardBackground,
        titleTextStyle: app_text.TextTheme.darkHeadline4,
        contentTextStyle: app_text.TextTheme.darkBodyText1,
      ),
      textTheme: material.TextTheme(
        displayLarge: app_text.TextTheme.darkHeadline1,
        displayMedium: app_text.TextTheme.darkHeadline2,
        displaySmall: app_text.TextTheme.darkHeadline3,
        headlineMedium: app_text.TextTheme.darkHeadline4,
        bodyLarge: app_text.TextTheme.darkBodyText1,
        bodyMedium: app_text.TextTheme.darkBodyText2,
        titleMedium: app_text.TextTheme.darkSubtitle1,
        titleSmall: app_text.TextTheme.darkSubtitle2,
        labelLarge: app_text.TextTheme.button,
        bodySmall: app_text.TextTheme.darkCaption,
        labelSmall: app_text.TextTheme.darkOverline,
      ),
      inputDecorationTheme: material.InputDecorationTheme(
        filled: true,
        fillColor: ColorTheme.darkCardBackground,
        contentPadding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.darkBorder),
        ),
        enabledBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.darkBorder),
        ),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.primaryColor, width: 1.5),
        ),
        errorBorder: material.OutlineInputBorder(
          borderRadius: const material.BorderRadius.all(material.Radius.circular(8)),
          borderSide: material.BorderSide(color: ColorTheme.error),
        ),
        labelStyle: app_text.TextTheme.darkBodyText2,
        hintStyle: app_text.TextTheme.darkBodyText2.copyWith(color: ColorTheme.darkTextHint),
        errorStyle: app_text.TextTheme.error,
      ),
      dividerTheme: const material.DividerThemeData(
        color: ColorTheme.darkBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: material.CardTheme(
        color: ColorTheme.darkCardBackground,
        elevation: 2,
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.circular(12),
        ),
        margin: const material.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      progressIndicatorTheme: const material.ProgressIndicatorThemeData(
        color: ColorTheme.primaryColor,
        linearTrackColor: ColorTheme.darkBorder,
      ),
      floatingActionButtonTheme: material.FloatingActionButtonThemeData(
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: material.Colors.white,
        elevation: 4,
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(16)),
        ),
      ),
      fontFamily: app_text.TextTheme.fontFamily,
    );
  }
} 