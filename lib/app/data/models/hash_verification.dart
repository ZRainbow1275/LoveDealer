import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'hash_verification.g.dart';

@HiveType(typeId: 5)
class HashVerification {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String recordId;
  
  @HiveField(2)
  final String masterHash;
  
  @HiveField(3)
  final Map<String, String> componentHashes;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime? lastVerifiedAt;
  
  @HiveField(6)
  final bool isValid;
  
  HashVerification({
    String? id,
    required this.recordId,
    required this.masterHash,
    required this.componentHashes,
    DateTime? createdAt,
    this.lastVerifiedAt,
    this.isValid = true,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  // 拷贝方法，用于更新验证信息
  HashVerification copyWith({
    String? recordId,
    String? masterHash,
    Map<String, String>? componentHashes,
    DateTime? lastVerifiedAt,
    bool? isValid,
  }) {
    return HashVerification(
      id: id,
      recordId: recordId ?? this.recordId,
      masterHash: masterHash ?? this.masterHash,
      componentHashes: componentHashes ?? this.componentHashes,
      createdAt: createdAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      isValid: isValid ?? this.isValid,
    );
  }
  
  // 添加一个组件哈希
  HashVerification addComponentHash(String component, String hash) {
    final newHashes = Map<String, String>.from(componentHashes);
    newHashes[component] = hash;
    
    return copyWith(componentHashes: newHashes);
  }
  
  // 更新验证状态
  HashVerification updateVerificationStatus(bool isValid) {
    return copyWith(
      isValid: isValid,
      lastVerifiedAt: DateTime.now(),
    );
  }
  
  // 获取组件哈希
  String? getComponentHash(String component) {
    return componentHashes[component];
  }
  
  // 从JSON转换
  factory HashVerification.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> hashesMap = json['componentHashes'] ?? {};
    final Map<String, String> hashes = {};
    
    hashesMap.forEach((key, value) {
      hashes[key] = value.toString();
    });
    
    return HashVerification(
      id: json['id'],
      recordId: json['recordId'],
      masterHash: json['masterHash'],
      componentHashes: hashes,
      createdAt: DateTime.parse(json['createdAt']),
      lastVerifiedAt: json['lastVerifiedAt'] != null 
        ? DateTime.parse(json['lastVerifiedAt']) 
        : null,
      isValid: json['isValid'] ?? true,
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordId': recordId,
      'masterHash': masterHash,
      'componentHashes': componentHashes,
      'createdAt': createdAt.toIso8601String(),
      'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
      'isValid': isValid,
    };
  }
  
  // 验证主哈希和组件哈希是否匹配
  bool verifyMasterHash(String calculatedMasterHash) {
    return masterHash == calculatedMasterHash;
  }
  
  // 验证特定组件哈希是否匹配
  bool verifyComponentHash(String component, String calculatedHash) {
    final storedHash = componentHashes[component];
    if (storedHash == null) return false;
    return storedHash == calculatedHash;
  }
  
  // 常用组件名称常量
  static const String COMPONENT_PERSONAL_INFO = 'personal_info';
  static const String COMPONENT_PARTNER_INFO = 'partner_info';
  static const String COMPONENT_STATEMENT = 'statement';
  static const String COMPONENT_AUDIO = 'audio';
  static const String COMPONENT_FACE = 'face';
  static const String COMPONENT_PHOTOS = 'photos';
  static const String COMPONENT_LOCATION = 'location';
  static const String COMPONENT_TIMESTAMP = 'timestamp';
} 