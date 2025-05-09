import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 通知工具类
class NotificationUtils {
  /// 显示成功提示
  static void showSuccess(String message, {
    String? title,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title ?? '成功',
      message,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  
  /// 显示错误提示
  static void showError(String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title ?? '错误',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
  
  /// 显示警告提示
  static void showWarning(String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title ?? '警告',
      message,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }
  
  /// 显示信息提示
  static void showInfo(String message, {
    String? title,
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title ?? '提示',
      message,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
  
  /// 显示加载对话框
  static void showLoading({String? message}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(message, style: const TextStyle(color: Colors.black87)),
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  /// 隐藏加载对话框
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
  
  /// 显示确认对话框
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    
    return result ?? false;
  }
  
  /// 显示底部菜单
  static Future<T?> showBottomSheet<T>({
    required List<BottomSheetItem<T>> items,
    String? title,
    bool enableDrag = true,
    bool isDismissible = true,
    bool isScrollControlled = false,
  }) {
    return Get.bottomSheet<T>(
      Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...items.map((item) => ListTile(
              leading: item.icon,
              title: Text(item.title),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () => Get.back(result: item.value),
            )),
          ],
        ),
      ),
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
    );
  }
  
  /// 显示自定义对话框
  static Future<T?> showCustomDialog<T>({
    required Widget content,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return Get.dialog<T>(
      Dialog(
        child: content,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
    );
  }
  
  /// 显示吐司提示
  static void showToast(String message, {
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black87,
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
    
    switch (gravity) {
      case ToastGravity.TOP:
        Get.showOverlay(
          asyncFunction: () => Future.delayed(duration),
          loadingWidget: Positioned(
            top: 100,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: Get.width,
                child: Center(child: toast),
              ),
            ),
          ),
        );
        break;
      case ToastGravity.CENTER:
        Get.showOverlay(
          asyncFunction: () => Future.delayed(duration),
          loadingWidget: Positioned(
            top: Get.height / 2 - 50,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: Get.width,
                child: Center(child: toast),
              ),
            ),
          ),
        );
        break;
      case ToastGravity.BOTTOM:
      default:
        Get.showOverlay(
          asyncFunction: () => Future.delayed(duration),
          loadingWidget: Positioned(
            bottom: 100,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: Get.width,
                child: Center(child: toast),
              ),
            ),
          ),
        );
    }
  }
}

/// 吐司位置枚举
enum ToastGravity {
  TOP,
  CENTER,
  BOTTOM,
}

/// 底部菜单项
class BottomSheetItem<T> {
  final String title;
  final String? subtitle;
  final Icon? icon;
  final T value;
  
  BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
} 