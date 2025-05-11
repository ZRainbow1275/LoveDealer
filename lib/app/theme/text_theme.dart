import 'package:flutter/material.dart' as material;
import 'color_theme.dart';

class TextTheme {
  TextTheme._();
  
  static const String fontFamily = 'PingFang';
  
  // 标题样式
  static const material.TextStyle headline1 = material.TextStyle(
    fontSize: 26,
    fontWeight: material.FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static const material.TextStyle headline2 = material.TextStyle(
    fontSize: 22,
    fontWeight: material.FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static const material.TextStyle headline3 = material.TextStyle(
    fontSize: 20,
    fontWeight: material.FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static const material.TextStyle headline4 = material.TextStyle(
    fontSize: 18,
    fontWeight: material.FontWeight.bold,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  // 正文样式
  static const material.TextStyle bodyText1 = material.TextStyle(
    fontSize: 16,
    fontWeight: material.FontWeight.normal,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static const material.TextStyle bodyText2 = material.TextStyle(
    fontSize: 14,
    fontWeight: material.FontWeight.normal,
    color: ColorTheme.textSecondary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  // 副标题样式
  static const material.TextStyle subtitle1 = material.TextStyle(
    fontSize: 16,
    fontWeight: material.FontWeight.w500,
    color: ColorTheme.textPrimary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static const material.TextStyle subtitle2 = material.TextStyle(
    fontSize: 14,
    fontWeight: material.FontWeight.w500,
    color: ColorTheme.textSecondary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  // 按钮样式
  static const material.TextStyle button = material.TextStyle(
    fontSize: 16,
    fontWeight: material.FontWeight.w500,
    color: ColorTheme.buttonText,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  // 小字样式
  static const material.TextStyle caption = material.TextStyle(
    fontSize: 12,
    fontWeight: material.FontWeight.normal,
    color: ColorTheme.textHint,
    fontFamily: fontFamily,
  );
  
  // 过度小字样式
  static const material.TextStyle overline = material.TextStyle(
    fontSize: 10,
    fontWeight: material.FontWeight.normal,
    color: ColorTheme.textHint,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  // 暗色模式样式
  static material.TextStyle darkHeadline1 = headline1.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkHeadline2 = headline2.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkHeadline3 = headline3.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkHeadline4 = headline4.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkBodyText1 = bodyText1.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkBodyText2 = bodyText2.copyWith(color: ColorTheme.darkTextSecondary);
  static material.TextStyle darkSubtitle1 = subtitle1.copyWith(color: ColorTheme.darkTextPrimary);
  static material.TextStyle darkSubtitle2 = subtitle2.copyWith(color: ColorTheme.darkTextSecondary);
  static material.TextStyle darkCaption = caption.copyWith(color: ColorTheme.darkTextHint);
  static material.TextStyle darkOverline = overline.copyWith(color: ColorTheme.darkTextHint);
  
  // 特殊状态样式
  static material.TextStyle error = caption.copyWith(color: ColorTheme.error);
  static material.TextStyle success = caption.copyWith(color: ColorTheme.success);
  static material.TextStyle warning = caption.copyWith(color: ColorTheme.warning);
  static material.TextStyle info = caption.copyWith(color: ColorTheme.info);
  
  // 链接样式
  static material.TextStyle link = bodyText2.copyWith(
    color: ColorTheme.primaryColor,
    decoration: material.TextDecoration.underline,
  );
  
  // 强调样式
  static material.TextStyle emphasis = bodyText1.copyWith(
    fontWeight: material.FontWeight.w500,
  );
} 