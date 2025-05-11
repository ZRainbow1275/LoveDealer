import 'package:flutter/material.dart' as material;

class ColorTheme {
  ColorTheme._();
  
  // 主要颜色
  static const material.Color primaryColor = material.Color(0xFF6C63FF);
  static const material.Color primaryDarkColor = material.Color(0xFF4B45B2);
  static const material.Color primaryLightColor = material.Color(0xFFB1AEF5);
  static const material.Color accentColor = material.Color(0xFFFF6C90);
  
  // 辅助颜色
  static const material.Color secondaryColor = material.Color(0xFF6C63FF);
  static const material.Color secondaryDarkColor = material.Color(0xFF5751D3);
  static const material.Color secondaryLightColor = material.Color(0xFF9B95FF);
  
  // 主要文本颜色
  static const material.Color textPrimary = material.Color(0xFF2D3142);
  static const material.Color textSecondary = material.Color(0xFF9098B1);
  static const material.Color textHint = material.Color(0xFFBFC5D2);
  
  // 背景颜色
  static const material.Color background = material.Color(0xFFF5F5F7);
  static const material.Color cardBackground = material.Color(0xFFFFFFFF);
  static const material.Color darkBackground = material.Color(0xFF121212);
  static const material.Color darkCardBackground = material.Color(0xFF1E1E1E);
  
  // 功能颜色
  static const material.Color success = material.Color(0xFF4CAF50);
  static const material.Color warning = material.Color(0xFFFFC107);
  static const material.Color error = material.Color(0xFFE53935);
  static const material.Color info = material.Color(0xFF2196F3);
  
  // 暗色模式颜色
  static const material.Color darkTextPrimary = material.Color(0xFFEEEEEE);
  static const material.Color darkTextSecondary = material.Color(0xFFBBBBBB);
  static const material.Color darkTextHint = material.Color(0xFF999999);
  
  // 边框和分隔线
  static const material.Color border = material.Color(0xFFEEEEEE);
  static const material.Color darkBorder = material.Color(0xFF333333);
  
  // 按钮颜色
  static const material.Color buttonText = material.Colors.white;
  static const material.Color disabledButton = material.Color(0xFFBDBDBD);
  
  // 透明度
  static const double disabledOpacity = 0.5;
  static const double hoverOpacity = 0.1;
  static const double splashOpacity = 0.2;
  
  // 阴影
  static const material.Color shadowColor = material.Color(0x66000000);
  
  // 状态颜色
  static const material.Color recordActive = material.Color(0xFFD32F2F);
  static const material.Color verified = material.Color(0xFF00C853);
  static const material.Color unverified = material.Color(0xFFFFA000);
  
  // 特殊颜色
  static const material.Color timelineActive = material.Color(0xFF3366FF);
  static const material.Color timelineInactive = material.Color(0xFFBDBDBD);
} 