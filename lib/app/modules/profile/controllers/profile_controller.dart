import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/personal_info.dart';
import '../../../routes/app_pages.dart';
import '../../../services/storage_service.dart';
import '../../../services/auth_service.dart';
import '../../../theme/theme_service.dart';
import '../../../utils/logger.dart';

class ProfileController extends GetxController {
  final RxInt selectedIndex = 2.obs; // 底部导航栏默认选中我的
  final Rx<PersonalInfo?> personalInfo = Rx<PersonalInfo?>(null);
  final RxBool isLoading = true.obs;
  final RxDouble completionPercentage = 0.0.obs;
  
  // 编辑个人信息的控制器
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  // 服务
  final StorageService _storageService = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();
  final ThemeService _themeService = ThemeService();
  final Logger _logger = Logger();
  
  // 状态变量
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString avatar = ''.obs;
  final RxBool isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadPersonalInfo();
    _loadUserProfile();
    isDarkMode.value = _themeService.isDarkMode();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    idNumberController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }
  
  // 加载个人信息
  Future<void> loadPersonalInfo() async {
    isLoading.value = true;
    try {
      final info = await _storageService.getPersonalInfo();
      personalInfo.value = info;
      
      // 如果有个人信息，则设置编辑控制器
      if (info != null) {
        nameController.text = info.name;
        idNumberController.text = info.idNumber;
        phoneController.text = info.phoneNumber;
        emailController.text = info.email;
        addressController.text = info.address ?? '';
      }
      
      // 计算信息完整度
      calculateCompletionPercentage();
    } catch (e) {
      debugPrint('加载个人信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 计算信息完整度
  void calculateCompletionPercentage() {
    if (personalInfo.value == null) {
      completionPercentage.value = 0.0;
      return;
    }
    
    int totalFields = 5; // 姓名、身份证、手机、邮箱、地址
    int completedFields = 0;
    
    if (personalInfo.value!.name.isNotEmpty) completedFields++;
    if (personalInfo.value!.idNumber.isNotEmpty) completedFields++;
    if (personalInfo.value!.phoneNumber.isNotEmpty) completedFields++;
    if (personalInfo.value!.email.isNotEmpty) completedFields++;
    if (personalInfo.value!.address != null && personalInfo.value!.address!.isNotEmpty) completedFields++;
    
    completionPercentage.value = completedFields / totalFields;
  }
  
  // 保存个人信息
  Future<void> savePersonalInfo() async {
    try {
      // 创建或更新个人信息
      final newInfo = PersonalInfo(
        id: personalInfo.value?.id,
        name: nameController.text,
        idNumber: idNumberController.text,
        phoneNumber: phoneController.text,
        email: emailController.text,
        address: addressController.text.isEmpty ? null : addressController.text,
      );
      
      await _storageService.setPersonalInfo(newInfo);
      personalInfo.value = newInfo;
      
      // 更新完整度
      calculateCompletionPercentage();
      
      Get.back(); // 关闭编辑对话框
      Get.snackbar('成功', '个人信息已更新', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('保存个人信息失败: $e');
      Get.snackbar('错误', '保存个人信息失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 底部导航切换
  void changePage(int index) {
    if (index != selectedIndex.value) {
      selectedIndex.value = index;
      switch (index) {
        case 0:
          Get.offAllNamed(Routes.HOME);
          break;
        case 1:
          Get.offAllNamed(Routes.HISTORY);
          break;
        case 2:
          // 已经在个人页面，不需要操作
          break;
      }
    }
  }
  
  // 跳转到应用信息页面
  void goToAppInfo() {
    Get.toNamed(Routes.APP_INFO);
  }
  
  // 检查信息是否完整
  bool isProfileComplete() {
    return completionPercentage.value >= 1.0;
  }
  
  // 加载用户资料
  Future<void> _loadUserProfile() async {
    isLoading.value = true;
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        username.value = user.username ?? '用户';
        email.value = user.email ?? '';
        avatar.value = user.avatar ?? '';
      }
    } catch (e) {
      _logger.e('加载用户资料失败', error: e);
    } finally {
      isLoading.value = false;
    }
  }
  
  // 切换主题模式
  void toggleThemeMode() {
    _themeService.switchTheme();
    isDarkMode.value = _themeService.isDarkMode();
  }
  
  // 查看应用信息
  void viewAppInfo() {
    Get.toNamed(Routes.APP_INFO);
  }
  
  // 退出登录
  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed(Routes.AGREEMENT);
    } catch (e) {
      _logger.e('退出登录失败', error: e);
      Get.snackbar('错误', '退出登录失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 清除缓存
  Future<void> clearCache() async {
    try {
      isLoading.value = true;
      
      Get.dialog(
        AlertDialog(
          title: const Text('清除缓存'),
          content: const Text('确定要清除应用缓存吗？这将删除所有临时文件，但不会影响您的记录数据。'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                
                await _storageService.clearCache();
                
                Get.snackbar('成功', '缓存已清除', snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      _logger.e('清除缓存失败', error: e);
      Get.snackbar('错误', '清除缓存失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
} 