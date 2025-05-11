import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'personal_info.g.dart';

@HiveType(typeId: 0)
class PersonalInfo {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String idNumber;
  
  @HiveField(3)
  final String phoneNumber;
  
  @HiveField(4)
  final String email;
  
  @HiveField(5)
  final String? avatarPath;
  
  @HiveField(6)
  final String? address;
  
  @HiveField(7)
  final String? emergencyContact;
  
  @HiveField(8)
  final String? emergencyPhone;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  PersonalInfo({
    String? id,
    required this.name,
    required this.idNumber,
    required this.phoneNumber,
    required this.email,
    this.avatarPath,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  // 创建空的个人信息对象
  factory PersonalInfo.empty() {
    return PersonalInfo(
      name: '',
      idNumber: '',
      phoneNumber: '',
      email: '',
    );
  }
  
  // 拷贝方法，用于更新信息
  PersonalInfo copyWith({
    String? name,
    String? idNumber,
    String? phoneNumber,
    String? email,
    String? avatarPath,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    return PersonalInfo(
      id: id,
      name: name ?? this.name,
      idNumber: idNumber ?? this.idNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
  
  // 判断信息是否完整
  bool isComplete() {
    return name.isNotEmpty && 
           idNumber.isNotEmpty && 
           phoneNumber.isNotEmpty && 
           email.isNotEmpty;
  }
  
  // 获取信息完整度百分比
  int getCompleteness() {
    int total = 8; // 总共8项信息
    int completed = 0;
    
    if (name.isNotEmpty) completed++;
    if (idNumber.isNotEmpty) completed++;
    if (phoneNumber.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (avatarPath != null && avatarPath!.isNotEmpty) completed++;
    if (address != null && address!.isNotEmpty) completed++;
    if (emergencyContact != null && emergencyContact!.isNotEmpty) completed++;
    if (emergencyPhone != null && emergencyPhone!.isNotEmpty) completed++;
    
    return (completed / total * 100).round();
  }
  
  // 验证身份证号码格式是否正确
  static bool validateIdNumber(String idNumber) {
    // 简单验证，18位
    RegExp idRegExp = RegExp(r'^\d{17}[\dXx]$');
    return idRegExp.hasMatch(idNumber);
  }
  
  // 验证手机号格式是否正确
  static bool validatePhoneNumber(String phoneNumber) {
    // 简单验证，11位
    RegExp phoneRegExp = RegExp(r'^1\d{10}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }
  
  // 验证邮箱格式是否正确
  static bool validateEmail(String email) {
    RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }
  
  // 从JSON转换
  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      id: json['id'],
      name: json['name'],
      idNumber: json['idNumber'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarPath: json['avatarPath'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'idNumber': idNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarPath': avatarPath,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}