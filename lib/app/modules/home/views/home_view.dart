import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../theme/color_theme.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: controller.goToAppInfo,
            color: ColorTheme.textSecondary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                    const SizedBox(height: 60),
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ColorTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            size: 60,
            color: ColorTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '欢迎使用"记录"',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '安全、可靠的双方同意记录工具',
          style: TextStyle(
            fontSize: 16,
            color: ColorTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: '发起新的记录',
          onPressed: controller.goToPairing,
          icon: const Icon(Icons.add_circle_outline, size: 20),
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          text: '查看历史记录',
          onPressed: controller.goToHistory,
          icon: const Icon(Icons.history, size: 20),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTheme.primaryLightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ColorTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '关于记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"记录"应用旨在通过技术手段帮助用户创建和保存性同意记录，为双方提供安全保障。',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppTextButton(
                text: '了解更多',
                onPressed: controller.goToAppInfo,
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: ColorTheme.primaryColor,
                ),
                iconAfterText: true,
              ),
            ],
          ),
        ],
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
} 