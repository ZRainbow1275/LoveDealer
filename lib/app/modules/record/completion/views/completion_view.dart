import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../../widgets/buttons/buttons.dart';
import '../../../../../widgets/indicators/indicators.dart';
import '../../../../theme/color_theme.dart';
import '../controllers/completion_controller.dart';
import '../../controllers/record_controller.dart';

class CompletionView extends GetView<CompletionController> {
  const CompletionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.goToHome();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('记录完成'),
          backgroundColor: ColorTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorTheme.primaryColor,
                      ),
                    );
                  }
                  
                  return _buildCompletionContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final recordController = Get.find<RecordController>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: StepIndicator(
        currentStep: recordController.currentStep.value,
        totalSteps: recordController.steps.length,
        stepTitles: recordController.steps.map((step) => step['title']!).toList(),
      ),
    );
  }

  Widget _buildCompletionContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSuccessAnimation(),
                const SizedBox(height: 24),
                _buildCompletionMessage(),
                const SizedBox(height: 32),
                _buildEvidenceList(),
                const SizedBox(height: 32),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: ColorTheme.verified.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),
        Lottie.asset(
          'assets/animations/success.json',
          repeat: false,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildCompletionMessage() {
    return Column(
      children: const [
        Text(
          '记录完成',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorTheme.verified,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '您已成功完成本次同意记录，记录已安全加密存储并生成哈希值用于验证',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ColorTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            '证据摘要',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildEvidenceItem(
            icon: Icons.mic,
            title: '口头同意',
            description: controller.record.value?.hasAudioRecord() == true 
                ? '口头同意已记录' 
                : '未录制口头同意',
            isCompleted: controller.record.value?.hasAudioRecord() == true,
          ),
          const SizedBox(height: 16),
          _buildEvidenceItem(
            icon: Icons.face,
            title: '人脸识别',
            description: controller.record.value?.hasFaceRecognition() == true 
                ? '已完成人脸识别' 
                : '未完成人脸识别',
            isCompleted: controller.record.value?.hasFaceRecognition() == true,
          ),
          const SizedBox(height: 16),
          _buildEvidenceItem(
            icon: Icons.camera_alt,
            title: '场景照片',
            description: controller.record.value?.hasPhotos() == true 
                ? '已拍摄 ${controller.record.value?.getPhotoCount() ?? 0} 张场景照片' 
                : '未拍摄场景照片',
            isCompleted: controller.record.value?.hasPhotos() == true,
          ),
          const SizedBox(height: 16),
          _buildEvidenceItem(
            icon: Icons.description,
            title: '同意陈述',
            description: controller.record.value?.consentStatement != null && controller.record.value!.consentStatement!.isNotEmpty 
                ? '已填写同意陈述' 
                : '未填写同意陈述',
            isCompleted: controller.record.value?.consentStatement != null && controller.record.value!.consentStatement!.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted 
            ? ColorTheme.verified.withOpacity(0.1) 
            : ColorTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? ColorTheme.verified 
                  : ColorTheme.warning,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted 
                        ? ColorTheme.verified.withOpacity(0.8) 
                        : ColorTheme.warning.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.warning,
            color: isCompleted ? ColorTheme.verified : ColorTheme.warning,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.security,
                  color: ColorTheme.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '安全信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.verified_user,
            text: '所有记录内容已通过加密处理并存储在本地设备中',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.lock,
            text: '您可以随时在"历史记录"中查看此记录',
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.fingerprint,
            text: '记录已生成唯一哈希值，可用于验证记录完整性',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: ColorTheme.info,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: '查看记录详情',
              onPressed: controller.viewRecordDetail,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              text: '返回首页',
              onPressed: controller.goToHome,
            ),
          ),
        ],
      ),
    );
  }
} 