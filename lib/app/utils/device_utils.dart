import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设备信息工具类
class DeviceUtils {
  /// 单例实例
  static final DeviceUtils _instance = DeviceUtils._internal();
  
  /// 设备信息插件
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// 应用信息
  PackageInfo? _packageInfo;
  
  /// 设备信息缓存
  Map<String, dynamic>? _deviceData;
  
  /// 工厂构造函数
  factory DeviceUtils() => _instance;
  
  /// 私有构造函数
  DeviceUtils._internal();
  
  /// 初始化
  Future<void> init() async {
    await _initPackageInfo();
    await _initDeviceInfo();
  }
  
  /// 初始化应用信息
  Future<void> _initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
  
  /// 初始化设备信息
  Future<void> _initDeviceInfo() async {
    if (_deviceData != null) return;
    
    _deviceData = <String, dynamic>{};
    
    try {
      if (kIsWeb) {
        _deviceData = _readWebBrowserInfo(await _deviceInfo.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          _deviceData = _readAndroidBuildData(await _deviceInfo.androidInfo);
        } else if (Platform.isIOS) {
          _deviceData = _readIosDeviceInfo(await _deviceInfo.iosInfo);
        } else if (Platform.isLinux) {
          _deviceData = _readLinuxDeviceInfo(await _deviceInfo.linuxInfo);
        } else if (Platform.isMacOS) {
          _deviceData = _readMacOsDeviceInfo(await _deviceInfo.macOsInfo);
        } else if (Platform.isWindows) {
          _deviceData = _readWindowsDeviceInfo(await _deviceInfo.windowsInfo);
        }
      }
    } catch (e) {
      _deviceData = {'Error': 'Failed to get platform version: $e'};
    }
  }
  
  /// 读取Android设备信息
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'version': build.version.release,
      'sdkInt': build.version.sdkInt,
      'id': build.id,
      'board': build.board,
      'bootloader': build.bootloader,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'isPhysicalDevice': build.isPhysicalDevice,
      'type': build.type,
    };
  }
  
  /// 读取iOS设备信息
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname': data.utsname.sysname,
      'utsname.nodename': data.utsname.nodename,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'utsname.machine': data.utsname.machine,
    };
  }
  
  /// 读取Web浏览器信息
  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }
  
  /// 读取Linux设备信息
  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }
  
  /// 读取macOS设备信息
  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }
  
  /// 读取Windows设备信息
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }
  
  /// 获取应用名称
  String getAppName() {
    return _packageInfo?.appName ?? '记录';
  }
  
  /// 获取应用包名
  String getPackageName() {
    return _packageInfo?.packageName ?? 'com.lovedealer.record';
  }
  
  /// 获取应用版本号
  String getVersion() {
    return _packageInfo?.version ?? '1.0.0';
  }
  
  /// 获取应用构建号
  String getBuildNumber() {
    return _packageInfo?.buildNumber ?? '1';
  }
  
  /// 获取完整版本号（格式：版本号+构建号）
  String getFullVersion() {
    return '${getVersion()}+${getBuildNumber()}';
  }
  
  /// 获取设备品牌
  String getDeviceBrand() {
    return _deviceData?['brand'] ?? 
           _deviceData?['manufacturer'] ?? 
           _deviceData?['vendor'] ?? 
           '未知设备';
  }
  
  /// 获取设备型号
  String getDeviceModel() {
    return _deviceData?['model'] ?? '未知型号';
  }
  
  /// 获取设备操作系统
  String getDeviceOS() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return '未知操作系统';
  }
  
  /// 获取操作系统版本
  String getOSVersion() {
    if (Platform.isAndroid) {
      return _deviceData?['version'] ?? '未知版本';
    } else if (Platform.isIOS) {
      return _deviceData?['systemVersion'] ?? '未知版本';
    } else if (Platform.isLinux) {
      return _deviceData?['version'] ?? '未知版本';
    } else if (Platform.isMacOS) {
      return _deviceData?['osRelease'] ?? '未知版本';
    } else if (Platform.isWindows) {
      return '未知版本';
    }
    return '未知版本';
  }
  
  /// 获取设备唯一标识符
  String getDeviceId() {
    if (Platform.isAndroid) {
      return _deviceData?['id'] ?? '';
    } else if (Platform.isIOS) {
      return _deviceData?['identifierForVendor'] ?? '';
    } else if (Platform.isWindows) {
      return '';
    }
    return '';
  }
  
  /// 判断是否为物理设备（非模拟器）
  bool isPhysicalDevice() {
    return _deviceData?['isPhysicalDevice'] == true;
  }
  
  /// 获取所有设备信息
  Map<String, dynamic> getAllDeviceInfo() {
    return _deviceData ?? {};
  }
} 