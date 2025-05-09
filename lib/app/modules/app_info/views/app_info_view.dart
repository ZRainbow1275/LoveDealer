import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_info_controller.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../theme/color_theme.dart';

class AppInfoView extends GetView<AppInfoController> {
  const AppInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于记录'),
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAppHeader(),
              const SizedBox(height: 24),
              _buildAppIntroSection(),
              const SizedBox(height: 16),
              _buildDocumentsSection(),
              const SizedBox(height: 16),
              _buildContactSection(),
              const SizedBox(height: 16),
              _buildTechnicalSection(),
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: ColorTheme.primaryColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.file_copy, // 文件图标替代原有的心形图标
            color: Colors.white,
            size: 64,
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => Text(
          controller.appName.value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: ColorTheme.textPrimary,
          ),
        )),
        const SizedBox(height: 8),
        Obx(() => Text(
          '版本 ${controller.appVersion.value}',
          style: const TextStyle(
            fontSize: 16,
            color: ColorTheme.textSecondary,
          ),
        )),
      ],
    );
  }

  Widget _buildAppIntroSection() {
    return _buildSectionContainer(
      icon: Icons.info_outline,
      title: '应用介绍',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '「记录」是一款为双方提供性同意记录的应用程序，旨在提供安全、可靠的性同意证明。通过蓝牙配对、五层哈希验证机制等先进技术，确保记录的真实性与完整性。',
            style: TextStyle(
              fontSize: 15,
              color: ColorTheme.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.shield_outlined,
            text: '所有数据均采用加密技术保护，仅存储于用户设备本地',
          ),
          _buildFeatureItem(
            icon: Icons.fingerprint,
            text: '五层哈希验证机制确保数据完整性和防篡改',
          ),
          _buildFeatureItem(
            icon: Icons.bluetooth,
            text: '蓝牙设备配对确保双方都在场并同意记录',
          ),
          _buildFeatureItem(
            icon: Icons.verified_user,
            text: '人脸识别、照片拍摄和音频录制多重证据收集',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: ColorTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
              color: ColorTheme.textPrimary,
              height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return _buildSectionContainer(
      icon: Icons.file_copy_outlined,
      title: '文档与协议',
      child: Column(
        children: [
          _buildDocumentItem(
            icon: Icons.file_present_outlined,
            title: '用户协议',
            description: '使用本应用的条款与条件',
            onTap: () => Get.toNamed('/agreement', arguments: {'tab': 0}),
          ),
          const Divider(height: 1),
          _buildDocumentItem(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            description: '关于数据收集与使用的说明',
            onTap: () => Get.toNamed('/agreement', arguments: {'tab': 1}),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
        children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                    title,
                        style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: ColorTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                    description,
                        style: const TextStyle(
                      fontSize: 14,
                          color: ColorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSectionContainer(
      icon: Icons.email_outlined,
      title: '联系我们',
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.email,
            text: 'support@lovedealer.com',
            onTap: controller.sendEmail,
              ),
          _buildContactItem(
            icon: Icons.language,
            text: 'www.lovedealer.com',
            onTap: controller.visitWebsite,
                ),
          _buildContactItem(
            icon: Icons.phone,
            text: '400-888-7777',
            onTap: controller.callPhoneNumber,
          ),
          _buildContactItem(
            icon: Icons.location_on,
            text: '北京市朝阳区建国路88号',
            onTap: controller.viewLocation,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(
              icon,
                    size: 18,
                    color: ColorTheme.primaryColor,
                  ),
            ),
            Expanded(
              child: Text(
                    text,
                style: const TextStyle(
                      fontSize: 15,
                      color: ColorTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: ColorTheme.textHint,
            ),
          ],
        ),
            if (!isLast)
              const Divider(
                height: 24,
                thickness: 1,
                color: Color(0xFFF0F0F0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalSection() {
    return _buildSectionContainer(
      icon: Icons.code,
      title: '技术信息',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '本应用使用Flutter框架开发，采用Material组件库构建，实现了高性能的跨平台用户体验。应用架构遵循干净架构原则，使用GetX进行状态管理和导航控制。',
            style: TextStyle(
              fontSize: 15,
              color: ColorTheme.textPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '应用采用了安全的加密算法和数据存储方案，所有记录均通过五层哈希验证机制确保完整性，本地数据使用Flutter安全存储方案加密保存。',
            style: TextStyle(
              fontSize: 15,
              color: ColorTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ColorTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: const [
        Text(
          '© 2023 记录 All Rights Reserved.',
          style: TextStyle(
            fontSize: 12,
            color: ColorTheme.textHint,
          ),
        ),
      ],
    );
  }
} 