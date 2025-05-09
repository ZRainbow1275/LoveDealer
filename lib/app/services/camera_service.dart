import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 相机服务
/// 
/// 负责相机初始化、拍照和照片管理
class CameraService extends GetxService {
  static CameraService get to => Get.find<CameraService>();
  
  // 可用相机列表
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  
  // 当前相机控制器
  Rx<CameraController?> controller = Rx<CameraController?>(null);
  
  // 相机初始化状态
  final RxBool isInitialized = false.obs;
  
  // 闪光灯模式
  final Rx<FlashMode> flashMode = FlashMode.auto.obs;
  
  // 前后摄像头
  final Rx<CameraLensDirection> lensDirection = CameraLensDirection.back.obs;
  
  // 已拍照片列表
  final RxList<String> capturedPhotos = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initCameras();
  }
  
  @override
  void onClose() {
    controller.value?.dispose();
    super.onClose();
  }
  
  /// 初始化相机
  Future<void> _initCameras() async {
    try {
      cameras.value = await availableCameras();
      if (cameras.isNotEmpty) {
        await selectCamera(lensDirection.value);
      }
    } catch (e) {
      debugPrint('初始化相机失败: $e');
    }
  }
  
  /// 选择相机
  Future<void> selectCamera(CameraLensDirection direction) async {
    lensDirection.value = direction;
    
    if (cameras.isEmpty) {
      return;
    }
    
    // 查找指定方向的相机
    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == direction,
      orElse: () => cameras.first,
    );
    
    // 释放旧控制器
    await controller.value?.dispose();
    
    // 创建新控制器
    final newController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    controller.value = newController;
    
    // 初始化新控制器
    try {
      await newController.initialize();
      isInitialized.value = true;
      
      // 设置闪光灯模式
      await newController.setFlashMode(flashMode.value);
    } catch (e) {
      isInitialized.value = false;
      debugPrint('初始化相机控制器失败: $e');
    }
  }
  
  /// 切换前后摄像头
  Future<void> toggleCameraDirection() async {
    final newDirection = lensDirection.value == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    
    await selectCamera(newDirection);
  }
  
  /// 切换闪光灯模式
  Future<void> toggleFlashMode() async {
    final modes = [
      FlashMode.auto,
      FlashMode.off,
      FlashMode.always,
    ];
    
    final currentIndex = modes.indexOf(flashMode.value);
    final nextIndex = (currentIndex + 1) % modes.length;
    flashMode.value = modes[nextIndex];
    
    if (isInitialized.value && controller.value != null) {
      await controller.value!.setFlashMode(flashMode.value);
    }
  }
  
  /// 拍照
  Future<String?> takePicture() async {
    if (!isInitialized.value || controller.value == null) {
      return null;
    }
    
    try {
      // 拍照
      final XFile picture = await controller.value!.takePicture();
      
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final photoDir = '${directory.path}/photos';
      
      // 确保目录存在
      await Directory(photoDir).create(recursive: true);
      
      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_$timestamp.jpg';
      final filePath = '$photoDir/$fileName';
      
      // 复制文件
      final savedFile = await File(picture.path).copy(filePath);
      
      // 添加到照片列表
      capturedPhotos.add(savedFile.path);
      
      return savedFile.path;
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }
  
  /// 删除照片
  Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        capturedPhotos.remove(photoPath);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除照片失败: $e');
      return false;
    }
  }
  
  /// 清除所有照片
  Future<void> clearAllPhotos() async {
    try {
      for (final photoPath in capturedPhotos) {
        await deletePhoto(photoPath);
      }
      capturedPhotos.clear();
    } catch (e) {
      debugPrint('清除所有照片失败: $e');
    }
  }
  
  /// 获取相机预览小部件
  Widget getCameraPreview() {
    if (!isInitialized.value || controller.value == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return CameraPreview(controller.value!);
  }
} 