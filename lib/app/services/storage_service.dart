import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/personal_info.dart';
import '../data/models/history_record.dart';
import '../data/models/pairing_info.dart';
import '../data/models/hash_verification.dart';

/// 存储服务，用于管理应用数据的本地存储
class StorageService extends GetxService {
  static const String SECURE_STORAGE_KEY = 'record_app_encryption_key';
  static const String BOX_APP_SETTINGS = 'app_settings';
  static const String BOX_PERSONAL_INFO = 'personal_info';
  static const String BOX_HISTORY_RECORDS = 'history_records';
  static const String BOX_PAIRING_INFO = 'pairing_info';
  static const String BOX_HASH_VERIFICATION = 'hash_verification';
  
  late final FlutterSecureStorage _secureStorage;
  late final Box _settingsBox;
  late final Box _personalInfoBox;
  late final Box _historyRecordsBox;
  late final Box _pairingInfoBox;
  late final Box _hashVerificationBox;
  
  /// 初始化存储服务
  Future<StorageService> init() async {
    _secureStorage = const FlutterSecureStorage();
    
    // 注册适配器 - 暂时注释掉，稍后再实现
    /*
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PersonalInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecordStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PairingInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PairingStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(HashVerificationAdapter());
    }
    */
    
    // 获取加密密钥，如果不存在则创建
    String? encryptionKey = await _secureStorage.read(key: SECURE_STORAGE_KEY);
    if (encryptionKey == null) {
      final keyBytes = List<int>.generate(32, (i) => i % 255);
      encryptionKey = base64Encode(keyBytes);
      await _secureStorage.write(key: SECURE_STORAGE_KEY, value: encryptionKey);
    }
    
    final encryptionKeyBytes = base64Decode(encryptionKey);
    
    // 打开盒子 - 暂时使用普通的Box而不是类型化的Box
    _settingsBox = await Hive.openBox(BOX_APP_SETTINGS);
    
    /*
    _personalInfoBox = await Hive.openBox<PersonalInfo>(
      BOX_PERSONAL_INFO,
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
    _historyRecordsBox = await Hive.openBox<HistoryRecord>(
      BOX_HISTORY_RECORDS,
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
    _pairingInfoBox = await Hive.openBox<PairingInfo>(
      BOX_PAIRING_INFO,
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
    _hashVerificationBox = await Hive.openBox<HashVerification>(
      BOX_HASH_VERIFICATION,
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
    */
    
    // 暂时使用普通的Box
    _personalInfoBox = await Hive.openBox(BOX_PERSONAL_INFO);
    _historyRecordsBox = await Hive.openBox(BOX_HISTORY_RECORDS);
    _pairingInfoBox = await Hive.openBox(BOX_PAIRING_INFO);
    _hashVerificationBox = await Hive.openBox(BOX_HASH_VERIFICATION);
    
    return this;
  }
  
  //====== 应用设置管理 ======//
  
  /// 获取是否首次启动
  Future<bool> getIsFirstLaunch() async {
    return _settingsBox.get('isFirstLaunch', defaultValue: true);
  }
  
  /// 设置是否首次启动
  Future<void> setIsFirstLaunch(bool value) async {
    await _settingsBox.put('isFirstLaunch', value);
  }
  
  /// 获取是否已接受协议
  Future<bool> getAgreementAccepted() async {
    return _settingsBox.get('agreementAccepted', defaultValue: false);
  }
  
  /// 设置是否已接受协议
  Future<void> setAgreementAccepted(bool value) async {
    await _settingsBox.put('agreementAccepted', value);
  }
  
  /// 获取暗黑模式设置
  Future<bool> getDarkMode() async {
    return _settingsBox.get('darkMode', defaultValue: false);
  }
  
