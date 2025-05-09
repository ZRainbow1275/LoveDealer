import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/history_record.dart';
import '../data/models/pairing_info.dart';
import 'encryption_service.dart';
import 'hash_service.dart';
import 'storage_service.dart';

/// 记录管理服务
/// 
/// 负责历史记录的存储、检索和管理
class RecordService extends GetxService {
  static RecordService get to => Get.find<RecordService>();
  
  // 依赖服务
  final StorageService _storageService = StorageService.to;
  final HashService _hashService = HashService.to;
  final EncryptionService _encryptionService = EncryptionService.to;
  
  // 历史记录列表
  final RxList<HistoryRecord> historyRecords = <HistoryRecord>[].obs;
  
  // 当前在编辑或查看的记录
  final Rx<HistoryRecord?> currentRecord = Rx<HistoryRecord?>(null);
  
  // 记录文件夹路径
  String? _recordsFolderPath;
  
  @override
  void onInit() {
    super.onInit();
    _initRecordFolder();
    _loadHistoryRecords();
  }
  
  /// 初始化记录文件夹
  Future<void> _initRecordFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _recordsFolderPath = '${directory.path}/records';
      
      // 确保目录存在
      await Directory(_recordsFolderPath!).create(recursive: true);
    } catch (e) {
      debugPrint('初始化记录文件夹失败: $e');
    }
  }
  
  /// 加载历史记录列表
  Future<void> _loadHistoryRecords() async {
    try {
      final records = await _storageService.getHistoryRecords();
      if (records != null) {
        historyRecords.assignAll(records);
      }
    } catch (e) {
      debugPrint('加载历史记录失败: $e');
    }
  }
  
  /// 创建新记录
  Future<HistoryRecord> createNewRecord({
    required String partnerName,
    required PairingInfo pairingInfo,
    String? statement,
    String? audioPath,
    List<String>? photoPaths,
    List<String>? facePaths,
  }) async {
    if (_recordsFolderPath == null) {
      await _initRecordFolder();
    }
    
    // 创建记录文件夹
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();
    final recordFolderPath = '$_recordsFolderPath/$recordId';
    await Directory(recordFolderPath).create(recursive: true);
    
    // 创建记录对象
    final record = HistoryRecord(
      id: recordId,
      timestamp: DateTime.now(),
      partnerName: partnerName,
      partnerDeviceId: pairingInfo.deviceId,
      statement: statement ?? '我与${partnerName}在充分知情、理性，且完全自愿的情况下同意发生性关系。',
      location: '未知位置', // 实际应用中应从LocationService获取
      audioFilePath: audioPath,
      photoFilePaths: photoPaths ?? [],
      faceImagePaths: facePaths ?? [],
      pairingInfo: pairingInfo,
      verificationStatus: VerificationStatus.verified,
    );
    
    // 复制文件到记录文件夹
    record.audioFilePath = await _copyFileToRecord(audioPath, recordFolderPath, 'audio');
    record.photoFilePaths = await _copyFilesToRecord(photoPaths, recordFolderPath, 'photos');
    record.faceImagePaths = await _copyFilesToRecord(facePaths, recordFolderPath, 'faces');
    
    // 计算记录哈希值
    await _computeRecordHash(record);
    
    // 保存记录
    await _saveRecord(record);
    
    return record;
  }
  
  /// 复制单个文件到记录文件夹
  Future<String?> _copyFileToRecord(String? filePath, String recordFolderPath, String subfolder) async {
    if (filePath == null || filePath.isEmpty) {
      return null;
    }
    
    try {
      // 创建子文件夹
      final targetFolder = '$recordFolderPath/$subfolder';
      await Directory(targetFolder).create(recursive: true);
      
      // 复制文件
      final fileName = filePath.split('/').last;
      final targetPath = '$targetFolder/$fileName';
      
      await File(filePath).copy(targetPath);
      
      return targetPath;
    } catch (e) {
      debugPrint('复制文件失败: $e');
      return filePath; // 失败时返回原路径
    }
  }
  
  /// 复制多个文件到记录文件夹
  Future<List<String>> _copyFilesToRecord(List<String>? filePaths, String recordFolderPath, String subfolder) async {
    if (filePaths == null || filePaths.isEmpty) {
      return [];
    }
    
    final result = <String>[];
    
    for (final filePath in filePaths) {
      final targetPath = await _copyFileToRecord(filePath, recordFolderPath, subfolder);
      if (targetPath != null) {
        result.add(targetPath);
      }
    }
    
    return result;
  }
  
  /// 计算记录哈希值
  Future<void> _computeRecordHash(HistoryRecord record) async {
    try {
      // 计算记录数据哈希值
      final recordData = jsonEncode(record.toJson());
      record.dataHash = await _hashService.computeStringHash(recordData);
      
      // 计算音频文件哈希值
      if (record.audioFilePath != null) {
        record.audioHash = await _hashService.computeFileHash(record.audioFilePath!);
      }
      
      // 计算照片哈希值
      for (final photoPath in record.photoFilePaths) {
        final hash = await _hashService.computeFileHash(photoPath);
        record.photoHashes[photoPath] = hash;
      }
      
      // 计算人脸图像哈希值
      for (final facePath in record.faceImagePaths) {
        final hash = await _hashService.computeFileHash(facePath);
        record.faceHashes[facePath] = hash;
      }
      
      // 计算总哈希值
      final allHashes = [
        record.dataHash ?? '',
        record.audioHash ?? '',
        ...record.photoHashes.values,
        ...record.faceHashes.values,
      ].join();
      
      record.masterHash = await _hashService.computeStringHash(allHashes);
    } catch (e) {
      debugPrint('计算记录哈希值失败: $e');
    }
  }
  
  /// 保存记录
  Future<void> _saveRecord(HistoryRecord record) async {
    try {
      // 先将记录加密
      final recordJson = record.toJson();
      final encryptedData = _encryptionService.encryptJson(recordJson);
      
      if (encryptedData == null) {
        throw Exception('加密记录数据失败');
      }
      
      // 保存加密数据到文件
      if (_recordsFolderPath != null) {
        final dataFilePath = '$_recordsFolderPath/${record.id}_data.enc';
        await File(dataFilePath).writeAsString(encryptedData);
      }
      
      // 添加到历史记录列表
      final index = historyRecords.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        historyRecords[index] = record;
      } else {
        historyRecords.add(record);
      }
      
      // 排序历史记录（按时间降序）
      historyRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // 保存历史记录列表
      await _storageService.saveHistoryRecords(historyRecords);
    } catch (e) {
      debugPrint('保存记录失败: $e');
    }
  }
  
  /// 获取记录详情
  Future<HistoryRecord?> getRecordDetail(String recordId) async {
    try {
      // 先从历史记录列表中查找
      final record = historyRecords.firstWhereOrNull((r) => r.id == recordId);
      if (record != null) {
        currentRecord.value = record;
        return record;
      }
      
      // 如果没找到，尝试从文件加载
      if (_recordsFolderPath != null) {
        final dataFilePath = '$_recordsFolderPath/${recordId}_data.enc';
        if (await File(dataFilePath).exists()) {
          final encryptedData = await File(dataFilePath).readAsString();
          final recordJson = _encryptionService.decryptJson(encryptedData);
          
          if (recordJson != null) {
            final loadedRecord = HistoryRecord.fromJson(recordJson);
            currentRecord.value = loadedRecord;
            return loadedRecord;
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('获取记录详情失败: $e');
      return null;
    }
  }
  
  /// 验证记录完整性
  Future<bool> verifyRecordIntegrity(HistoryRecord record) async {
    try {
      // 验证数据哈希值
      if (record.dataHash != null) {
        final recordData = jsonEncode(record.toJson());
        final computedHash = await _hashService.computeStringHash(recordData);
        if (computedHash != record.dataHash) {
          return false;
        }
      }
      
      // 验证音频哈希值
      if (record.audioFilePath != null && record.audioHash != null) {
        final computedHash = await _hashService.computeFileHash(record.audioFilePath!);
        if (computedHash != record.audioHash) {
          return false;
        }
      }
      
      // 验证照片哈希值
      for (final entry in record.photoHashes.entries) {
        final photoPath = entry.key;
        final savedHash = entry.value;
        final computedHash = await _hashService.computeFileHash(photoPath);
        if (computedHash != savedHash) {
          return false;
        }
      }
      
      // 验证人脸图像哈希值
      for (final entry in record.faceHashes.entries) {
        final facePath = entry.key;
        final savedHash = entry.value;
        final computedHash = await _hashService.computeFileHash(facePath);
        if (computedHash != savedHash) {
          return false;
        }
      }
      
      // 验证总哈希值
      if (record.masterHash != null) {
        final allHashes = [
          record.dataHash ?? '',
          record.audioHash ?? '',
          ...record.photoHashes.values,
          ...record.faceHashes.values,
        ].join();
        
        final computedMasterHash = await _hashService.computeStringHash(allHashes);
        if (computedMasterHash != record.masterHash) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('验证记录完整性失败: $e');
      return false;
    }
  }
  
  /// 搜索历史记录
  List<HistoryRecord> searchHistoryRecords(String keyword) {
    if (keyword.isEmpty) {
      return historyRecords;
    }
    
    final lowercaseKeyword = keyword.toLowerCase();
    return historyRecords.where((record) {
      return record.partnerName.toLowerCase().contains(lowercaseKeyword) ||
             record.id.toLowerCase().contains(lowercaseKeyword) ||
             record.timestamp.toString().contains(lowercaseKeyword) ||
             record.location.toLowerCase().contains(lowercaseKeyword);
    }).toList();
  }
  
  /// 删除记录
  Future<bool> deleteRecord(String recordId) async {
    try {
      // 从列表中移除记录
      final index = historyRecords.indexWhere((r) => r.id == recordId);
      if (index >= 0) {
        final record = historyRecords.removeAt(index);
        
        // 删除记录文件
        if (_recordsFolderPath != null) {
          // 删除加密数据文件
          final dataFilePath = '$_recordsFolderPath/${recordId}_data.enc';
          if (await File(dataFilePath).exists()) {
            await File(dataFilePath).delete();
          }
          
          // 删除记录文件夹
          final recordFolderPath = '$_recordsFolderPath/$recordId';
          if (await Directory(recordFolderPath).exists()) {
            await Directory(recordFolderPath).delete(recursive: true);
          }
        }
        
        // 保存历史记录列表
        await _storageService.saveHistoryRecords(historyRecords);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('删除记录失败: $e');
      return false;
    }
  }
  
  /// 获取记录数量
  int get recordCount => historyRecords.length;
  
  /// 检查记录是否存在
  bool recordExists(String recordId) {
    return historyRecords.any((r) => r.id == recordId);
  }
} 