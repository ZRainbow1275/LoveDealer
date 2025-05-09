import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'history_record.g.dart';

@HiveType(typeId: 1)
class HistoryRecord {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String partnerName;
  
  @HiveField(2)
  final String? partnerDeviceId;
  
  @HiveField(3)
  final String? location;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final String? consentStatement;
  
  @HiveField(6)
  final String? audioRecordPath;
  
  @HiveField(7)
  final String? faceRecognitionPath;
  
  @HiveField(8)
  final List<String>? photosPaths;
  
  @HiveField(9)
  final bool isCompleted;
  
  @HiveField(10)
  final String? hashValue;
  
  @HiveField(11)
  final RecordStatus status;
  
  @HiveField(12)
  final String partnerAvatar;
  
  @HiveField(13)
  final bool isVerified;
  
  @HiveField(14)
  final List<String> evidenceIds;
  
  HistoryRecord({
    String? id,
    required this.partnerName,
    this.partnerDeviceId,
    this.location,
    DateTime? createdAt,
    this.consentStatement,
    this.audioRecordPath,
    this.faceRecognitionPath,
    this.photosPaths,
    this.isCompleted = false,
    this.hashValue,
    this.status = RecordStatus.CREATED,
    this.partnerAvatar = '',
    this.isVerified = false,
    this.evidenceIds = const [],
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  // 拷贝方法，用于更新记录
  HistoryRecord copyWith({
    String? partnerName,
    String? partnerDeviceId,
    String? location,
    String? consentStatement,
    String? audioRecordPath,
    String? faceRecognitionPath,
    List<String>? photosPaths,
    bool? isCompleted,
    String? hashValue,
    RecordStatus? status,
    String? partnerAvatar,
    bool? isVerified,
    List<String>? evidenceIds,
  }) {
    return HistoryRecord(
      id: id ?? this.id,
      partnerName: partnerName ?? this.partnerName,
      partnerDeviceId: partnerDeviceId ?? this.partnerDeviceId,
      location: location ?? this.location,
      createdAt: createdAt,
      consentStatement: consentStatement ?? this.consentStatement,
      audioRecordPath: audioRecordPath ?? this.audioRecordPath,
      faceRecognitionPath: faceRecognitionPath ?? this.faceRecognitionPath,
      photosPaths: photosPaths ?? this.photosPaths,
      isCompleted: isCompleted ?? this.isCompleted,
      hashValue: hashValue ?? this.hashValue,
      status: status ?? this.status,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      isVerified: isVerified ?? this.isVerified,
      evidenceIds: evidenceIds ?? this.evidenceIds,
    );
  }
  
  // 从JSON转换
  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'],
      partnerName: json['partnerName'],
      partnerDeviceId: json['partnerDeviceId'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      consentStatement: json['consentStatement'],
      audioRecordPath: json['audioRecordPath'],
      faceRecognitionPath: json['faceRecognitionPath'],
      photosPaths: json['photosPaths'] != null 
        ? List<String>.from(json['photosPaths']) 
        : null,
      isCompleted: json['isCompleted'] ?? false,
      hashValue: json['hashValue'],
      status: json['status'] != null 
        ? RecordStatusExtension.fromString(json['status']) 
        : RecordStatus.CREATED,
      partnerAvatar: json['partnerAvatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
      evidenceIds: List<String>.from(json['evidenceIds'] ?? []),
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerName': partnerName,
      'partnerDeviceId': partnerDeviceId,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'consentStatement': consentStatement,
      'audioRecordPath': audioRecordPath,
      'faceRecognitionPath': faceRecognitionPath,
      'photosPaths': photosPaths,
      'isCompleted': isCompleted,
      'hashValue': hashValue,
      'status': status.toString(),
      'partnerAvatar': partnerAvatar,
      'isVerified': isVerified,
      'evidenceIds': evidenceIds,
    };
  }
  
  // 是否有人脸识别
  bool hasFaceRecognition() {
    return faceRecognitionPath != null && faceRecognitionPath!.isNotEmpty;
  }
  
  // 是否有照片
  bool hasPhotos() {
    return photosPaths != null && photosPaths!.isNotEmpty;
  }
  
  // 是否有录音
  bool hasAudioRecord() {
    return audioRecordPath != null && audioRecordPath!.isNotEmpty;
  }
  
  // 获取照片数量
  int getPhotoCount() {
    return photosPaths?.length ?? 0;
  }
  
  // 判断记录是否可验证
  bool isVerifiable() {
    return isCompleted && hashValue != null && hashValue!.isNotEmpty;
  }
}

@HiveType(typeId: 2)
enum RecordStatus {
  @HiveField(0)
  CREATED,
  
  @HiveField(1)
  STATEMENT_RECORDED,
  
  @HiveField(2)
  FACE_RECOGNIZED,
  
  @HiveField(3)
  PHOTOS_CAPTURED,
  
  @HiveField(4)
  COMPLETED,
  
  @HiveField(5)
  VERIFIED,
  
  @HiveField(6)
  INVALIDATED,
}

extension RecordStatusExtension on RecordStatus {
  String get name {
    switch (this) {
      case RecordStatus.CREATED:
        return '已创建';
      case RecordStatus.STATEMENT_RECORDED:
        return '已录制陈述';
      case RecordStatus.FACE_RECOGNIZED:
        return '已人脸识别';
      case RecordStatus.PHOTOS_CAPTURED:
        return '已拍照';
      case RecordStatus.COMPLETED:
        return '已完成';
      case RecordStatus.VERIFIED:
        return '已验证';
      case RecordStatus.INVALIDATED:
        return '已失效';
    }
  }
  
  static RecordStatus fromString(String status) {
    switch (status) {
      case 'RecordStatus.CREATED':
        return RecordStatus.CREATED;
      case 'RecordStatus.STATEMENT_RECORDED':
        return RecordStatus.STATEMENT_RECORDED;
      case 'RecordStatus.FACE_RECOGNIZED':
        return RecordStatus.FACE_RECOGNIZED;
      case 'RecordStatus.PHOTOS_CAPTURED':
        return RecordStatus.PHOTOS_CAPTURED;
      case 'RecordStatus.COMPLETED':
        return RecordStatus.COMPLETED;
      case 'RecordStatus.VERIFIED':
        return RecordStatus.VERIFIED;
      case 'RecordStatus.INVALIDATED':
        return RecordStatus.INVALIDATED;
      default:
        return RecordStatus.CREATED;
    }
  }
} 