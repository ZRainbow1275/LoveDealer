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

class PhotoCaptureController extends GetxController {
  // 服务
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();
  
  // 相机控制
  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isFrontCameraSelected = false.obs;  // 默认使用后置相机
  final RxBool hasPermission = false.obs;
  final RxBool flashEnabled = false.obs;
  
  // 记录ID和照片路径
  late final String recordId;
  final RxList<String> capturedPhotos = <String>[].obs;
  final RxInt currentPhotoIndex = 0.obs;
  
  // 照片计数
  final int minPhotos = 1;
  final int maxPhotos = 5;
  final RxBool isEnoughPhotos = false.obs;
  
  // 视图控制
  final RxBool isGalleryView = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    recordId = Get.arguments['recordId'] ?? '';
    if (recordId.isEmpty) {
      Get.back();
      return;
    }
    _checkPermission();
    
    // 监听照片数量变化
    ever(capturedPhotos, (_) {
      isEnoughPhotos.value = capturedPhotos.length >= minPhotos;
    });
  }
  
  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
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
      
      // 默认使用后置相机
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
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
        flashMode: flashEnabled.value ? FlashMode.torch : FlashMode.off,
      );
      
      await cameraController!.initialize();
    } catch (e) {
      _logger.e('切换相机失败', error: e);
      Get.snackbar('错误', '切换相机失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 切换闪光灯
  Future<void> toggleFlash() async {
    if (cameraController == null || !isCameraInitialized.value) return;
    
    try {
      flashEnabled.value = !flashEnabled.value;
      
      if (flashEnabled.value) {
        await cameraController!.setFlashMode(FlashMode.torch);
      } else {
        await cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      _logger.e('切换闪光灯失败', error: e);
      Get.snackbar('错误', '切换闪光灯失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 切换图库视图
  void toggleGalleryView() {
    isGalleryView.value = !isGalleryView.value;
  }
  
  // 拍摄照片
  Future<void> takePicture() async {
    if (cameraController == null || !isCameraInitialized.value || isCapturing.value) return;
    
    try {
      isCapturing.value = true;
      
      final XFile photo = await cameraController!.takePicture();
      
      // 保存照片到应用目录
      final directory = await getApplicationDocumentsDirectory();
      final recordDirectory = Directory('${directory.path}/records/$recordId');
      
      if (!await recordDirectory.exists()) {
        await recordDirectory.create(recursive: true);
      }
      
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${recordDirectory.path}/$fileName';
      
      await File(photo.path).copy(filePath);
      
      capturedPhotos.add(filePath);
      currentPhotoIndex.value = capturedPhotos.length - 1;
      
      Get.snackbar('成功', '照片已保存', snackPosition: SnackPosition.BOTTOM);
      
      // 如果拍摄了照片，自动切换到图库视图
      if (capturedPhotos.length == 1) {
        isGalleryView.value = true;
      }
    } catch (e) {
      _logger.e('拍摄照片失败', error: e);
      Get.snackbar('错误', '拍摄照片失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCapturing.value = false;
    }
  }
  
  // 删除照片
  void deleteCurrentPhoto() {
    if (capturedPhotos.isEmpty || currentPhotoIndex.value < 0 || currentPhotoIndex.value >= capturedPhotos.length) {
      return;
    }
    
    try {
      final filePath = capturedPhotos[currentPhotoIndex.value];
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      
      capturedPhotos.removeAt(currentPhotoIndex.value);
      
      if (capturedPhotos.isEmpty) {
        currentPhotoIndex.value = 0;
        isGalleryView.value = false; // 如果删除了所有照片，切换回相机视图
      } else if (currentPhotoIndex.value >= capturedPhotos.length) {
        currentPhotoIndex.value = capturedPhotos.length - 1;
      }
      
      Get.snackbar('成功', '照片已删除', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _logger.e('删除照片失败', error: e);
      Get.snackbar('错误', '删除照片失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 查看上一张照片
  void previousPhoto() {
    if (capturedPhotos.isEmpty) return;
    
    if (currentPhotoIndex.value > 0) {
      currentPhotoIndex.value--;
    } else {
      currentPhotoIndex.value = capturedPhotos.length - 1;
    }
  }
  
  // 查看下一张照片
  void nextPhoto() {
    if (capturedPhotos.isEmpty) return;
    
    if (currentPhotoIndex.value < capturedPhotos.length - 1) {
      currentPhotoIndex.value++;
    } else {
      currentPhotoIndex.value = 0;
    }
  }
  
  // 完成拍照，继续记录流程
  Future<void> completePhotoCapture() async {
    if (capturedPhotos.isEmpty) {
      Get.snackbar('提示', '请至少拍摄一张照片', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      final recordController = Get.find<dynamic>(tag: 'RecordController');
      await recordController.processPhotoCaptureResult(capturedPhotos);
    } catch (e) {
      _logger.e('完成拍照失败', error: e);
      Get.snackbar('错误', '完成拍照失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 返回上一页
  void goBack() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认返回'),
        content: const Text('返回将丢失已拍摄的照片，确定要返回吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('确认返回'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
  
  // 显示权限被拒绝对话框
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('权限请求'),
        content: const Text('需要相机权限才能拍摄照片。请在设置中开启相机权限。'),
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