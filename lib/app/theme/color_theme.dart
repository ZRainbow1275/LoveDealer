import 'package:flutter/material.dart';

class ColorTheme {
  ColorTheme._();
  
  // 主要颜色
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryDarkColor = Color(0xFF4B45B2);
  static const Color primaryLightColor = Color(0xFFB1AEF5);
  static const Color accentColor = Color(0xFFFF6C90);
  
  // 辅助颜色
  static const Color secondaryColor = Color(0xFF6C63FF);
  static const Color secondaryDarkColor = Color(0xFF5751D3);
  static const Color secondaryLightColor = Color(0xFF9B95FF);
  
  // 主要文本颜色
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9098B1);
  static const Color textHint = Color(0xFFBFC5D2);
  
  // 背景颜色
  static const Color background = Color(0xFFF5F5F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  
  // 功能颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // 暗色模式颜色
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFBBBBBB);
  static const Color darkTextHint = Color(0xFF999999);
  
  // 边框和分隔线
  static const Color border = Color(0xFFEEEEEE);
  static const Color darkBorder = Color(0xFF333333);
  
  // 按钮颜色
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Color(0xFFBDBDBD);
  
  // 透明度
  static const double disabledOpacity = 0.5;
  static const double hoverOpacity = 0.1;
  static const double splashOpacity = 0.2;
  
  // 阴影
  static const Color shadowColor = Color(0x66000000);
  
  // 状态颜色
  static const Color recordActive = Color(0xFFD32F2F);
  static const Color verified = Color(0xFF00C853);
  static const Color unverified = Color(0xFFFFA000);
  
  // 特殊颜色
  static const Color timelineActive = Color(0xFF3366FF);
  static const Color timelineInactive = Color(0xFFBDBDBD);
} 