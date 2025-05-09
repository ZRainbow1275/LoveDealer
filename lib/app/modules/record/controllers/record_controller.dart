import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/history_record.dart';
import '../../../data/models/pairing_info.dart';
import '../../../routes/app_pages.dart';
import '../../../services/bluetooth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/location_service.dart';
import '../../../services/hash_service.dart';
import '../../../utils/logger.dart';

class RecordController extends GetxController {
  // 服务
  final BluetoothService _bluetoothService = Get.find<BluetoothService>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationService _locationService = Get.find<LocationService>();
  final HashService _hashService = Get.find<HashService>();
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
    {
      'title': '同意录入',
      'description': '录制双方的同意陈述',
    },
    {
      'title': '人脸识别',
      'description': '进行面部识别以验证身份',
    },
    {
      'title': '拍照记录',
      'description': '拍摄照片作为辅助证据',
    },
    {
      'title': '完成记录',
      'description': '确认并存储记录',
    },
  ];
  
  @override
  void onInit() {
    super.onInit();
    _initRecorder();
    _initRecord();
  }
  
  @override
  void onClose() {
    consentStatementController.dispose();
    _connectionCheckTimer?.cancel();
    _recordingTimer?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.onClose();
  }
  
  // 初始化录音器
  Future<void> _initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        Get.snackbar('错误', '需要麦克风权限才能继续', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      await _recorder.openRecorder();
      await _player.openPlayer();
      
      _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
      _player.setSubscriptionDuration(const Duration(milliseconds: 500));
    } catch (e) {
      _logger.e('初始化录音器失败', error: e);
      Get.snackbar('错误', '初始化录音器失败', snackPosition: SnackPosition.BOTTOM);
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
  
  // 初始化记录
  Future<void> _initRecord() async {
    isLoading.value = true;
    try {
      // 获取配对信息
      final pairingInfos = await _storageService.getAllPairingInfo();
      final activePairing = pairingInfos.where((p) => p.status == PairingStatus.PAIRED).toList();
      
      if (activePairing.isEmpty) {
        Get.snackbar('错误', '未找到有效的配对信息', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        return;
      }
      
      final pairing = activePairing.first;
      
      // 获取位置信息
      String locationStr = '';
      try {
        final location = await _locationService.getCurrentLocation();
        if (location != null) {
          locationStr = '${location.latitude}, ${location.longitude}';
          final address = await _locationService.getAddressFromCoordinates(
            location.latitude, 
            location.longitude
          );
          if (address.isNotEmpty) {
            locationStr = address;
          }
        }
      } catch (e) {
        _logger.e('获取位置信息失败', error: e);
      }
      
      // 设置状态变量
      partnerName.value = pairing.partnerDeviceName ?? '未知设备';
      partnerDeviceId.value = pairing.partnerDeviceId ?? '';
      currentLocation.value = locationStr;
      
      // 创建新的历史记录
      final newRecord = HistoryRecord(
        partnerName: partnerName.value,
        partnerDeviceId: partnerDeviceId.value,
        location: currentLocation.value,
        createdAt: DateTime.now(),
        status: RecordStatus.CREATED,
      );
      
      await _storageService.saveHistoryRecord(newRecord);
      recordId.value = newRecord.id;
      
      // 启动连接检查定时器
      _startConnectionCheck();
    } catch (e) {
      _logger.e('初始化记录失败', error: e);
      Get.snackbar('错误', '初始化记录失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // 启动连接检查
  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (partnerDeviceId.value.isEmpty) return;
      
      final isConnected = await _bluetoothService.isDeviceConnected(partnerDeviceId.value);
      if (!isConnected) {
        _connectionCheckTimer?.cancel();
        Get.dialog(
          AlertDialog(
            title: const Text('连接断开'),
            content: const Text('与配对设备的连接已断开，请重新配对后继续记录'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // 关闭对话框
                  Get.back(); // 返回上一页
                },
                child: const Text('确定'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    });
  }
  
  // 保存同意陈述
  Future<void> saveConsentStatement() async {
    if (consentStatementController.text.isEmpty) {
      Get.snackbar('提示', '请输入同意陈述', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (!hasRecording.value || audioFilePath.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('确认'),
          content: const Text('您尚未录制声音确认，是否继续？录音可以增加证据的可靠性。'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('返回录制'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _saveAndContinue();
              },
              child: const Text('继续'),
            ),
          ],
        ),
      );
      return;
    }
    
    _saveAndContinue();
  }
  
  // 保存并继续
  Future<void> _saveAndContinue() async {
    try {
      final record = await _storageService.getHistoryRecordById(recordId.value);
      if (record == null) {
        throw Exception('未找到记录');
      }
      
      final updatedRecord = record.copyWith(
        consentStatement: consentStatementController.text,
        audioRecordPath: audioFilePath.value,
        status: RecordStatus.STATEMENT_RECORDED,
      );
      
      await _storageService.saveHistoryRecord(updatedRecord);
      
      recordStatus.value = RecordStatus.STATEMENT_RECORDED;
      currentStep.value = 1; // 进入下一步
      
      Get.toNamed(Routes.FACE_RECOGNITION, arguments: {'recordId': recordId.value});
    } catch (e) {
      _logger.e('保存同意陈述失败', error: e);
      Get.snackbar('错误', '保存同意陈述失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 处理人脸识别结果
  Future<void> processFaceRecognitionResult(String faceImagePath) async {
    try {
      final record = await _storageService.getHistoryRecordById(recordId.value);
      if (record == null) {
        throw Exception('未找到记录');
      }
      
      final updatedRecord = record.copyWith(
        faceRecognitionPath: faceImagePath,
        status: RecordStatus.FACE_RECOGNIZED,
      );
      
      await _storageService.saveHistoryRecord(updatedRecord);
      
      recordStatus.value = RecordStatus.FACE_RECOGNIZED;
      currentStep.value = 2; // 进入下一步
      
      Get.toNamed(Routes.PHOTO_CAPTURE, arguments: {'recordId': recordId.value});
    } catch (e) {
      _logger.e('处理人脸识别结果失败', error: e);
      Get.snackbar('错误', '处理人脸识别结果失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 处理照片拍摄结果
  Future<void> processPhotoCaptureResult(List<String> photosPaths) async {
    try {
      final record = await _storageService.getHistoryRecordById(recordId.value);
      if (record == null) {
        throw Exception('未找到记录');
      }
      
      final updatedRecord = record.copyWith(
        photosPaths: photosPaths,
        status: RecordStatus.PHOTOS_CAPTURED,
      );
      
      await _storageService.saveHistoryRecord(updatedRecord);
      
      recordStatus.value = RecordStatus.PHOTOS_CAPTURED;
      currentStep.value = 3; // 进入下一步
      
      // 计算记录的哈希值
      final recordData = updatedRecord.toJson();
      final hashValue = await _hashService.calculateHash(recordData.toString());
      
      final completedRecord = updatedRecord.copyWith(
        isCompleted: true,
        hashValue: hashValue,
        status: RecordStatus.COMPLETED,
      );
      
      await _storageService.saveHistoryRecord(completedRecord);
      
      recordStatus.value = RecordStatus.COMPLETED;
      
      Get.toNamed(Routes.COMPLETION, arguments: {'recordId': recordId.value});
    } catch (e) {
      _logger.e('处理照片拍摄结果失败', error: e);
      Get.snackbar('错误', '处理照片拍摄结果失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  // 完成记录流程
  void completeRecordProcess() {
    Get.offAllNamed(Routes.HOME);
  }
  
  // 取消记录
  Future<void> cancelRecord() async {
    Get.dialog(
      AlertDialog(
        title: const Text('取消记录'),
        content: const Text('确定要取消当前记录吗？已录入的信息将会丢失。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('继续记录'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // 关闭对话框
              
              try {
                // 删除当前记录
                if (recordId.value.isNotEmpty) {
                  await _storageService.deleteHistoryRecord(recordId.value);
                }
                
                Get.offAllNamed(Routes.HOME);
              } catch (e) {
                _logger.e('取消记录失败', error: e);
                Get.snackbar('错误', '取消记录失败', snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('确认取消'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
} 