import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// 加密工具类
class CryptoUtils {
  /// 单例实例
  static final CryptoUtils _instance = CryptoUtils._internal();
  
  /// 全局UUID实例
  static final Uuid _uuid = const Uuid();
  
  /// 工厂构造函数
  factory CryptoUtils() => _instance;
  
  /// 私有构造函数
  CryptoUtils._internal();
  
  /// 计算MD5哈希
  String calculateMD5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
  
  /// 计算SHA-1哈希
  String calculateSHA1(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }
  
  /// 计算SHA-256哈希
  String calculateSHA256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
  
  /// 计算SHA-512哈希
  String calculateSHA512(String input) {
    return sha512.convert(utf8.encode(input)).toString();
  }
  
  /// 计算HMAC-SHA256
  String calculateHMAC(String input, String key) {
    final hmacKey = utf8.encode(key);
    final hmacData = utf8.encode(input);
    final hmac = Hmac(sha256, hmacKey);
    return hmac.convert(hmacData).toString();
  }
  
  /// 生成UUID
  String generateUUID() {
    return _uuid.v4();
  }
  
  /// 生成时间戳UUID
  String generateTimeBasedUUID() {
    return _uuid.v1();
  }
  
  /// Base64编码
  String encodeBase64(String input) {
    return base64.encode(utf8.encode(input));
  }
  
  /// Base64解码
  String decodeBase64(String input) {
    return utf8.decode(base64.decode(input));
  }
  
  /// Base64编码文件数据
  String encodeFileToBase64(Uint8List fileData) {
    return base64.encode(fileData);
  }
  
  /// Base64解码为文件数据
  Uint8List decodeBase64ToFile(String input) {
    return base64.decode(input);
  }
  
  /// 生成随机盐值
  String generateSalt({int length = 16}) {
    final values = List<int>.generate(length, (_) => _getRandomByte());
    return base64.encode(values);
  }
  
  /// 获取随机字节
  int _getRandomByte() {
    return _uuid.v4().codeUnitAt(0) % 256;
  }
  
  /// 使用盐值计算密码哈希
  String hashPasswordWithSalt(String password, String salt) {
    final combinedPassword = password + salt;
    return calculateSHA256(combinedPassword);
  }
  
  /// 验证哈希密码
  bool verifyPassword(String password, String salt, String hashedPassword) {
    final calculatedHash = hashPasswordWithSalt(password, salt);
    return calculatedHash == hashedPassword;
  }
  
  /// 生成安全的随机字符串
  String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[_getRandomByte() % chars.length]).join();
  }
} 