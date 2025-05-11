import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限服务，用于管理应用权限
class PermissionService extends GetxService {
  /// 获取PermissionService实例
  static PermissionService get to => Get.find<PermissionService>();

  // 权限状态
  final RxMap<Permission, PermissionStatus> permissionStatus = <Permission, PermissionStatus>{}.obs;
  
  // 需要检查的权限列表
  final List<Permission> _permissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.location,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ];
  
  /// 初始化权限服务
  Future<PermissionService> init() async {
    // 初始化权限状态
    for (var permission in _permissions) {
      permissionStatus[permission] = await permission.status;
    }
    
    return this;
  }
  
  /// 检查单个权限
  Future<PermissionStatus> checkPermission(Permission permission) async {
    final status = await permission.status;
    permissionStatus[permission] = status;
    return status;
  }
  
  /// 检查所有权限
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    for (var permission in _permissions) {
      await checkPermission(permission);
    }
    return permissionStatus;
  }
  
  /// 请求单个权限
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    permissionStatus[permission] = status;
    return status;
  }
  
  /// 请求多个权限
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(List<Permission> permissions) async {
    final Map<Permission, PermissionStatus> results = {};
    
    for (var permission in permissions) {
      final status = await requestPermission(permission);
      results[permission] = status;
    }
    
    return results;
  }
  
  /// 请求所有权限
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await requestMultiplePermissions(_permissions);
  }
  
  /// 检查特定功能所需的全部权限是否已授予
  Future<bool> checkFeaturePermissions(PermissionFeature feature) async {
    final requiredPermissions = _getFeaturePermissions(feature);
    
    for (var permission in requiredPermissions) {
      final status = await checkPermission(permission);
      if (!status.isGranted) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 请求特定功能所需的全部权限
  Future<bool> requestFeaturePermissions(PermissionFeature feature) async {
    final requiredPermissions = _getFeaturePermissions(feature);
    final results = await requestMultiplePermissions(requiredPermissions);
    
    return results.values.every((status) => status.isGranted);
  }
  
  /// 获取特定功能所需的权限列表
  List<Permission> _getFeaturePermissions(PermissionFeature feature) {
    switch (feature) {
      case PermissionFeature.CAMERA:
        return [Permission.camera];
      
      case PermissionFeature.AUDIO_RECORDING:
        return [Permission.microphone];
      
      case PermissionFeature.FILE_STORAGE:
        return [Permission.storage];
      
      case PermissionFeature.LOCATION:
        return [Permission.location];
      
      case PermissionFeature.BLUETOOTH:
        return [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ];
      
      case PermissionFeature.RECORD_FLOW:
        return [
          Permission.camera,
          Permission.microphone,
          Permission.storage,
          Permission.location,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ];
    }
  }
  
  /// 检查权限是否永久拒绝
  bool isPermanentlyDenied(Permission permission) {
    final status = permissionStatus[permission];
    return status != null && status.isPermanentlyDenied;
  }
  
  /// 打开应用设置
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

/// 功能权限枚举
enum PermissionFeature {
  CAMERA,
  AUDIO_RECORDING,
  FILE_STORAGE,
  LOCATION,
  BLUETOOTH,
  RECORD_FLOW,
} 