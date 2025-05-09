import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/storage_service.dart';

class AgreementController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final RxBool hasReachedBottom = false.obs;
  final RxBool isAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _checkPreviousAgreement();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  // 监听滚动以确定用户是否已阅读到底部
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
      hasReachedBottom.value = true;
    }
  }

  // 检查用户是否已同意过协议
  void _checkPreviousAgreement() {
    final storageService = Get.find<StorageService>();
    final hasAgreed = storageService.hasAgreedToTerms();
    
    if (hasAgreed) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  // 同意协议
  void agreeToTerms() {
    if (isAgreed.value) {
      final storageService = Get.find<StorageService>();
      storageService.setAgreedToTerms(true);
      Get.offAllNamed(Routes.HOME);
    }
  }

  // 切换同意状态
  void toggleAgreement(bool value) {
    isAgreed.value = value;
  }
} 