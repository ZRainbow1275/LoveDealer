import 'package:get/get.dart';

import '../services/audio_service.dart';
import '../services/bluetooth_service.dart';
import '../services/camera_service.dart';
import '../services/continuous_record_service.dart';
import '../services/encryption_service.dart';
import '../services/face_recognition_service.dart';
import '../services/hash_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/record_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

/// 服务绑定类
/// 
/// 负责注册所有核心服务到GetX依赖注入系统
class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    // 注册基础服务（第一阶段已完成的服务）
    Get.lazyPut<PermissionService>(() => PermissionService(), fenix: true);
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<HashService>(() => HashService(), fenix: true);
    
    // 注册阶段三新实现的服务
    
    // 1. 用户管理功能
    Get.lazyPut<UserService>(() => UserService(), fenix: true);
    
    // 2. 蓝牙配对功能
    Get.lazyPut<BluetoothService>(() => BluetoothService(), fenix: true);
    
    // 3. 证据收集功能
    Get.lazyPut<CameraService>(() => CameraService(), fenix: true);
    Get.lazyPut<FaceRecognitionService>(() => FaceRecognitionService(), fenix: true);
    Get.lazyPut<AudioService>(() => AudioService(), fenix: true);
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    
    // 4. 数据安全功能
    Get.lazyPut<EncryptionService>(() => EncryptionService(), fenix: true);
    
    // 5. 持续记录服务
    Get.lazyPut<ContinuousRecordService>(() => ContinuousRecordService(), fenix: true);
    
    // 6. 记录管理功能
    Get.lazyPut<RecordService>(() => RecordService(), fenix: true);
  }
} 