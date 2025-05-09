import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/personal_info.dart';
import '../services/storage_service.dart';
import '../routes/app_pages.dart';

class AppController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxBool isFirstLaunch = true.obs;
  final RxBool isAgreementAccepted = false.obs;
  final RxBool isDarkMode = false.obs;
  final Rx<PersonalInfo?> personalInfo = Rx<PersonalInfo?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _loadAppState();
  }
  
  Future<void> _loadAppState() async {
    try {
      // 加载首次启动状态
      isFirstLaunch.value = await _storageService.getIsFirstLaunch();
      
      // 加载协议接受状态
      isAgreementAccepted.value = await _storageService.getAgreementAccepted();
      
      // 加载暗黑模式状态
      isDarkMode.value = await _storageService.getDarkMode();
      
      // 加载个人信息
      final info = await _storageService.getPersonalInfo();
      personalInfo.value = info;
      
      // 根据首次启动状态和协议状态决定是否跳转到协议页面
      if (!isAgreementAccepted.value) {
        Get.offAllNamed(Routes.AGREEMENT);
      } else if (personalInfo.value == null || !personalInfo.value!.isComplete()) {
        Get.offAllNamed(Routes.PROFILE);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      debugPrint('加载应用状态出错: $e');
    }
  }
  
  // 接受协议
  Future<void> acceptAgreement() async {
    isAgreementAccepted.value = true;
    await _storageService.setAgreementAccepted(true);
    if (isFirstLaunch.value) {
      isFirstLaunch.value = false;
      await _storageService.setIsFirstLaunch(false);
    }
    Get.offAllNamed(Routes.HOME);
  }
  
  // 切换暗黑模式
  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    await _storageService.setDarkMode(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  // 保存个人信息
  Future<void> savePersonalInfo(PersonalInfo info) async {
    personalInfo.value = info;
    await _storageService.setPersonalInfo(info);
  }
  
  // 获取个人信息完整度百分比
  int getPersonalInfoCompleteness() {
    if (personalInfo.value == null) return 0;
    return personalInfo.value!.getCompleteness();
  }
  
  // 清除所有应用数据（开发测试用）
  Future<void> clearAllData() async {
    await _storageService.clearAll();
    isFirstLaunch.value = true;
    isAgreementAccepted.value = false;
    isDarkMode.value = false;
    personalInfo.value = null;
    Get.offAllNamed(Routes.AGREEMENT);
  }
} 