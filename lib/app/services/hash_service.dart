import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import '../data/models/history_record.dart';
import '../data/models/hash_verification.dart';
import '../data/models/personal_info.dart';

/// 哈希服务，用于处理数据的哈希计算和验证
class HashService extends GetxService {
  /// 计算字符串的SHA-256哈希值
  String calculateSHA256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 计算文件的SHA-256哈希值
  Future<String> calculateFileSHA256(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 计算个人信息的哈希值
  String calculatePersonalInfoHash(PersonalInfo info) {
    final Map<String, dynamic> hashData = {
      'id': info.id,
      'name': info.name,
      'idNumber': info.idNumber,
      'phoneNumber': info.phoneNumber,
      'email': info.email,
    };
    
    final jsonString = jsonEncode(hashData);
    return calculateSHA256(jsonString);
  }
  
  /// 计算记录的组件哈希值
  Future<Map<String, String>> calculateRecordComponentHashes(
    HistoryRecord record,
    PersonalInfo personalInfo,
  ) async {
    final Map<String, String> componentHashes = {};
    
    // 个人信息哈希
    componentHashes[HashVerification.COMPONENT_PERSONAL_INFO] = 
      calculatePersonalInfoHash(personalInfo);
    
    // 伴侣信息哈希
    componentHashes[HashVerification.COMPONENT_PARTNER_INFO] = 
      calculateSHA256(record.partnerName + (record.partnerDeviceId ?? ''));
    
    // 同意陈述哈希
    if (record.consentStatement != null && record.consentStatement!.isNotEmpty) {
      componentHashes[HashVerification.COMPONENT_STATEMENT] = 
        calculateSHA256(record.consentStatement!);
    }
    
    // 录音哈希
    if (record.audioRecordPath != null && record.audioRecordPath!.isNotEmpty) {
      try {
        componentHashes[HashVerification.COMPONENT_AUDIO] = 
          await calculateFileSHA256(record.audioRecordPath!);
      } catch (e) {
        print('Error calculating audio hash: $e');
      }
    }
    
    // 人脸识别哈希
    if (record.faceRecognitionPath != null && record.faceRecognitionPath!.isNotEmpty) {
      try {
        componentHashes[HashVerification.COMPONENT_FACE] = 
          await calculateFileSHA256(record.faceRecognitionPath!);
      } catch (e) {
        print('Error calculating face recognition hash: $e');
      }
    }
    
    // 照片哈希（使用所有照片哈希的组合）
    if (record.photosPaths != null && record.photosPaths!.isNotEmpty) {
      final List<String> photoHashes = [];
      
      for (var photoPath in record.photosPaths!) {
        try {
          final hash = await calculateFileSHA256(photoPath);
          photoHashes.add(hash);
        } catch (e) {
          print('Error calculating photo hash: $e');
        }
      }
      
      if (photoHashes.isNotEmpty) {
        componentHashes[HashVerification.COMPONENT_PHOTOS] = 
          calculateSHA256(photoHashes.join());
      }
    }
    
    // 位置哈希
    if (record.location != null && record.location!.isNotEmpty) {
      componentHashes[HashVerification.COMPONENT_LOCATION] = 
        calculateSHA256(record.location!);
    }
    
    // 时间戳哈希
    componentHashes[HashVerification.COMPONENT_TIMESTAMP] = 
      calculateSHA256(record.createdAt.toIso8601String());
    
    return componentHashes;
  }
  
  /// 计算记录的主哈希值（从组件哈希计算）
  String calculateMasterHash(Map<String, String> componentHashes) {
    final sortedKeys = componentHashes.keys.toList()..sort();
    final List<String> sortedHashes = [];
    
    for (var key in sortedKeys) {
      sortedHashes.add(componentHashes[key]!);
    }
    
    final combinedHash = sortedHashes.join();
    return calculateSHA256(combinedHash);
  }
  
  /// 为记录创建完整的哈希验证
  Future<HashVerification> createHashVerification(
    HistoryRecord record,
    PersonalInfo personalInfo,
  ) async {
    final componentHashes = await calculateRecordComponentHashes(record, personalInfo);
    final masterHash = calculateMasterHash(componentHashes);
    
    return HashVerification(
      recordId: record.id,
      masterHash: masterHash,
      componentHashes: componentHashes,
    );
  }
  
  /// 验证记录的哈希是否匹配
  Future<bool> verifyRecordHash(
    HistoryRecord record,
    PersonalInfo personalInfo,
    HashVerification verification,
  ) async {
    final currentComponentHashes = 
      await calculateRecordComponentHashes(record, personalInfo);
    final currentMasterHash = calculateMasterHash(currentComponentHashes);
    
    return verification.masterHash == currentMasterHash;
  }
  
  /// 验证特定组件的哈希是否匹配
  Future<bool> verifyComponentHash(
    String component,
    String data,
    HashVerification verification,
  ) async {
    final storedHash = verification.getComponentHash(component);
    if (storedHash == null) return false;
    
    final currentHash = calculateSHA256(data);
    return storedHash == currentHash;
  }
  
  /// 验证文件组件的哈希是否匹配
  Future<bool> verifyFileComponentHash(
    String component,
    String filePath,
    HashVerification verification,
  ) async {
    final storedHash = verification.getComponentHash(component);
    if (storedHash == null) return false;
    
    try {
      final currentHash = await calculateFileSHA256(filePath);
      return storedHash == currentHash;
    } catch (e) {
      print('Error verifying file hash: $e');
      return false;
    }
  }
} 