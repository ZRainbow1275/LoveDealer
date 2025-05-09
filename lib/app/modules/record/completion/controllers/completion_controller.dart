import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/models/history_record.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/storage_service.dart';
import '../../../../utils/logger.dart';

class CompletionController extends GetxController {
  // 服务
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();
  
  // 状态变量
  final RxBool isLoading = true.obs;
  final Rx<HistoryRecord?> record = Rx<HistoryRecord?>(null);
  final RxString recordId = ''.obs;
  final RxString sharePath = ''.obs;
  final RxBool isGeneratingShareData = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    recordId.value = Get.arguments['recordId'] ?? '';
    if (recordId.isEmpty) {
      Get.offAllNamed(Routes.HOME);
      return;
    }
    _loadRecord();
  }
  
  // 加载记录
  Future<void> _loadRecord() async {
    isLoading.value = true;
    try {
      final historyRecord = await _storageService.getHistoryRecordById(recordId.value);
      if (historyRecord == null) {
        Get.snackbar('错误', '未找到记录', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(Routes.HOME);
        return;
      }
      
      record.value = historyRecord;
    } catch (e) {
      _logger.e('加载记录失败', error: e);
      Get.snackbar('错误', '加载记录失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // 生成分享数据
  Future<void> generateShareData() async {
    if (record.value == null) return;
    
    try {
      isGeneratingShareData.value = true;
      
      // 创建临时目录
      final directory = await getTemporaryDirectory();
      final shareDir = Directory('${directory.path}/share');
      
      if (await shareDir.exists()) {
        await shareDir.delete(recursive: true);
      }
      await shareDir.create();
      
      // 创建分享信息文本文件
      final infoText = _generateShareText();
      final infoFile = File('${shareDir.path}/记录信息.txt');
      await infoFile.writeAsString(infoText);
      
      // 复制人脸识别照片
      if (record.value!.faceRecognitionPath != null && record.value!.faceRecognitionPath!.isNotEmpty) {
        final faceFile = File(record.value!.faceRecognitionPath!);
        if (await faceFile.exists()) {
          await faceFile.copy('${shareDir.path}/人脸识别.jpg');
        }
      }
      
      // 复制场景照片
      if (record.value!.photosPaths != null && record.value!.photosPaths!.isNotEmpty) {
        for (int i = 0; i < record.value!.photosPaths!.length; i++) {
          final photoFile = File(record.value!.photosPaths![i]);
          if (await photoFile.exists()) {
            await photoFile.copy('${shareDir.path}/场景照片_${i+1}.jpg');
          }
        }
      }
      
      sharePath.value = shareDir.path;
      
      // 分享文件
      await Share.shareXFiles(
        [(await infoFile.create()).path].map((path) => XFile(path)).toList(),
        text: '记录分享',
      );
    } catch (e) {
      _logger.e('生成分享数据失败', error: e);
      Get.snackbar('错误', '生成分享数据失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGeneratingShareData.value = false;
    }
  }
  
  // 生成分享文本
  String _generateShareText() {
    if (record.value == null) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('====== 记录同意证明 ======');
    buffer.writeln();
    buffer.writeln('记录ID: ${record.value!.id}');
    buffer.writeln('创建时间: ${record.value!.createdAt.toString()}');
    buffer.writeln('地点: ${record.value!.location}');
    buffer.writeln('状态: ${_getStatusText(record.value!.status)}');
    buffer.writeln();
    
    if (record.value!.consentStatement != null && record.value!.consentStatement!.isNotEmpty) {
      buffer.writeln('同意陈述:');
      buffer.writeln(record.value!.consentStatement);
      buffer.writeln();
    }
    
    if (record.value!.hashValue != null && record.value!.hashValue!.isNotEmpty) {
      buffer.writeln('数据哈希值:');
      buffer.writeln(record.value!.hashValue);
      buffer.writeln();
    }
    
    buffer.writeln('此记录已通过加密验证，请勿篡改。');
    
    return buffer.toString();
  }
  
  // 获取状态文本
  String _getStatusText(RecordStatus? status) {
    switch (status) {
      case RecordStatus.CREATED:
        return '已创建';
      case RecordStatus.STATEMENT_RECORDED:
        return '已录制陈述';
      case RecordStatus.FACE_RECOGNIZED:
        return '已人脸识别';
      case RecordStatus.PHOTOS_CAPTURED:
        return '已拍摄照片';
      case RecordStatus.COMPLETED:
        return '已完成';
      default:
        return '未知';
    }
  }
  
  // 查看记录详情
  void viewRecordDetail() {
    Get.offNamed(Routes.DETAIL, arguments: {'recordId': recordId.value});
  }
  
  // 返回首页
  void goToHome() {
    Get.offAllNamed(Routes.HOME);
  }
} 