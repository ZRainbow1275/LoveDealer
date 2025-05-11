import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// 蓝牙工具类，提供辅助蓝牙操作的工具函数
class BluetoothUtils {
  BluetoothUtils._();

  /// 蓝牙服务UUID，用于标识本应用
  static const String APP_SERVICE_UUID = '0000a000-0000-1000-8000-00805f9b34fb';

  /// 配对特征UUID，用于传输配对信息
  static const String PAIRING_CHARACTERISTIC_UUID = '0000a001-0000-1000-8000-00805f9b34fb';

  /// 配对状态特征UUID，用于传输配对状态
  static const String PAIRING_STATUS_CHARACTERISTIC_UUID = '0000a002-0000-1000-8000-00805f9b34fb';

  /// 获取设备名称，如果没有名称则使用MAC地址
  static String getDeviceName(BluetoothDevice device) {
    return device.name.isNotEmpty ? device.name : device.id.id;
  }

  /// 获取设备标识符（MAC地址）
  static String getDeviceId(BluetoothDevice device) {
    return device.id.id;
  }

  /// 检查设备是否已连接
  static Future<bool> isDeviceConnected(BluetoothDevice device) async {
    try {
      final state = await device.connectionState.first;
      return state == BluetoothConnectionState.connected;
    } catch (e) {
      print('Error checking device connection: $e');
      return false;
    }
  }

  /// 搜索配对设备（过滤出只有本应用的设备）
  static Stream<List<ScanResult>> scanForPairingDevices({Duration timeout = const Duration(seconds: 10)}) {
    // 开始扫描，设置超时时间
    FlutterBluePlus.startScan(timeout: timeout);

    // 过滤并返回扫描结果
    return FlutterBluePlus.scanResults
        .map((results) => results.where((result) => 
            _isAppDevice(result.device) && 
            result.advertisementData.connectable)
            .toList());
  }

  /// 停止蓝牙扫描
  static Future<void> stopScan() async {
    return FlutterBluePlus.stopScan();
  }

  /// 检查设备是否为本应用设备
  static bool _isAppDevice(BluetoothDevice device) {
    // 实际应用中，可能需要检查广播数据中的特定标识符
    // 这里简单地检查设备名称是否包含应用标识
    return device.name.toLowerCase().contains('record') || 
           device.name.toLowerCase().contains('lovedealer');
  }

  /// 生成配对码
  static String generatePairingCode() {
    // 生成6位数字配对码
    return (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
  }

  /// 验证配对码
  static bool validatePairingCode(String localCode, String remoteCode) {
    return localCode == remoteCode;
  }

  /// 创建配对消息
  static Map<String, dynamic> createPairingMessage({
    required String deviceId,
    required String deviceName,
    required String pairingCode,
    String? recordId,
  }) {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'pairingCode': pairingCode,
      'timestamp': DateTime.now().toIso8601String(),
      'messageId': const Uuid().v4(),
      'recordId': recordId,
    };
  }

  /// 将配对消息编码为字节数组
  static List<int> encodePairingMessage(Map<String, dynamic> message) {
    final jsonString = jsonEncode(message);
    return utf8.encode(jsonString);
  }

  /// 将字节数组解码为配对消息
  static Map<String, dynamic> decodePairingMessage(List<int> data) {
    final jsonString = utf8.decode(data);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// 计算配对消息的哈希值，用于验证
  static String calculatePairingHash(Map<String, dynamic> message) {
    final jsonString = jsonEncode(message);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 格式化MAC地址（添加冒号分隔符）
  static String formatMacAddress(String macAddress) {
    if (macAddress.contains(':')) return macAddress;
    
    final buffer = StringBuffer();
    for (int i = 0; i < macAddress.length; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(macAddress.substring(i, i + 2).toUpperCase());
    }
    return buffer.toString();
  }

  /// 检查蓝牙是否开启
  static Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }

  /// 获取设备的信号强度描述
  static String getSignalStrengthDescription(int rssi) {
    if (rssi >= -50) return '强';
    if (rssi >= -70) return '中';
    if (rssi >= -90) return '弱';
    return '极弱';
  }

  /// 获取设备的信号强度图标索引（0-3）
  static int getSignalStrengthIconIndex(int rssi) {
    if (rssi >= -50) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -90) return 1;
    return 0;
  }

  /// 计算两个设备间的大致距离（米）
  /// 注意：这只是一个粗略估计，受环境因素影响很大
  static double calculateDistance(int rssi, {int txPower = -59}) {
    if (rssi == 0) return -1.0;
    
    final ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10.0).toDouble();
    } else {
      return 0.89976 * pow(ratio, 7.7095).toDouble() + 0.111;
    }
  }
  
  /// 执行双重退避算法，用于蓝牙重连尝试的间隔计算
  static Duration calculateBackoff(int attempt, {Duration initialDelay = const Duration(milliseconds: 200)}) {
    if (attempt <= 0) return initialDelay;
    
    // 使用双重退避：延迟时间 = 初始延迟 * 2^(尝试次数)，最大30秒
    final factor = pow(2, attempt.clamp(0, 7)).toInt();
    final calculatedDelay = initialDelay.inMilliseconds * factor;
    return Duration(milliseconds: calculatedDelay.clamp(0, 30000));
  }
} 