import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../data/models/pairing_info.dart';
import '../../../theme/color_theme.dart';
import '../controllers/pairing_controller.dart';

class PairingView extends GetView<PairingController> {
  const PairingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配对设备'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
          color: ColorTheme.textSecondary,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          // 根据配对状态显示不同的界面
          if (controller.pairingStatus.value == PairingStatus.PAIRED) {
            return _buildPairedView();
          } else if (controller.pairingStatus.value == PairingStatus.EXPIRED) {
            return _buildExpiredView();
          } else if (controller.pairingStatus.value == PairingStatus.PENDING) {
            // 根据不同的PENDING状态下的情况显示不同界面
            if (controller.pairingCode.value.isNotEmpty) {
              return _buildPairingCodeView();
            } else if (controller.pairingDeviceName.value.isNotEmpty) {
              return _buildDeviceSelectedView();
            } else {
              return _buildInitialView();
            }
          } else {
            // 默认视图
            return _buildInitialView();
          }
        }),
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection('配对流程', '请选择配对方式'),
          const SizedBox(height: 40),
          _buildPairingOption(
            title: '生成配对码',
            description: '生成配对码，让对方输入以完成配对',
            icon: Icons.confirmation_number_outlined,
            onTap: controller.generatePairingCode,
            isLoading: controller.isGeneratingCode.value,
          ),
          const SizedBox(height: 20),
          _buildPairingOption(
            title: '扫描设备',
            description: '扫描附近可配对的设备',
            icon: Icons.bluetooth_searching,
            onTap: controller.startScanning,
            isLoading: controller.isScanning.value,
          ),
          const Spacer(),
          Obx(() {
            if (controller.isScanning.value) {
              return Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    '正在扫描附近设备...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: '停止扫描',
                    onPressed: controller.stopScanning,
                  ),
                  const SizedBox(height: 16),
                  _buildDevicesList(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPairingCodeView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection('配对码', '请让对方输入以下配对码'),
          const SizedBox(height: 40),
          _buildPairingCodeDisplay(controller.pairingCode.value),
          const SizedBox(height: 40),
          const Text(
            '配对码有效期为5分钟，过期后需要重新生成',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const Text(
            '等待对方输入配对码...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const Spacer(),
          SecondaryButton(
            text: '取消配对',
            onPressed: controller.goBack,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDeviceSelectedView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection('设备已选择', '正在等待配对确认'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
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
                const Icon(
                  Icons.bluetooth_connected,
                  color: ColorTheme.primaryColor,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  controller.pairingDeviceName.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '请在对方设备上确认配对',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
          const Spacer(),
          SecondaryButton(
            text: '取消配对',
            onPressed: controller.goBack,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPairedView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection('配对成功', '您的设备已成功配对'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorTheme.verified.withOpacity(0.1),
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
                const Icon(
                  Icons.check_circle_outline,
                  color: ColorTheme.verified,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  '已与 ${controller.pairingDeviceName.value} 配对',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '现在您可以开始记录同意过程',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            text: '开始记录',
            onPressed: controller.proceedToRecord,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExpiredView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection('配对已过期', '配对码已失效'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
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
              children: const [
                Icon(
                  Icons.timer_off,
                  color: ColorTheme.warning,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  '配对码已过期',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '请重新生成配对码或扫描设备',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            text: '重新生成配对码',
            onPressed: controller.generatePairingCode,
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            text: '扫描设备',
            onPressed: controller.startScanning,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: ColorTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPairingOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: ColorTheme.primaryColor,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: ColorTheme.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList() {
    return Obx(() {
      if (controller.devices.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '未发现设备',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.devices.length,
          itemBuilder: (context, index) {
            final device = controller.devices[index];
            return ListTile(
              leading: const Icon(Icons.bluetooth, color: ColorTheme.primaryColor),
              title: Text(
                device.name.isEmpty ? '未知设备' : device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('信号强度: ${device.rssi} dBm'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => controller.selectDevice(device),
            );
          },
        ),
      );
    });
  }

  Widget _buildPairingCodeDisplay(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: code.split('').map((char) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: ColorTheme.primaryLightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                char,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.primaryColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 