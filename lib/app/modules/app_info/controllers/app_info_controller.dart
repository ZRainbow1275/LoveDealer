import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoController extends GetxController {
  final RxString appVersion = '1.0.0'.obs;
  final RxString appName = '记录'.obs;
  final RxString packageName = 'com.example.lovedealer'.obs;
  final RxString buildNumber = '1'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }
  
  // 加载应用信息
  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName.value = packageInfo.appName;
      packageName.value = packageInfo.packageName;
      appVersion.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('获取应用信息失败: $e');
    }
  }
  
  // 打开用户协议
  void openUserAgreement() {
    Get.toNamed('/agreement', arguments: {'tab': 0});
  }
  
  // 打开隐私政策
  void openPrivacyPolicy() {
    Get.toNamed('/agreement', arguments: {'tab': 1});
  }
  
  // 发送邮件联系
  void sendEmail() {
    _launchUrl('mailto:support@lovedealer.com');
  }
  
  // 访问网站
  void visitWebsite() {
    _launchUrl('https://www.lovedealer.com');
  }
  
  // 拨打电话
  void callPhoneNumber() {
    _launchUrl('tel:4008887777');
  }
  
  // 查看地图位置
  void viewLocation() {
    _launchUrl('https://maps.google.com/?q=北京市朝阳区建国路88号');
  }
  
  // 发送反馈邮件
  void sendFeedbackEmail() {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'feedback@lovedealer.com',
      query: 'subject=记录应用反馈&body=请在此处填写您的反馈内容',
    );
    _launchUrl(emailUri.toString());
  }
  
  // 打开URL的通用方法
  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar('错误', '无法打开链接: $urlString', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('打开链接失败: $e');
      Get.snackbar('错误', '打开链接失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 返回上一页
  void goBack() {
    Get.back();
  }
} 