import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../data/models/pairing_info.dart';

/// 蓝牙配对服务
/// 
/// 负责设备扫描、配对和连接状态管理
class BluetoothService extends GetxService {
  static BluetoothService get to => Get.find<BluetoothService>();
  
  // 蓝牙状态
  final Rx<BluetoothAdapterState> _bluetoothState = BluetoothAdapterState.unknown.obs;
  
  // 是否支持蓝牙
  final RxBool _isBluetoothSupported = true.obs;
  
  // 是否正在扫描
  final RxBool _isScanning = false.obs;
  
  // 扫描结果
  final RxList<ScanResult> scanResults = <ScanResult>[].obs;
  
  // 已连接设备
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  
  // 配对信息
  final Rx<PairingInfo?> pairingInfo = Rx<PairingInfo?>(null);
  
  // 配对码
  final RxString pairingCode = ''.obs;
  
  // 连接状态
  final RxBool isConnected = false.obs;
  
  // 状态监听器
  StreamSubscription? _stateSubscription;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  
  bool get isBluetoothSupported => _isBluetoothSupported.value;
  BluetoothAdapterState get bluetoothState => _bluetoothState.value;
  bool get isScanning => _isScanning.value;
  
  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }
  
  @override
  void onClose() {
    _stateSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.onClose();
  }
  
  /// 初始化蓝牙
  Future<void> _initBluetooth() async {
    try {
      // 监听蓝牙状态
      _stateSubscription = FlutterBluePlus.adapterState.listen((state) {
        _bluetoothState.value = state;
        if (state == BluetoothAdapterState.off) {
          _isScanning.value = false;
          scanResults.clear();
          isConnected.value = false;
          connectedDevice.value = null;
        }
      });
      
      // 初始获取蓝牙状态
      _bluetoothState.value = await FlutterBluePlus.adapterState.first;
    } catch (e) {
      _isBluetoothSupported.value = false;
      debugPrint('蓝牙初始化失败: $e');
    }
  }
  
  /// 打开蓝牙
  Future<void> enableBluetooth() async {
    // 注意：在iOS上无法通过代码打开蓝牙，需要用户手动操作
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      debugPrint('打开蓝牙失败: $e');
    }
  }
  
  /// 开始扫描
  Future<void> startScan({Duration? timeout}) async {
    if (_bluetoothState.value != BluetoothAdapterState.on) {
      throw Exception('蓝牙未开启');
    }
    
    if (_isScanning.value) {
      return;
    }
    
    // 清除旧的扫描结果
    scanResults.clear();
    
    // 设置扫描超时
    timeout ??= const Duration(seconds: 10);
    
    try {
      _isScanning.value = true;
      
      // 开始扫描
      _scanSubscription?.cancel();
      await FlutterBluePlus.startScan(timeout: timeout);
      
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          scanResults.value = results;
        },
        onDone: () {
          _isScanning.value = false;
        },
        onError: (e) {
          _isScanning.value = false;
          debugPrint('扫描出错: $e');
        },
      );
    } catch (e) {
      _isScanning.value = false;
      debugPrint('开始扫描失败: $e');
      rethrow;
    }
  }
  
  /// 停止扫描
  Future<void> stopScan() async {
    if (_isScanning.value) {
      try {
        await FlutterBluePlus.stopScan();
        _isScanning.value = false;
      } catch (e) {
        debugPrint('停止扫描失败: $e');
      }
    }
  }
  
  /// 连接设备
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (isConnected.value && connectedDevice.value?.remoteId == device.remoteId) {
      return;
    }
    
    // 先断开之前的连接
    await disconnectDevice();
    
    try {
      await device.connect();
      connectedDevice.value = device;
      isConnected.value = true;
      
      // 监听连接状态
      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          isConnected.value = false;
          connectedDevice.value = null;
        } else if (state == BluetoothConnectionState.connected) {
          isConnected.value = true;
          connectedDevice.value = device;
        }
      });
      
      // 生成配对码
      generatePairingCode();
    } catch (e) {
      isConnected.value = false;
      connectedDevice.value = null;
      debugPrint('连接设备失败: $e');
      rethrow;
    }
  }
  
  /// 断开设备连接
  Future<void> disconnectDevice() async {
    if (connectedDevice.value != null) {
      try {
        await connectedDevice.value!.disconnect();
      } catch (e) {
        debugPrint('断开设备连接失败: $e');
      } finally {
        isConnected.value = false;
        connectedDevice.value = null;
        _connectionSubscription?.cancel();
        _connectionSubscription = null;
      }
    }
  }
  
  /// 生成配对码
  void generatePairingCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    pairingCode.value = code;
  }
  
  /// 创建配对信息
  Future<PairingInfo> createPairingInfo() async {
    if (connectedDevice.value == null) {
      throw Exception('未连接设备');
    }
    
    final deviceId = connectedDevice.value!.remoteId.str;
    final deviceName = connectedDevice.value!.platformName;
    
    final info = PairingInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      pairingCode: pairingCode.value,
      createdAt: DateTime.now(),
      status: PairingStatus.PAIRED,
    );
    
    pairingInfo.value = info;
    return info;
  }
  
  /// 验证配对码
  bool verifyPairingCode(String code) {
    return code == pairingCode.value;
  }
  
  /// 获取设备名称
  String getDeviceName(BluetoothDevice device) {
    return device.platformName.isNotEmpty ? device.platformName : '未知设备';
  }
  
  /// 检查指定设备ID是否已连接
  Future<bool> isDeviceConnected(String deviceId) async {
    if (!isConnected.value || connectedDevice.value == null) {
      return false;
    }
    
    // 检查当前连接的设备ID是否匹配
    return connectedDevice.value!.remoteId.str == deviceId;
  }
} 