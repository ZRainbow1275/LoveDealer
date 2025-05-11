import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../../../../widgets/buttons/buttons.dart';
import '../../../../../widgets/indicators/indicators.dart';
import '../../../../theme/color_theme.dart';
import '../controllers/face_recognition_controller.dart';
import '../../controllers/record_controller.dart';

class FaceRecognitionView extends GetView<FaceRecognitionController> {
  const FaceRecognitionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸识别'),
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
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: Obx(() {
                if (!controller.hasPermission.value) {
                  return _buildPermissionDeniedView();
                }
                
                if (!controller.isCameraInitialized.value) {
                  return _buildLoadingView();
                }
                
                return _buildCameraView();
              }),
            ),
          ],
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

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: ColorTheme.warning,
          ),
          const SizedBox(height: 16),
          const Text(
            '需要相机权限',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              '请允许应用访问相机，以便进行人脸识别',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ColorTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '去设置开启权限',
            onPressed: controller.openAppSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            color: ColorTheme.primaryColor,
          ),
          SizedBox(height: 16),
          Text('正在初始化相机...'),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusIndicator(),
          const SizedBox(height: 20),
          _buildPersonTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCameraPreview(),
          ),
          const SizedBox(height: 20),
          _buildRecognitionProgress(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: '拍摄照片',
              onPressed: controller.isCapturing.value 
                  ? null 
                  : controller.takePicture,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              text: '返回上一步',
              onPressed: controller.isCapturing.value 
                  ? null 
                  : controller.goBack,
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.face,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '人脸识别',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.isFrontCameraSelected.value
                      ? '请将面部置于圈内，保持表情自然'
                      : '请切换到前置摄像头进行人脸识别',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonTabs() {
    final recordController = Get.find<RecordController>();
    
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.isUserTab.value 
                      ? ColorTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '我自己',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: controller.isUserTab.value 
                        ? Colors.white 
                        : ColorTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setIsUserTab(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !controller.isUserTab.value 
                        ? ColorTheme.primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    recordController.partnerName.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: !controller.isUserTab.value 
                          ? Colors.white 
                          : ColorTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCameraPreview() {
    final recordController = Get.find<RecordController>();
    
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // 相机预览
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.black,
            child: Obx(() {
              if (!controller.isCameraInitialized.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              
              return CameraPreview(controller.cameraController!);
            }),
          ),
        ),
        
        // 录制指示器
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'REC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 人脸识别指导覆盖层
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorTheme.primaryColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        
        // 用户提示
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Text(
              controller.isUserTab.value
                  ? '您的脸部' 
                  : '${recordController.partnerName.value}的脸部',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ),
        
        // 加载中覆盖层
        if (controller.isCapturing.value)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '正在处理...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // 相机切换按钮
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: controller.isCapturing.value 
                ? null 
                : controller.toggleCamera,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecognitionProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '人脸识别进度',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: ColorTheme.background,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Obx(() => Container(
              height: 6,
              width: controller.recognitionProgress.value * Get.width,
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ],
        ),
      ],
    );
  }
} 