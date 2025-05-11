import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../../../../widgets/buttons/buttons.dart';
import '../../../../../widgets/indicators/indicators.dart';
import '../../../../theme/color_theme.dart';
import '../controllers/photo_capture_controller.dart';
import '../../controllers/record_controller.dart';

class PhotoCaptureView extends GetView<PhotoCaptureController> {
  const PhotoCaptureView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照记录'),
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
                
                return _buildMainContent();
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
            Icons.camera_alt,
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
              '请允许应用访问相机，以便进行场景拍摄',
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
        children: [
          const CircularProgressIndicator(
            color: ColorTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text('正在初始化相机...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.capturedPhotos.isEmpty) {
        return _buildCameraView();
      } else {
        return _buildGalleryView();
      }
    });
  }
  
  Widget _buildCameraView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildStatusIndicator(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildCameraPreview(),
        ),
        _buildCameraControls(),
      ],
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
              Icons.camera_alt,
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
                  '场景拍摄',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '请拍摄${controller.minPhotos}到${controller.maxPhotos}张照片记录当前场景',
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
    );
  }
  
  Widget _buildCameraPreview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black,
              child: controller.isCameraInitialized.value
                  ? CameraPreview(controller.cameraController!)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          // 闪光灯控制
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: controller.toggleFlash,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Obx(() => Icon(
                  controller.flashEnabled.value
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                  size: 24,
                )),
              ),
            ),
          ),
          
          // 拍照提示
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '点击按钮拍摄照片',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 相机控制
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 切换相机按钮
                GestureDetector(
                  onTap: controller.toggleCamera,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // 拍照按钮
                GestureDetector(
                  onTap: controller.isCapturing.value 
                      ? null 
                      : controller.takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: controller.isCapturing.value 
                              ? Colors.grey 
                              : ColorTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // 已拍摄照片预览按钮
                GestureDetector(
                  onTap: () => controller.capturedPhotos.isNotEmpty 
                      ? controller.toggleGalleryView() 
                      : null,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraControls() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '已拍摄 ${controller.capturedPhotos.length} 张，${controller.isEnoughPhotos.value ? '可完成' : '至少需要 ${controller.minPhotos} 张'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                ),
              ),
              if (controller.capturedPhotos.isNotEmpty)
                TextButton.icon(
                  onPressed: controller.toggleGalleryView,
                  icon: const Icon(
                    Icons.photo_library,
                    size: 18,
                    color: ColorTheme.primaryColor,
                  ),
                  label: const Text(
                    '查看',
                    style: TextStyle(
                      color: ColorTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: '完成拍摄',
              onPressed: controller.isEnoughPhotos.value && !controller.isCapturing.value
                  ? controller.completePhotoCapture
                  : null,
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
  
  Widget _buildGalleryView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '已拍摄照片',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                ),
              ),
              OutlinedButton.icon(
                onPressed: controller.toggleGalleryView,
                icon: const Icon(Icons.camera_alt),
                label: const Text('继续拍摄'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: controller.capturedPhotos.isNotEmpty
                            ? Image.file(
                                File(controller.capturedPhotos[controller.currentPhotoIndex.value]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('暂无照片'),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: controller.previousPhoto,
                          color: ColorTheme.primaryColor,
                        ),
                        Text(
                          '${controller.currentPhotoIndex.value + 1} / ${controller.capturedPhotos.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: controller.nextPhoto,
                          color: ColorTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
                
                // 删除按钮
                if (controller.capturedPhotos.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: controller.deleteCurrentPhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: '完成拍摄',
              onPressed: controller.isEnoughPhotos.value
                  ? controller.completePhotoCapture
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              text: '返回上一步',
              onPressed: controller.goBack,
            ),
          ),
        ],
      ),
    );
  }
} 