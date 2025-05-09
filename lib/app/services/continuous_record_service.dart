import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'audio_service.dart';
import 'bluetooth_service.dart';
import 'camera_service.dart';
import 'hash_service.dart';
import 'location_service.dart';

/// 持续记录服务
/// 
/// 负责在后台持续进行录音、定期拍照和监控蓝牙连接状态
class ContinuousRecordService extends GetxService {
  static ContinuousRecordService get to => Get.find<ContinuousRecordService>();
  
  // 依赖服务
  final AudioService _audioService = AudioService.to;
  final CameraService _cameraService = CameraService.to;
  final BluetoothService _bluetoothService = BluetoothService.to;
  final LocationService _locationService = LocationService.to;
  final HashService _hashService = HashService.to;
  
  // 服务状态
  final RxBool isRunning = false.obs;
  
  // 录音文件路径
  final RxString recordingFilePath = ''.obs;
  
  // 照片列表
  final RxList<String> photosList = <String>[].obs;
  
  // 开始时间
  final Rx<DateTime?> startTime = Rx<DateTime?>(null);
  
  // 定时器
  Timer? _photoTimer;
  Timer? _connectionCheckTimer;
  
  // 监控频率配置
  final Duration _photoInterval = const Duration(minutes: 5);
  final Duration _connectionCheckInterval = const Duration(seconds: 30);
  
  // 服务数据存储路径
  String? _serviceFolderPath;
  
  @override
  void onInit() {
    super.onInit();
    _initServiceFolder();
  }
  
  @override
  void onClose() {
    stopService();
    super.onClose();
  }
  
  /// 初始化服务数据存储文件夹
  Future<void> _initServiceFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _serviceFolderPath = '${directory.path}/continuous_record';
      
      // 确保目录存在
      await Directory(_serviceFolderPath!).create(recursive: true);
    } catch (e) {
      debugPrint('初始化服务文件夹失败: $e');
    }
  }
  
  /// 启动持续记录服务
  Future<bool> startService() async {
    if (isRunning.value) {
      return true;
    }
    
    try {
      // 创建记录会话文件夹
      final sessionFolderPath = await _createSessionFolder();
      if (sessionFolderPath == null) {
        return false;
      }
      
      // 开始录音
      final audioFilePath = '$sessionFolderPath/continuous_audio.aac';
      final audioStarted = await _audioService.startRecording(filePath: audioFilePath);
      if (!audioStarted) {
        return false;
      }
      
      recordingFilePath.value = audioFilePath;
      
      // 启动位置更新
      await _locationService.startLocationUpdates();
      
      // 拍摄第一张照片
      await _takePhoto(sessionFolderPath);
      
      // 设置定时拍照
      _photoTimer = Timer.periodic(_photoInterval, (_) {
        _takePhoto(sessionFolderPath);
      });
      
      // 设置定时检查蓝牙连接
      _connectionCheckTimer = Timer.periodic(_connectionCheckInterval, (_) {
        _checkBluetoothConnection();
      });
      
      // 更新服务状态
      isRunning.value = true;
      startTime.value = DateTime.now();
      
      return true;
    } catch (e) {
      debugPrint('启动持续记录服务失败: $e');
      await stopService();
      return false;
    }
  }
  
  /// 停止持续记录服务
  Future<void> stopService() async {
    if (!isRunning.value) {
      return;
    }
    
    try {
      // 停止定时器
      _photoTimer?.cancel();
      _photoTimer = null;
      
      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;
      
      // 停止录音
      await _audioService.stopRecording();
      
      // 更新服务状态
      isRunning.value = false;
      startTime.value = null;
    } catch (e) {
      debugPrint('停止持续记录服务失败: $e');
    }
  }
  
  /// 创建会话文件夹
  Future<String?> _createSessionFolder() async {
    if (_serviceFolderPath == null) {
      await _initServiceFolder();
      if (_serviceFolderPath == null) {
        return null;
      }
    }
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sessionFolderPath = '$_serviceFolderPath/session_$timestamp';
      
      await Directory(sessionFolderPath).create(recursive: true);
      return sessionFolderPath;
    } catch (e) {
      debugPrint('创建会话文件夹失败: $e');
      return null;
    }
  }
  
  /// 拍摄照片
  Future<void> _takePhoto(String sessionFolderPath) async {
    try {
      // 确保相机已初始化
      if (!_cameraService.isInitialized.value || _cameraService.controller.value == null) {
        return;
      }
      
      // 拍摄照片
      final photoPath = await _cameraService.takePicture();
      if (photoPath == null) {
        return;
      }
      
      // 复制照片到会话文件夹
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPhotoPath = '$sessionFolderPath/photo_$timestamp.jpg';
      
      final photoFile = File(photoPath);
      final newFile = await photoFile.copy(newPhotoPath);
      
      // 添加到照片列表
      photosList.add(newFile.path);
      
      // 删除原始文件（如果不在同一位置）
      if (photoPath != newPhotoPath) {
        await photoFile.delete();
      }
      
      // 计算照片哈希值
      await _hashService.computeFileHash(newFile.path);
    } catch (e) {
      debugPrint('拍摄照片失败: $e');
    }
  }
  
  /// 检查蓝牙连接状态
  Future<void> _checkBluetoothConnection() async {
    if (!_bluetoothService.isConnected.value && isRunning.value) {
      // 如果蓝牙断开连接，记录日志
      debugPrint('蓝牙连接已断开');
      
      // 可选：在这里添加断开连接的处理逻辑
      // 例如，在日志中记录断开时间，或者停止服务
    }
  }
  
  /// 获取服务运行时长（秒）
  int getRunningDuration() {
    if (!isRunning.value || startTime.value == null) {
      return 0;
    }
    
    final now = DateTime.now();
    return now.difference(startTime.value!).inSeconds;
  }
  
  /// 获取格式化的运行时长
  String getFormattedRunningDuration() {
    final duration = getRunningDuration();
    final hours = (duration ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((duration % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    
    return '$hours:$minutes:$seconds';
  }
} 