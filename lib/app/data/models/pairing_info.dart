import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'pairing_info.g.dart';

@HiveType(typeId: 3)
class PairingInfo {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String deviceId;
  
  @HiveField(2)
  final String deviceName;
  
  @HiveField(3)
  final String? pairingCode;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime? expiresAt;
  
  @HiveField(6)
  final PairingStatus status;
  
  @HiveField(7)
  final String? recordId;
  
  PairingInfo({
    String? id,
    required this.deviceId,
    required this.deviceName,
    this.pairingCode,
    DateTime? createdAt,
    this.expiresAt,
    this.status = PairingStatus.PENDING,
    this.recordId,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  // 拷贝方法，用于更新配对信息
  PairingInfo copyWith({
    String? deviceId,
    String? deviceName,
    String? pairingCode,
    DateTime? expiresAt,
    PairingStatus? status,
    String? recordId,
  }) {
    return PairingInfo(
      id: id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      pairingCode: pairingCode ?? this.pairingCode,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      recordId: recordId ?? this.recordId,
    );
  }
  
  // 检查配对是否已过期
  bool isExpired() {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  // 检查配对是否处于激活状态
  bool isActive() {
    return status == PairingStatus.PAIRED && !isExpired();
  }
  
  // 生成新的配对码
  static String generatePairingCode() {
    // 生成6位数字配对码
    return (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
  }
  
  // 创建新的配对信息，带有生成的配对码
  static PairingInfo createWithCode({
    required String deviceId,
    required String deviceName,
    int expiresInMinutes = 10,
  }) {
    final code = generatePairingCode();
    final expiresAt = DateTime.now().add(Duration(minutes: expiresInMinutes));
    
    return PairingInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      pairingCode: code,
      expiresAt: expiresAt,
      status: PairingStatus.PENDING,
    );
  }
  
  // 从JSON转换
  factory PairingInfo.fromJson(Map<String, dynamic> json) {
    return PairingInfo(
      id: json['id'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      pairingCode: json['pairingCode'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt']) 
        : null,
      status: json['status'] != null 
        ? PairingStatusExtension.fromString(json['status']) 
        : PairingStatus.PENDING,
      recordId: json['recordId'],
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'pairingCode': pairingCode,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.toString(),
      'recordId': recordId,
    };
  }
}

@HiveType(typeId: 4)
enum PairingStatus {
  @HiveField(0)
  PENDING,
  
  @HiveField(1)
  PAIRED,
  
  @HiveField(2)
  DISCONNECTED,
  
  @HiveField(3)
  EXPIRED,
  
  @HiveField(4)
  REJECTED,
}

extension PairingStatusExtension on PairingStatus {
  String get name {
    switch (this) {
      case PairingStatus.PENDING:
        return '等待配对';
      case PairingStatus.PAIRED:
        return '已配对';
      case PairingStatus.DISCONNECTED:
        return '已断开';
      case PairingStatus.EXPIRED:
        return '已过期';
      case PairingStatus.REJECTED:
        return '已拒绝';
    }
  }
  
  static PairingStatus fromString(String status) {
    switch (status) {
      case 'PairingStatus.PENDING':
        return PairingStatus.PENDING;
      case 'PairingStatus.PAIRED':
        return PairingStatus.PAIRED;
      case 'PairingStatus.DISCONNECTED':
        return PairingStatus.DISCONNECTED;
      case 'PairingStatus.EXPIRED':
        return PairingStatus.EXPIRED;
      case 'PairingStatus.REJECTED':
        return PairingStatus.REJECTED;
      default:
        return PairingStatus.PENDING;
    }
  }
} 