  /// 设置暗黑模式
  Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('darkMode', value);
  }
  
  //====== 个人信息管理 ======//
  
  /// 获取个人信息
  Future<PersonalInfo?> getPersonalInfo() async {
    if (_personalInfoBox.isEmpty) return null;
    return _personalInfoBox.getAt(0);
  }
  
  /// 设置个人信息
  Future<void> setPersonalInfo(PersonalInfo info) async {
    if (_personalInfoBox.isEmpty) {
      await _personalInfoBox.add(info);
    } else {
      await _personalInfoBox.putAt(0, info);
    }
  }
  
  //====== 历史记录管理 ======//
  
  /// 获取所有历史记录
  Future<List<HistoryRecord>> getAllHistoryRecords() async {
    return _historyRecordsBox.values.toList();
  }
  
  /// 根据ID获取历史记录
  Future<HistoryRecord?> getHistoryRecordById(String id) async {
    final records = _historyRecordsBox.values.where((record) => record.id == id);
    if (records.isEmpty) return null;
    return records.first;
  }
  
  /// 保存历史记录
  Future<void> saveHistoryRecord(HistoryRecord record) async {
    final recordToSave = record;
    final existingRecords = _historyRecordsBox.values.where((r) => r.id == record.id);
    
    if (existingRecords.isEmpty) {
      await _historyRecordsBox.add(recordToSave);
    } else {
      final index = _historyRecordsBox.values.toList().indexOf(existingRecords.first);
      await _historyRecordsBox.putAt(index, recordToSave);
    }
  }
  
  /// 删除历史记录
  Future<void> deleteHistoryRecord(String id) async {
    final records = _historyRecordsBox.values.where((record) => record.id == id);
    if (records.isEmpty) return;
    
    final index = _historyRecordsBox.values.toList().indexOf(records.first);
    await _historyRecordsBox.deleteAt(index);
  }
  
  /// 获取用于历史页面展示的所有历史记录
  Future<List<HistoryRecord>> getHistoryRecords() async {
    // 按时间倒序排列，最新的记录在前面
    final records = _historyRecordsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }
  
  /// 获取历史记录的分页数据
  Future<List<HistoryRecord>> getPaginatedHistoryRecords(int page, int pageSize) async {
    final records = await getHistoryRecords();
    
    final startIndex = page * pageSize;
    if (startIndex >= records.length) {
      return [];
    }
    
    final endIndex = (page + 1) * pageSize;
    final actualEndIndex = endIndex > records.length ? records.length : endIndex;
    
    return records.sublist(startIndex, actualEndIndex);
  }
  
  /// 搜索历史记录
  Future<List<HistoryRecord>> searchHistoryRecords(String query) async {
    if (query.isEmpty) {
      return getHistoryRecords();
    }
    
    final records = _historyRecordsBox.values.where((record) {
      final lowerQuery = query.toLowerCase();
      return record.partnerName.toLowerCase().contains(lowerQuery) ||
             (record.location?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return records;
  }
  
  //====== 配对信息管理 ======//
  
  /// 获取所有配对信息
  Future<List<PairingInfo>> getAllPairingInfo() async {
    return _pairingInfoBox.values.toList();
  }
  
  /// 根据ID获取配对信息
  Future<PairingInfo?> getPairingInfoById(String id) async {
    final pairings = _pairingInfoBox.values.where((pairing) => pairing.id == id);
    if (pairings.isEmpty) return null;
    return pairings.first;
  }
  
  /// 根据配对码获取配对信息
  Future<PairingInfo?> getPairingInfoByCode(String code) async {
    final pairings = _pairingInfoBox.values.where(
      (pairing) => pairing.pairingCode == code && !pairing.isExpired(),
    );
    if (pairings.isEmpty) return null;
    return pairings.first;
  }
  
  /// 保存配对信息
  Future<void> savePairingInfo(PairingInfo pairing) async {
    final pairingToSave = pairing;
    final existingPairings = _pairingInfoBox.values.where((p) => p.id == pairing.id);
    
    if (existingPairings.isEmpty) {
      await _pairingInfoBox.add(pairingToSave);
    } else {
      final index = _pairingInfoBox.values.toList().indexOf(existingPairings.first);
      await _pairingInfoBox.putAt(index, pairingToSave);
    }
  }
  
  /// 删除配对信息
  Future<void> deletePairingInfo(String id) async {
    final pairings = _pairingInfoBox.values.where((pairing) => pairing.id == id);
    if (pairings.isEmpty) return;
    
    final index = _pairingInfoBox.values.toList().indexOf(pairings.first);
    await _pairingInfoBox.deleteAt(index);
  }
  
  //====== 哈希验证管理 ======//
  
  /// 获取所有哈希验证
  Future<List<HashVerification>> getAllHashVerifications() async {
    return _hashVerificationBox.values.toList();
  }
  
  /// 根据记录ID获取哈希验证
  Future<HashVerification?> getHashVerificationByRecordId(String recordId) async {
    final verifications = _hashVerificationBox.values.where(
      (verification) => verification.recordId == recordId,
    );
    if (verifications.isEmpty) return null;
    return verifications.first;
  }
  
  /// 保存哈希验证
  Future<void> saveHashVerification(HashVerification verification) async {
    final verificationToSave = verification;
    final existingVerifications = _hashVerificationBox.values.where(
      (v) => v.id == verification.id,
    );
    
    if (existingVerifications.isEmpty) {
      await _hashVerificationBox.add(verificationToSave);
    } else {
      final index = _hashVerificationBox.values.toList().indexOf(existingVerifications.first);
      await _hashVerificationBox.putAt(index, verificationToSave);
    }
  }
  
  //====== 文件存储管理 ======//
  
  /// 获取应用文档目录
  Future<Directory> getAppDocDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// 获取临时目录
  Future<Directory> getAppTempDirectory() async {
    return await getTemporaryDirectory();
  }
  
  /// 保存文件
  Future<String> saveFile(File file, String fileName, String subDirectory) async {
    final appDocDir = await getAppDocDirectory();
    final dir = Directory('${appDocDir.path}/$subDirectory');
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final path = '${dir.path}/$fileName';
    await file.copy(path);
    
    return path;
  }
  
  /// 删除文件
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  //====== 数据清理 ======//
  
  /// 清除所有数据（用于开发测试）
  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _personalInfoBox.clear();
    await _historyRecordsBox.clear();
    await _pairingInfoBox.clear();
    await _hashVerificationBox.clear();
  }
  
  /// 检查用户是否已同意协议
  bool hasAgreedToTerms() {
    return _settingsBox.get('agreementAccepted', defaultValue: false);
  }
  
  /// 设置用户是否已同意协议
  Future<void> setAgreedToTerms(bool value) async {
    await _settingsBox.put('agreementAccepted', value);
  }
}