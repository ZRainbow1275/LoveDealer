import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/color_theme.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final bool barrierDismissible;

  const LoadingDialog({
    Key? key,
    this.message = '请稍候...',
    this.barrierDismissible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorTheme.primaryColor),
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16.0,
              color: ColorTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 便捷方法，用于显示加载对话框
  static Future<void> show({
    String message = '请稍候...',
    bool barrierDismissible = false,
  }) {
    return Get.dialog(
      LoadingDialog(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  // 便捷方法，用于关闭加载对话框
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
} 