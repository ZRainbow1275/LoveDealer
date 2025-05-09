import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../data/models/personal_info.dart';
import 'storage_service.dart';

/// 用户管理服务
/// 
/// 负责用户协议签署、个人信息管理和用户引导功能
class UserService extends GetxService {
  static UserService get to => Get.find<UserService>();
  
  final StorageService _storageService = StorageService.to;
  
  // 个人信息
  final Rx<PersonalInfo> personalInfo = PersonalInfo.empty().obs;
  
  // 协议签署状态
  final RxBool _agreementSigned = false.obs;
  final RxBool _privacyPolicySigned = false.obs;
  
  // 信息完整度
  final RxDouble _completionRate = 0.0.obs;
  
  // 是否首次使用
  final RxBool _isFirstTime = true.obs;
  
  bool get agreementSigned => _agreementSigned.value;
  bool get privacyPolicySigned => _privacyPolicySigned.value;
  double get completionRate => _completionRate.value;
  bool get isFirstTime => _isFirstTime.value;
  
  // 个人信息是否完整（完整率为100%）
  bool get isProfileComplete => _completionRate.value >= 1.0;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  /// 加载用户数据
  Future<void> _loadUserData() async {
    try {
      // 加载协议签署状态
      _agreementSigned.value = await _storageService.getBool('agreement_signed') ?? false;
      _privacyPolicySigned.value = await _storageService.getBool('privacy_policy_signed') ?? false;
      
      // 加载首次使用状态
      _isFirstTime.value = await _storageService.getBool('is_first_time') ?? true;
      
      // 加载个人信息
      final savedInfo = await _storageService.getPersonalInfo();
      if (savedInfo != null) {
        personalInfo.value = savedInfo;
        _calculateCompletionRate();
      }
    } catch (e) {
      debugPrint('加载用户数据失败: $e');
    }
  }
  
  /// 签署用户协议
  Future<void> signAgreement() async {
    _agreementSigned.value = true;
    await _storageService.setBool('agreement_signed', true);
  }
  
  /// 签署隐私政策
  Future<void> signPrivacyPolicy() async {
    _privacyPolicySigned.value = true;
    await _storageService.setBool('privacy_policy_signed', true);
  }
  
  /// 完成首次使用引导
  Future<void> completeFirstTimeGuide() async {
    _isFirstTime.value = false;
    await _storageService.setBool('is_first_time', false);
  }
  
  /// 更新个人信息
  Future<void> updatePersonalInfo(PersonalInfo info) async {
    personalInfo.value = info;
    await _storageService.savePersonalInfo(info);
    _calculateCompletionRate();
  }
  
  /// 计算个人信息完整度
  void _calculateCompletionRate() {
    final info = personalInfo.value;
    
    // 计算非空字段数量
    int filledFields = 0;
    int totalFields = 0;
    
    if (info.name.isNotEmpty) filledFields++;
    totalFields++;
    
    if (info.idNumber.isNotEmpty) filledFields++;
    totalFields++;
    
    if (info.phoneNumber.isNotEmpty) filledFields++;
    totalFields++;
    
    if (info.email.isNotEmpty) filledFields++;
    totalFields++;
    
    if (info.address.isNotEmpty) filledFields++;
    totalFields++;
    
    if (info.birthday != null) filledFields++;
    totalFields++;
    
    if (info.gender.isNotEmpty) filledFields++;
    totalFields++;
    
    // 计算完整率
    _completionRate.value = filledFields / totalFields;
  }
  
  /// 验证个人信息字段
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '姓名不能为空';
    }
    return null;
  }
  
  String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '身份证号不能为空';
    }
    // 简单的身份证号验证（仅长度，实际应用中应当更严格）
    if (value.length != 18) {
      return '身份证号必须为18位';
    }
    return null;
  }
  
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '手机号不能为空';
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '邮箱不能为空';
    }
    if (!GetUtils.isEmail(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
} 