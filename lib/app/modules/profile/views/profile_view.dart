import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../../widgets/forms/app_text_field.dart';
import '../../../../widgets/dialogs/dialogs.dart';
import '../../../theme/color_theme.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWarningBanner(),
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildAppInfoSection(),
                      const SizedBox(height: 24),
                      _buildSettings(),
                    ],
                  ),
                );
              }),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Obx(() {
      if (controller.completionPercentage.value >= 1.0) {
        return const SizedBox.shrink();
      }
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ColorTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: ColorTheme.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '个人信息不完整',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '请完善个人信息以使用全部功能',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTheme.warning.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final info = controller.personalInfo.value;
      final name = info?.name ?? '请设置姓名';
      final completeness = (controller.completionPercentage.value * 100).toInt();
      
      return Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: ColorTheme.primaryLightColor,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showEditAvatarModal(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: ColorTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showEditProfileModal(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: ColorTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: controller.completionPercentage.value,
                          backgroundColor: ColorTheme.timelineInactive.withOpacity(0.3),
                          color: completeness < 100 
                              ? ColorTheme.warning 
                              : ColorTheme.verified,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completeness%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: completeness < 100 
                            ? ColorTheme.warning 
                            : ColorTheme.verified,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoSection() {
    return Obx(() {
      final info = controller.personalInfo.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoHeader('基本信息', onTap: () => _showEditProfileModal(context)),
            _buildInfoItem('姓名', info?.name ?? '未设置'),
            _buildInfoItem('身份证号', info?.idNumber ?? '未设置', obscure: true),
            _buildInfoItem('手机号', info?.phoneNumber ?? '未设置'),
            _buildInfoItem('邮箱', info?.email ?? '未设置'),
            _buildInfoItem('地址', info?.address ?? '未设置'),
          ],
        ),
      );
    });
  }

  Widget _buildInfoHeader(String title, {VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Text(
                      '编辑',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: ColorTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: ColorTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              obscure && value != '未设置' 
                  ? '${value.substring(0, 3)}****${value.substring(value.length - 4)}' 
                  : value,
              style: TextStyle(
                fontSize: 14,
                color: value == '未设置' 
                    ? ColorTheme.textHint 
                    : ColorTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoHeader('关于应用'),
          InkWell(
            onTap: controller.goToAppInfo,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.info_outline,
                        color: ColorTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '记录 (LoveDealer)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '版本 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '查看详细信息',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: ColorTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 暗黑模式
          Obx(() => _buildSettingItem(
            icon: Icons.dark_mode,
            title: '暗黑模式',
            trailing: Switch(
              value: controller.isDarkMode.value,
              onChanged: (_) => controller.toggleThemeMode(),
              activeColor: ColorTheme.primaryColor,
            ),
            onTap: controller.toggleThemeMode,
          )),
          const Divider(),
          
          // 应用信息
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '应用信息',
            trailing: const Icon(
              Icons.chevron_right,
              color: ColorTheme.textHint,
              size: 20,
            ),
            onTap: controller.viewAppInfo,
          ),
          const Divider(),
          
          // 清除缓存
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: '清除缓存',
            trailing: const Icon(
              Icons.chevron_right,
              color: ColorTheme.textHint,
              size: 20,
            ),
            onTap: controller.clearCache,
          ),
          const Divider(),
          
          // 退出登录
          _buildSettingItem(
            icon: Icons.logout,
            title: '退出登录',
            textColor: ColorTheme.error,
            trailing: const Icon(
              Icons.chevron_right,
              color: ColorTheme.textHint,
              size: 20,
            ),
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? ColorTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? ColorTheme.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '历史',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  // 编辑头像弹窗
  void _showEditAvatarModal(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '更换头像',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      AppIconButton(
                        icon: Icons.camera_alt,
                        onPressed: () {
                          Get.back();
                          // 打开相机逻辑
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('拍照'),
                    ],
                  ),
                  Column(
                    children: [
                      AppIconButton(
                        icon: Icons.photo_library,
                        onPressed: () {
                          Get.back();
                          // 选择照片逻辑
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('相册'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                text: '取消',
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 编辑个人信息弹窗
  void _showEditProfileModal(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '编辑个人信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: '姓名',
                  controller: controller.nameController,
                  hint: '请输入姓名',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: '身份证号',
                  controller: controller.idNumberController,
                  hint: '请输入身份证号',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: '手机号',
                  controller: controller.phoneController,
                  hint: '请输入手机号',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: '邮箱',
                  controller: controller.emailController,
                  hint: '请输入邮箱',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: '地址',
                  controller: controller.addressController,
                  hint: '请输入地址',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: '取消',
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        text: '保存',
                        onPressed: controller.savePersonalInfo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 