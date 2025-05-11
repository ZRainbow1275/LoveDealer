import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/history_record.dart';
import '../../../routes/app_pages.dart';
import '../../../services/bluetooth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/location_service.dart';
import '../../../utils/logger.dart';

class RecordController extends GetxController {
  // 服务
  final BluetoothService _bluetoothService = Get.find<BluetoothService>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationService _locationService = Get.find<LocationService>();
  final Logger _logger = Logger();
  
  // 状态变量
  final RxBool isLoading = true.obs;
  final RxString partnerName = ''.obs;
  final RxString partnerDeviceId = ''.obs;
  final RxString currentLocation = ''.obs;
  final RxString recordId = ''.obs;
  final RxInt currentStep = 0.obs;
  final Rx<RecordStatus> recordStatus = RecordStatus.CREATED.obs;
  
  // 文本控制器
  final TextEditingController consentStatementController = TextEditingController();
  
  // 录音功能
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final RxBool isRecording = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool hasRecording = false.obs;
  final RxString recordingDuration = '00:00'.obs;
  final RxString audioFilePath = ''.obs;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  // 定时器
  Timer? _connectionCheckTimer;
  
  // 步骤标题和描述
  final List<Map<String, String>> steps = [
    {'title': '同意录入', 'description': '录入双方同意的陈述'},
    {'title': '人脸识别', 'description': '通过人脸识别验证双方身份'},
    {'title': '拍照记录', 'description': '拍摄现场照片作为辅助证据'},
    {'title': '完成记录', 'description': '生成记录并加密存储'},
  ];

  @override
  void onInit() {
    super.onInit();
    _initRecord();
  }

  @override
  void onClose() {
    consentStatementController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    _recordingTimer?.cancel();
    _connectionCheckTimer?.cancel();
    super.onClose();
  }

  // 初始化记录
  Future<void> _initRecord() async {
    try {
      isLoading.value = true;
      
      // 检查是否来自配对页面
      final args = Get.arguments;
      if (args != null && args['partnerId'] != null && args['partnerName'] != null) {
        partnerDeviceId.value = args['partnerId'];
        partnerName.value = args['partnerName'];
      } else {
        // 如果没有配对信息，返回主页
        Get.back();
        return;
      }
      
      // 创建记录ID
      recordId.value = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 获取当前位置
      await _fetchCurrentLocation();
      
      // 初始化录音功能
      await _initRecorder();
      
      // 启动连接检查
      _startConnectionCheck();
      
      isLoading.value = false;
    } catch (e) {
      _logger.e('初始化记录失败', error: e);
      Get.snackbar('错误', '初始化记录失败', snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
    }
  }
  
  // 获取当前位置
  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && position.latitude != null && position.longitude != null) {
        final address = await _locationService.getAddressFromCoordinates(position.latitude!, position.longitude!);
        currentLocation.value = address;
      } else {
        currentLocation.value = '未知位置';
      }
    } catch (e) {
      _logger.e('获取位置失败', error: e);
      currentLocation.value = '未知位置';
    }
  }
  
  // 初始化录音器
  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _logger.e('麦克风权限被拒绝');
      return;
    }
    
    await _recorder.openRecorder();
    await _player.openPlayer();
  }
  
  // 启动连接检查
  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnection();
    });
  }
  
  // 检查连接
  Future<void> _checkConnection() async {
    try {
      final isConnected = await _bluetoothService.isDeviceConnected(partnerDeviceId.value);
      if (!isConnected) {
        Get.snackbar(
          '连接断开',
          '与伙伴设备的连接已断开，请重新配对',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          onTap: (_) {
            Get.back();
          },
        );
      }
    } catch (e) {
      _logger.e('检查连接失败', error: e);
    }
  }
  
  // 开始录音
  Future<void> startRecording() async {
    if (isRecording.value || isPlaying.value) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordDirectory = Directory('${directory.path}/records/$recordId');
      
      if (!await recordDirectory.exists()) {
        await recordDirectory.create(recursive: true);
      }
      
      final filePath = '${recordDirectory.path}/consent_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      audioFilePath.value = filePath;
      
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      
      isRecording.value = true;
      _recordingSeconds = 0;
      _updateRecordingDuration();
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingSeconds++;
        _updateRecordingDuration();
        
        // 限制录音时长为3分钟
        if (_recordingSeconds >= 180) {
          stopRecording();
        }
      });
    } catch (e) {
      _logger.e('开始录音失败', error: e);
      Get.snackbar('错误', '开始录音失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 停止录音
  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    
    try {
      _recordingTimer?.cancel();
      await _recorder.stopRecorder();
      isRecording.value = false;
      hasRecording.value = true;
    } catch (e) {
      _logger.e('停止录音失败', error: e);
      Get.snackbar('错误', '停止录音失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 播放录音
  Future<void> playRecording() async {
    if (isRecording.value || isPlaying.value || audioFilePath.isEmpty) return;
    
    try {
      await _player.startPlayer(
        fromURI: audioFilePath.value,
        codec: Codec.aacADTS,
        whenFinished: () {
          isPlaying.value = false;
        },
      );
      
      isPlaying.value = true;
    } catch (e) {
      _logger.e('播放录音失败', error: e);
      Get.snackbar('错误', '播放录音失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 停止播放
  Future<void> stopPlaying() async {
    if (!isPlaying.value) return;
    
    try {
      await _player.stopPlayer();
      isPlaying.value = false;
    } catch (e) {
      _logger.e('停止播放失败', error: e);
      Get.snackbar('错误', '停止播放失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 更新录音时长
  void _updateRecordingDuration() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
    recordingDuration.value = '$minutes:$seconds';
  }
  
  // 继续到下一步
  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      switch (currentStep.value) {
        case 1: // 人脸识别
          Get.toNamed(Routes.FACE_RECOGNITION, arguments: {'recordId': recordId.value});
          break;
        case 2: // 拍照记录
          Get.toNamed(Routes.PHOTO_CAPTURE, arguments: {'recordId': recordId.value});
          break;
        case 3: // 完成记录
          Get.toNamed(Routes.COMPLETION, arguments: {'recordId': recordId.value});
          break;
      }
    }
  }
  
  // 返回上一步
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  // 取消记录
  void cancelRecord() {
    Get.dialog(
      AlertDialog(
        title: const Text('取消记录'),
        content: const Text('确定要取消当前记录吗？所有数据将会丢失。'),
        actions: [
          TextButton(
            child: const Text('继续记录'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('取消记录'),
            onPressed: () {
              Get.back();
              Get.back();
            },
          ),
        ],
      ),
    );
  }
  
  // 前往人脸识别页面
  void goToFaceRecognition() {
    Get.toNamed(Routes.FACE_RECOGNITION, arguments: {'recordId': recordId.value});
  }
  
  // 保存记录
  Future<bool> saveRecord() async {
    try {
      final record = HistoryRecord(
        partnerName: partnerName.value,
        partnerDeviceId: partnerDeviceId.value,
        location: currentLocation.value,
        consentStatement: consentStatementController.text,
        status: RecordStatus.COMPLETED,
      );
      await _storageService.saveHistoryRecord(record);
      return true;
    } catch (e) {
      _logger.e('保存记录失败', error: e);
      return false;
    }
  }
} 