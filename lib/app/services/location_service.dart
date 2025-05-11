import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

/// 位置服务
/// 
/// 负责获取和管理地理位置信息
class LocationService extends GetxService {
  static LocationService get to => Get.find<LocationService>();
  
  // 位置实例
  final Location _location = Location();
  
  // 是否启用位置服务
  final RxBool _serviceEnabled = false.obs;
  
  // 位置权限状态
  final Rx<PermissionStatus> _permissionStatus = PermissionStatus.denied.obs;
  
  // 当前位置
  final Rx<LocationData?> currentLocation = Rx<LocationData?>(null);
  
  // 位置监听器
  StreamSubscription<LocationData>? _locationSubscription;
  
  // 位置更新间隔（秒）
  final int _updateIntervalSeconds = 10;
  
  bool get isServiceEnabled => _serviceEnabled.value;
  PermissionStatus get permissionStatus => _permissionStatus.value;
  bool get hasPermission => _permissionStatus.value == PermissionStatus.granted;
  
  @override
  void onInit() {
    super.onInit();
    _checkLocationService();
  }
  
  @override
  void onClose() {
    _stopLocationUpdates();
    super.onClose();
  }
  
  /// 检查位置服务状态
  Future<bool> _checkLocationService() async {
    try {
      // 检查位置服务是否启用
      _serviceEnabled.value = await _location.serviceEnabled();
      if (!_serviceEnabled.value) {
        // 请求用户启用位置服务
        _serviceEnabled.value = await _location.requestService();
        if (!_serviceEnabled.value) {
          return false;
        }
      }
      
      // 检查位置权限
      _permissionStatus.value = await _location.hasPermission();
      if (_permissionStatus.value == PermissionStatus.denied) {
        // 请求位置权限
        _permissionStatus.value = await _location.requestPermission();
        if (_permissionStatus.value != PermissionStatus.granted) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('检查位置服务失败: $e');
      return false;
    }
  }
  
  /// 获取当前位置
  Future<LocationData?> getCurrentLocation() async {
    if (!await _checkLocationService()) {
      return null;
    }
    
    try {
      // 配置位置服务
      await _configureLocation();
      
      // 获取当前位置
      final locationData = await _location.getLocation();
      currentLocation.value = locationData;
      
      return locationData;
    } catch (e) {
      debugPrint('获取当前位置失败: $e');
      return null;
    }
  }
  
  /// 开始持续获取位置更新
  Future<bool> startLocationUpdates() async {
    if (!await _checkLocationService()) {
      return false;
    }
    
    try {
      // 配置位置服务
      await _configureLocation();
      
      // 先停止之前的监听
      await _stopLocationUpdates();
      
      // 开始监听位置更新
      _locationSubscription = _location.onLocationChanged.listen(
        (LocationData locationData) {
          currentLocation.value = locationData;
        },
        onError: (e) {
          debugPrint('位置更新错误: $e');
          _stopLocationUpdates();
        },
      );
      
      return true;
    } catch (e) {
      debugPrint('开始位置更新失败: $e');
      return false;
    }
  }
  
  /// 停止位置更新
  Future<void> _stopLocationUpdates() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }
  
  /// 配置位置服务
  Future<void> _configureLocation() async {
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: _updateIntervalSeconds * 1000, // 毫秒
      distanceFilter: 5, // 米
    );
  }
  
  /// 获取位置精度描述
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return '高精度';
      case LocationAccuracy.balanced:
        return '平衡精度';
      case LocationAccuracy.low:
        return '低精度';
      case LocationAccuracy.powerSave:
        return '省电模式';
      case LocationAccuracy.reduced:
        return '降低精度';
      default:
        return '未知精度';
    }
  }
  
  /// 获取格式化的位置信息
  String getFormattedLocation() {
    final location = currentLocation.value;
    if (location == null) {
      return '未获取位置信息';
    }
    
    final latitude = location.latitude;
    final longitude = location.longitude;
    
    if (latitude == null || longitude == null) {
      return '位置信息不完整';
    }
    
    return '经度: ${longitude.toStringAsFixed(6)}, 纬度: ${latitude.toStringAsFixed(6)}';
  }
  
  /// 计算两个位置之间的距离（简化版，仅供参考）
  double calculateDistance(LocationData location1, LocationData location2) {
    if (location1.latitude == null || location1.longitude == null ||
        location2.latitude == null || location2.longitude == null) {
      return -1;
    }
    
    // 这里使用简化的距离计算公式
    // 实际应用中应使用Haversine公式或第三方库计算
    const earthRadius = 6371000.0; // 地球半径（米）
    final lat1 = location1.latitude! * (math.pi / 180);
    final lat2 = location2.latitude! * (math.pi / 180);
    final lon1 = location1.longitude! * (math.pi / 180);
    final lon2 = location2.longitude! * (math.pi / 180);
    
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c; // 距离（米）
  }
  
  /// 根据坐标获取地址信息
  /// 
  /// 由于实际地址解析需要使用geocoding服务，这里简化实现
  /// 实际应用中应使用如geocoding或google_maps_webservice等插件
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // 简化实现，仅返回格式化坐标
      // 实际应用中应调用地理编码API获取真实地址
      return '经度: ${longitude.toStringAsFixed(6)}, 纬度: ${latitude.toStringAsFixed(6)}';
      
      // 完整实现示例（需要添加geocoding依赖）：
      // final placemarks = await placemarkFromCoordinates(latitude, longitude);
      // if (placemarks.isNotEmpty) {
      //   final place = placemarks.first;
      //   return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      // }
      // return '未知地址';
    } catch (e) {
      debugPrint('获取地址信息失败: $e');
      return '获取地址失败';
    }
  }
} 