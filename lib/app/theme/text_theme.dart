import 'package:flutter/material.dart';
import 'color_theme.dart';

class TextTheme {
  TextTheme._();
  
  static const String fontFamily = 'PingFang';
  
  // 标题样式
  static TextStyle headline1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static TextStyle headline4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  // 正文样式
  static TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ColorTheme.textSecondary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  // 副标题样式
  static TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorTheme.textSecondary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  // 按钮样式
  static TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorTheme.buttonText,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  // 小字样式
  static TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ColorTheme.textHint,
    fontFamily: fontFamily,
  );
  
  // 过度小字样式
  static TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: ColorTheme.textHint,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  // 暗色模式样式
  static TextStyle darkHeadline1 = headline1.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkHeadline2 = headline2.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkHeadline3 = headline3.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkHeadline4 = headline4.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkBodyText1 = bodyText1.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkBodyText2 = bodyText2.copyWith(color: ColorTheme.darkTextSecondary);
  static TextStyle darkSubtitle1 = subtitle1.copyWith(color: ColorTheme.darkTextPrimary);
  static TextStyle darkSubtitle2 = subtitle2.copyWith(color: ColorTheme.darkTextSecondary);
  static TextStyle darkCaption = caption.copyWith(color: ColorTheme.darkTextHint);
  static TextStyle darkOverline = overline.copyWith(color: ColorTheme.darkTextHint);
  
  // 特殊状态样式
  static TextStyle error = caption.copyWith(color: ColorTheme.error);
  static TextStyle success = caption.copyWith(color: ColorTheme.success);
  static TextStyle warning = caption.copyWith(color: ColorTheme.warning);
  static TextStyle info = caption.copyWith(color: ColorTheme.info);
  
  // 链接样式
  static TextStyle link = bodyText2.copyWith(
    color: ColorTheme.primaryColor,
    decoration: TextDecoration.underline,
  );
  
  // 强调样式
  static TextStyle emphasis = bodyText1.copyWith(
    fontWeight: FontWeight.w500,
  );
} 