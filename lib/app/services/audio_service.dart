import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 录音服务状态
enum AudioServiceStatus {
  /// 未初始化
  uninitialized,
  
  /// 已初始化
  initialized,
  
  /// 正在录音
  recording,
  
  /// 已暂停
  paused,
  
  /// 已停止
  stopped,
}

/// 录音服务
/// 
/// 负责音频录制和管理
class AudioService extends GetxService {
  static AudioService get to => Get.find<AudioService>();
  
  // 录音设备
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  // 录音服务状态
  final Rx<AudioServiceStatus> status = AudioServiceStatus.uninitialized.obs;
  
  // 当前录音文件路径
  final RxString currentFilePath = ''.obs;
  
  // 录音计时器
  final RxInt recordingDuration = 0.obs;
  
  // 录音振幅
  final RxDouble amplitude = 0.0.obs;
  
  // 计时器
  Timer? _timer;
  
  // 振幅监听器
  StreamSubscription? _amplitudeSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initRecorder();
  }
  
  @override
  void onClose() {
    _stopTimer();
    _stopAmplitudeListener();
    _recorder.closeRecorder();
    super.onClose();
  }
  
  /// 初始化录音设备
  Future<void> _initRecorder() async {
    try {
      await _recorder.openRecorder();
      status.value = AudioServiceStatus.initialized;
    } catch (e) {
      debugPrint('初始化录音设备失败: $e');
    }
  }
  
  /// 开始录音
  Future<bool> startRecording({String? filePath}) async {
    if (status.value == AudioServiceStatus.recording) {
      return true;
    }
    
    // 检查权限
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      return false;
    }
    
    try {
      // 如果未指定文件路径，则生成一个临时文件路径
      if (filePath == null) {
        filePath = await _generateFilePath();
      }
      
      currentFilePath.value = filePath;
      
      // 开始录音
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      
      status.value = AudioServiceStatus.recording;
      
      // 启动计时器
      _startTimer();
      
      // 启动振幅监听
      _startAmplitudeListener();
      
      return true;
    } catch (e) {
      debugPrint('开始录音失败: $e');
      return false;
    }
  }
  
  /// 暂停录音
  Future<bool> pauseRecording() async {
    if (status.value != AudioServiceStatus.recording) {
      return false;
    }
    
    try {
      await _recorder.pauseRecorder();
      status.value = AudioServiceStatus.paused;
      
      // 暂停计时器
      _stopTimer();
      
      // 暂停振幅监听
      _stopAmplitudeListener();
      
      return true;
    } catch (e) {
      debugPrint('暂停录音失败: $e');
      return false;
    }
  }
  
  /// 恢复录音
  Future<bool> resumeRecording() async {
    if (status.value != AudioServiceStatus.paused) {
      return false;
    }
    
    try {
      await _recorder.resumeRecorder();
      status.value = AudioServiceStatus.recording;
      
      // 恢复计时器
      _startTimer();
      
      // 恢复振幅监听
      _startAmplitudeListener();
      
      return true;
    } catch (e) {
      debugPrint('恢复录音失败: $e');
      return false;
    }
  }
  
  /// 停止录音
  Future<String?> stopRecording() async {
    if (status.value != AudioServiceStatus.recording && 
        status.value != AudioServiceStatus.paused) {
      return null;
    }
    
    try {
      final result = await _recorder.stopRecorder();
      status.value = AudioServiceStatus.stopped;
      
      // 停止计时器
      _stopTimer();
      
      // 停止振幅监听
      _stopAmplitudeListener();
      
      // 重置计时器
      recordingDuration.value = 0;
      
      return result;
    } catch (e) {
      debugPrint('停止录音失败: $e');
      return null;
    }
  }
  
  /// 检查录音权限
  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    
    final result = await Permission.microphone.request();
    return result.isGranted;
  }
  
  /// 生成录音文件路径
  Future<String> _generateFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = '${directory.path}/audio';
    
    // 确保目录存在
    await Directory(audioDir).create(recursive: true);
    
    // 生成文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$audioDir/recording_$timestamp.aac';
  }
  
  /// 启动计时器
  void _startTimer() {
    _stopTimer();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value++;
    });
  }
  
  /// 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// 启动振幅监听
  void _startAmplitudeListener() {
    _stopAmplitudeListener();
    
    _amplitudeSubscription = _recorder.onProgress?.listen((event) {
      if (event.decibels != null) {
        // 转换分贝值到0-1范围的振幅值
        // 通常，分贝值范围在-160到0之间，0是最大声音
        final db = event.decibels ?? -160.0;
        final normalizedDb = (db + 160.0) / 160.0; // 归一化到0-1
        amplitude.value = normalizedDb.clamp(0.0, 1.0);
      }
    });
  }
  
  /// 停止振幅监听
  void _stopAmplitudeListener() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    amplitude.value = 0.0;
  }
  
  /// 删除录音文件
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除录音文件失败: $e');
      return false;
    }
  }
  
  /// 是否正在录音
  bool get isRecording => status.value == AudioServiceStatus.recording;
  
  /// 是否已暂停
  bool get isPaused => status.value == AudioServiceStatus.paused;
  
  /// 获取格式化的录音时长
  String get formattedDuration {
    final duration = recordingDuration.value;
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
} 