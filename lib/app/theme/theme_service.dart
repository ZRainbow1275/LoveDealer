import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'color_theme.dart';

class ThemeService {
  // final _box = GetStorage();
  // final _key = 'isDarkMode';
  
  // 临时使用内存变量替代GetStorage
  static bool _isDarkMode = false;

  /// 获取主题模式 - 如果未设置则返回亮色模式
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /// 从本地存储加载主题设置
  bool _loadThemeFromBox() => _isDarkMode; // _box.read(_key) ?? false;
  
  /// 保存主题设置到本地存储
  _saveThemeToBox(bool isDarkMode) => _isDarkMode = isDarkMode; // _box.write(_key, isDarkMode);

  /// 切换主题
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }

  /// 获取当前主题模式
  bool isDarkMode() {
    return _loadThemeFromBox();
  }

  /// 获取亮色主题
  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ColorTheme.primaryColor,
      scaffoldBackgroundColor: ColorTheme.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ColorTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: ColorTheme.textSecondary,
        ),
      ),
      colorScheme: const ColorScheme.light().copyWith(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.accentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ColorTheme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headline5: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyText1: TextStyle(
          color: ColorTheme.textPrimary,
        ),
        bodyText2: TextStyle(
          color: ColorTheme.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ColorTheme.borderColor,
        thickness: 1,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  /// 获取暗色主题
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ColorTheme.primaryColor,
      scaffoldBackgroundColor: ColorTheme.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTheme.cardDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white70,
        ),
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: ColorTheme.primaryColor,
        secondary: ColorTheme.accentColor,
        surface: ColorTheme.cardDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTheme.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ColorTheme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: TextTheme(
        headline1: const TextStyle(color: Colors.white),
        headline2: const TextStyle(color: Colors.white),
        headline3: const TextStyle(color: Colors.white),
        headline4: const TextStyle(color: Colors.white),
        headline5: const TextStyle(color: Colors.white),
        headline6: const TextStyle(color: Colors.white),
        bodyText1: const TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.grey[300]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[700],
        thickness: 1,
      ),
      cardTheme: CardTheme(
        color: ColorTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
} 