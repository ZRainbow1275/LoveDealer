import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../services/storage_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/logger.dart';

class FaceRecognitionController extends GetxController {
  // 服务
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();
  
  // 相机控制
  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isFrontCameraSelected = true.obs;
  final RxBool hasPermission = false.obs;
  final RxString imagePath = ''.obs;
  
  // 记录ID
  late final String recordId;
  
  // 人脸识别UI控制
  final RxBool isUserTab = true.obs;
  final RxDouble recognitionProgress = 0.0.obs;
  Timer? _progressTimer;
  
  @override
  void onInit() {
    super.onInit();
    recordId = Get.arguments['recordId'] ?? '';
    if (recordId.isEmpty) {
      Get.back();
      return;
    }
    _checkPermission();
    _startProgressSimulation();
  }
  
  @override
  void onClose() {
    cameraController?.dispose();
    _progressTimer?.cancel();
    super.onClose();
  }
  
  // 模拟人脸识别进度
  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (recognitionProgress.value < 0.7) {
        recognitionProgress.value += 0.01;
      } else {
        _progressTimer?.cancel();
      }
    });
  }
  
  // 设置是用户还是伙伴标签
  void setIsUserTab(bool value) {
    isUserTab.value = value;
    // 重置进度条
    recognitionProgress.value = 0.0;
    _startProgressSimulation();
  }
  
  // 检查相机权限
  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      hasPermission.value = true;
      _initializeCamera();
    } else {
      await _requestPermission();
    }
  }
  
  // 请求相机权限
  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      hasPermission.value = true;
      _initializeCamera();
    } else {
      _showPermissionDeniedDialog();
      hasPermission.value = false;
    }
  }
  
  // 打开应用设置
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  // 初始化相机
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('错误', '未找到可用的相机设备', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      // 默认使用前置相机
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await cameraController!.initialize();
      isCameraInitialized.value = true;
      // 初始化后设置闪光灯模式（默认关闭）
      await cameraController!.setFlashMode(FlashMode.off);
    } catch (e) {
      _logger.e('初始化相机失败', error: e);
      Get.snackbar('错误', '初始化相机失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 切换相机
  Future<void> toggleCamera() async {
    if (cameraController == null || !isCameraInitialized.value) return;
    
    try {
      final cameras = await availableCameras();
      if (cameras.length <= 1) return;
      
      final lensDirection = cameraController!.description.lensDirection;
      CameraDescription newCamera;
      
      if (lensDirection == CameraLensDirection.front) {
        newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        isFrontCameraSelected.value = false;
      } else {
        newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        isFrontCameraSelected.value = true;
      }
      
      await cameraController!.dispose();
      
      cameraController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await cameraController!.initialize();
      // 切换相机后设置闪光灯模式（默认关闭）
      await cameraController!.setFlashMode(FlashMode.off);
    } catch (e) {
      _logger.e('切换相机失败', error: e);
      Get.snackbar('错误', '切换相机失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 拍摄照片
  Future<void> takePicture() async {
    if (cameraController == null || !isCameraInitialized.value || isCapturing.value) return;
    
    if (!isFrontCameraSelected.value) {
      Get.snackbar('提示', '请使用前置摄像头进行人脸识别', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (recognitionProgress.value < 0.65) {
      Get.snackbar('提示', '请等待人脸识别完成', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      isCapturing.value = true;
      
      final XFile photo = await cameraController!.takePicture();
      
      // 保存照片到应用目录
      final directory = await getApplicationDocumentsDirectory();
      final recordDirectory = Directory('${directory.path}/records/$recordId');
      
      if (!await recordDirectory.exists()) {
        await recordDirectory.create(recursive: true);
      }
      
      final personType = isUserTab.value ? 'self' : 'partner';
      final fileName = 'face_${personType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${recordDirectory.path}/$fileName';
      
      await File(photo.path).copy(filePath);
      
      imagePath.value = filePath;
      
      Get.dialog(
        AlertDialog(
          title: Text(isUserTab.value ? '您的人脸照片' : '伙伴的人脸照片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(filePath),
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text('是否使用此照片？'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                imagePath.value = '';
                isCapturing.value = false;
              },
              child: const Text('重新拍摄'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _saveImageAndProceed();
              },
              child: const Text('确认使用'),
            ),
          ],
        ),
      );
    } catch (e) {
      _logger.e('拍摄照片失败', error: e);
      Get.snackbar('错误', '拍摄照片失败: $e', snackPosition: SnackPosition.BOTTOM);
      isCapturing.value = false;
    }
  }
  
  // 保存图片并继续流程
  Future<void> _saveImageAndProceed() async {
    if (imagePath.isEmpty) {
      isCapturing.value = false;
      return;
    }
    
    try {
      final recordController = Get.find<dynamic>(tag: 'RecordController');
      await recordController.processFaceRecognitionResult(imagePath.value);
    } catch (e) {
      _logger.e('保存人脸识别结果失败', error: e);
      Get.snackbar('错误', '保存人脸识别结果失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCapturing.value = false;
    }
  }
  
  // 返回上一页
  void goBack() {
    Get.back();
  }
  
  // 显示权限被拒绝对话框
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('权限请求'),
        content: const Text('需要相机权限才能进行人脸识别。请在设置中开启相机权限。'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              goBack();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
} 