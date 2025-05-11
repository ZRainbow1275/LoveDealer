import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'color_theme.dart';

class ThemeService {
  // final _box = GetStorage();
  // final _key = 'isDarkMode';
  
  // 临时使用内存变量替代GetStorage
  static bool _isDarkMode = false;

  /// 获取主题模式 - 如果未设置则返回亮色模式
  material.ThemeMode get theme => _loadThemeFromBox() ? material.ThemeMode.dark : material.ThemeMode.light;

  /// 从本地存储加载主题设置
  bool _loadThemeFromBox() => _isDarkMode; // _box.read(_key) ?? false;
  
  /// 保存主题设置到本地存储
  _saveThemeToBox(bool isDarkMode) => _isDarkMode = isDarkMode; // _box.write(_key, isDarkMode);

  /// 切换主题
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? material.ThemeMode.light : material.ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }

  /// 获取当前主题模式
  bool isDarkMode() {
    return _loadThemeFromBox();
  }

  /// 获取亮色主题
  material.ThemeData get lightTheme {
    return material.ThemeData(
      primaryColor: ColorTheme.primaryColor,
      scaffoldBackgroundColor: ColorTheme.background,
      appBarTheme: const material.AppBarTheme(
        backgroundColor: material.Colors.white,
        foregroundColor: ColorTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: material.IconThemeData(
          color: ColorTheme.textSecondary,
        ),
      ),
      colorScheme: const material.ColorScheme.light().copyWith(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.accentColor,
      ),
      inputDecorationTheme: material.InputDecorationTheme(
        filled: true,
        fillColor: material.Colors.white,
        border: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: const material.BorderSide(color: ColorTheme.border),
        ),
        enabledBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: const material.BorderSide(color: ColorTheme.border),
        ),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: const material.BorderSide(
            color: ColorTheme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const material.TextTheme(
        displayLarge: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        displayMedium: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        displaySmall: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        headlineMedium: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        headlineSmall: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        titleLarge: material.TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: material.FontWeight.bold,
        ),
        bodyLarge: material.TextStyle(
          color: ColorTheme.textPrimary,
        ),
        bodyMedium: material.TextStyle(
          color: ColorTheme.textSecondary,
        ),
      ),
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: material.Colors.white,
          shape: const material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.all(material.Radius.circular(8)),
          ),
          padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const material.TextStyle(
            fontSize: 16,
            fontWeight: material.FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: material.TextButtonThemeData(
        style: material.TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const material.TextStyle(
            fontSize: 16,
            fontWeight: material.FontWeight.bold,
          ),
        ),
      ),
      dividerTheme: const material.DividerThemeData(
        color: ColorTheme.border,
        thickness: 1,
      ),
      cardTheme: material.CardTheme(
        color: material.Colors.white,
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(12)),
        ),
        elevation: 2,
        shadowColor: material.Colors.black.withOpacity(0.1),
      ),
    );
  }

  /// 获取暗色主题
  material.ThemeData get darkTheme {
    return material.ThemeData(
      brightness: material.Brightness.dark,
      primaryColor: ColorTheme.primaryColor,
      scaffoldBackgroundColor: ColorTheme.darkBackground,
      appBarTheme: const material.AppBarTheme(
        backgroundColor: ColorTheme.darkCardBackground,
        foregroundColor: material.Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: material.IconThemeData(
          color: material.Colors.white70,
        ),
      ),
      colorScheme: const material.ColorScheme.dark().copyWith(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.accentColor,
        surface: ColorTheme.darkCardBackground,
      ),
      inputDecorationTheme: material.InputDecorationTheme(
        filled: true,
        fillColor: ColorTheme.darkCardBackground,
        border: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: material.BorderSide(color: material.Colors.grey[700]!),
        ),
        enabledBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: material.BorderSide(color: material.Colors.grey[700]!),
        ),
        focusedBorder: material.OutlineInputBorder(
          borderRadius: material.BorderRadius.circular(8),
          borderSide: const material.BorderSide(
            color: ColorTheme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: material.TextTheme(
        displayLarge: const material.TextStyle(color: material.Colors.white),
        displayMedium: const material.TextStyle(color: material.Colors.white),
        displaySmall: const material.TextStyle(color: material.Colors.white),
        headlineMedium: const material.TextStyle(color: material.Colors.white),
        headlineSmall: const material.TextStyle(color: material.Colors.white),
        titleLarge: const material.TextStyle(color: material.Colors.white),
        bodyLarge: const material.TextStyle(color: material.Colors.white),
        bodyMedium: material.TextStyle(color: material.Colors.grey[300]),
      ),
      elevatedButtonTheme: material.ElevatedButtonThemeData(
        style: material.ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: material.Colors.white,
          shape: const material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.all(material.Radius.circular(8)),
          ),
          padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const material.TextStyle(
            fontSize: 16,
            fontWeight: material.FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: material.TextButtonThemeData(
        style: material.TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const material.TextStyle(
            fontSize: 16,
            fontWeight: material.FontWeight.bold,
          ),
        ),
      ),
      dividerTheme: material.DividerThemeData(
        color: material.Colors.grey[700],
        thickness: 1,
      ),
      cardTheme: material.CardTheme(
        color: ColorTheme.darkCardBackground,
        shape: const material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(material.Radius.circular(12)),
        ),
        elevation: 2,
        shadowColor: material.Colors.black.withOpacity(0.3),
      ),
    );
  }
} 