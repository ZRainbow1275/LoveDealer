import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../../widgets/indicators/indicators.dart';
import '../../../theme/color_theme.dart';
import '../controllers/record_controller.dart';

class RecordView extends GetView<RecordController> {
  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('记录 - ${controller.steps[controller.currentStep.value]["title"]}')),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.cancelRecord,
          color: ColorTheme.textSecondary,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: _buildCurrentStepContent(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: StepIndicator(
        currentStep: controller.currentStep.value,
        totalSteps: controller.steps.length,
        stepTitles: controller.steps.map((step) => step['title']!).toList(),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildConsentStatementStep();
      default:
        return _buildLoadingStep();
    }
  }

  Widget _buildConsentStatementStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusIndicator(),
          const SizedBox(height: 24),
          _buildPartnerInfoCard(),
          const SizedBox(height: 24),
          _buildConsentStatementSection(),
          const SizedBox(height: 24),
          _buildAudioRecorder(),
          const SizedBox(height: 24),
          _buildLocationInfo(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: '继续',
              onPressed: controller.nextStep,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              text: '返回上一步',
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '同意陈述录入',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '请填写同意陈述并录制声音确认，这将作为有效证据',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerInfoCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '配对信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person,
                color: ColorTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                '配对对象：',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                controller.partnerName.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.smartphone,
                color: ColorTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                '设备ID：',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.partnerDeviceId.value.isEmpty
                      ? '未知'
                      : controller.partnerDeviceId.value.substring(0, 8) + '...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsentStatementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '同意陈述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '请输入双方对于此次亲密行为的同意陈述，将作为书面证据。',
          style: TextStyle(
            fontSize: 14,
            color: ColorTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.consentStatementController,
            decoration: const InputDecoration(
              hintText: '请输入同意陈述，例如：我们双方同意进行亲密行为...',
              border: InputBorder.none,
              isDense: true,
            ),
            maxLines: 6,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 15,
              color: ColorTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildConsentExample(),
      ],
    );
  }

  Widget _buildConsentExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorTheme.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '示例：',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: ColorTheme.info,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '我们双方（姓名）在此确认，我们同意在完全知情、理解和自愿的情况下进行亲密行为。我们确认我们都具有法律能力，没有受到胁迫或欺诈。',
            style: TextStyle(
              fontSize: 13,
              color: ColorTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRecorder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '口头确认',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '请双方口头表达对同意陈述的确认，录音将作为声音证据。',
          style: TextStyle(
            fontSize: 14,
            color: ColorTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTheme.primaryColor,
              width: 1,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            final isRecording = controller.isRecording.value;
            
            return Row(
              children: [
                GestureDetector(
                  onTap: isRecording 
                      ? controller.stopRecording 
                      : controller.startRecording,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isRecording 
                          ? Colors.red 
                          : ColorTheme.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? Colors.red : ColorTheme.primaryColor)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRecording ? '录音中...' : '点击开始录音',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isRecording ? Colors.red : ColorTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRecording 
                            ? '已录制 ${controller.recordingDuration.value}' 
                            : controller.hasRecording.value 
                                ? '录音已完成 (${controller.recordingDuration.value})' 
                                : '请念出同意陈述',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.hasRecording.value && !isRecording)
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: ColorTheme.primaryColor,
                    ),
                    onPressed: controller.isPlaying.value 
                        ? controller.stopPlaying 
                        : controller.playRecording,
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '位置信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: ColorTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentLocation.value.isEmpty
                          ? '未获取位置'
                          : controller.currentLocation.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateTime.now().toString().substring(0, 19),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
} 