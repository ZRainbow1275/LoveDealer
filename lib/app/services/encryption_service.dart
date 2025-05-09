import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// 加密服务
/// 
/// 负责数据加密和解密，以及密钥管理
class EncryptionService extends GetxService {
  static EncryptionService get to => Get.find<EncryptionService>();
  
  // 安全存储
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // 密钥存储键名
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _encryptionIvKey = 'encryption_iv';
  
  // 加密器和解密器
  encrypt.Encrypter? _encrypter;
  encrypt.IV? _iv;
  
  @override
  void onInit() {
    super.onInit();
    _initEncryption();
  }
  
  /// 初始化加密服务
  Future<void> _initEncryption() async {
    try {
      // 尝试从安全存储中获取密钥
      String? keyString = await _secureStorage.read(key: _encryptionKeyKey);
      String? ivString = await _secureStorage.read(key: _encryptionIvKey);
      
      if (keyString == null || ivString == null) {
        // 如果密钥不存在，生成新密钥
        await _generateAndStoreKeys();
        
        // 重新读取生成的密钥
        keyString = await _secureStorage.read(key: _encryptionKeyKey);
        ivString = await _secureStorage.read(key: _encryptionIvKey);
        
        if (keyString == null || ivString == null) {
          throw Exception('无法生成或读取加密密钥');
        }
      }
      
      // 初始化加密器
      final key = encrypt.Key.fromBase64(keyString);
      _iv = encrypt.IV.fromBase64(ivString);
      _encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    } catch (e) {
      debugPrint('初始化加密服务失败: $e');
    }
  }
  
  /// 生成并存储新密钥
  Future<void> _generateAndStoreKeys() async {
    try {
      // 生成随机密钥
      final key = encrypt.Key.fromSecureRandom(32); // 256位密钥
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // 存储密钥
      await _secureStorage.write(key: _encryptionKeyKey, value: key.base64);
      await _secureStorage.write(key: _encryptionIvKey, value: iv.base64);
    } catch (e) {
      debugPrint('生成密钥失败: $e');
      rethrow;
    }
  }
  
  /// 重置密钥（谨慎使用，会导致无法解密之前加密的数据）
  Future<void> resetKeys() async {
    try {
      await _secureStorage.delete(key: _encryptionKeyKey);
      await _secureStorage.delete(key: _encryptionIvKey);
      await _initEncryption();
    } catch (e) {
      debugPrint('重置密钥失败: $e');
    }
  }
  
  /// 加密字符串
  String? encryptString(String plainText) {
    if (_encrypter == null || _iv == null) {
      debugPrint('加密服务未初始化');
      return null;
    }
    
    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      debugPrint('加密字符串失败: $e');
      return null;
    }
  }
  
  /// 解密字符串
  String? decryptString(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      debugPrint('加密服务未初始化');
      return null;
    }
    
    try {
      final decrypted = _encrypter!.decrypt64(encryptedText, iv: _iv!);
      return decrypted;
    } catch (e) {
      debugPrint('解密字符串失败: $e');
      return null;
    }
  }
  
  /// 加密json对象
  String? encryptJson(Map<String, dynamic> json) {
    return encryptString(jsonEncode(json));
  }
  
  /// 解密json对象
  Map<String, dynamic>? decryptJson(String encryptedText) {
    final decrypted = decryptString(encryptedText);
    if (decrypted == null) {
      return null;
    }
    
    try {
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('解析JSON失败: $e');
      return null;
    }
  }
  
  /// 为密码生成盐值
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
  
  /// 使用盐值对密码进行哈希
  String hashPassword(String password, String salt) {
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);
    
    // 合并密码和盐值
    final combined = Uint8List(passwordBytes.length + saltBytes.length);
    combined.setRange(0, passwordBytes.length, passwordBytes);
    combined.setRange(passwordBytes.length, combined.length, saltBytes);
    
    // 计算SHA-256哈希
    final digest = sha256.convert(combined);
    return digest.toString();
  }
  
  /// 验证密码
  bool verifyPassword(String password, String salt, String hashedPassword) {
    final computedHash = hashPassword(password, salt);
    return computedHash == hashedPassword;
  }
  
  /// 生成随机密码
  String generateRandomPassword(int length) {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// 检查加密服务是否已初始化
  bool get isInitialized => _encrypter != null && _iv != null;
} 