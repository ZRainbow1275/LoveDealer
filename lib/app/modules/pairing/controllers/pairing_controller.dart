import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// 导入flutter_blue_plus以获取正确的类型，使用as避免名称冲突
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import '../../../data/models/pairing_info.dart';
import '../../../routes/app_pages.dart';
import '../../../services/bluetooth_service.dart';
import '../../../services/permission_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class PairingController extends GetxController {
  // 服务
  final BluetoothService _bluetoothService = Get.find<BluetoothService>();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();
  
  // 状态变量
  final RxBool isScanning = false.obs;
  final RxBool isGeneratingCode = false.obs;
  final RxList<BluetoothDeviceInfo> devices = <BluetoothDeviceInfo>[].obs;
  final RxString pairingCode = ''.obs;
  final RxString pairingDeviceId = ''.obs;
  final RxString pairingDeviceName = ''.obs;
  final RxBool isPaired = false.obs;
  final Rx<PairingStatus> pairingStatus = PairingStatus.PENDING.obs;
  
  // 控制器
  final TextEditingController codeInputController = TextEditingController();
  
  // 定时器
  Timer? _scanTimer;
  Timer? _pairingCodeTimer;
  
  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }
  
  @override
  void onClose() {
    _scanTimer?.cancel();
    _pairingCodeTimer?.cancel();
    codeInputController.dispose();
    stopScanning();
    super.onClose();
  }
  
  // 检查蓝牙和位置权限
  Future<void> _checkPermissions() async {
    try {
      final hasBluetoothPermission = await _permissionService.checkFeaturePermissions(PermissionFeature.BLUETOOTH);
      if (!hasBluetoothPermission) {
        await _requestPermissions();
      } else {
        await _initBluetooth();
      }
    } catch (e) {
      _logger.e('检查权限失败', error: e);
      _showError('检查权限失败');
    }
  }
  
  // 请求蓝牙和位置权限
  Future<void> _requestPermissions() async {
    try {
      final permissionsGranted = await _permissionService.requestFeaturePermissions(PermissionFeature.BLUETOOTH);
      if (permissionsGranted) {
        await _initBluetooth();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _logger.e('请求权限失败', error: e);
      _showError('请求权限失败');
    }
  }
  
  // 初始化蓝牙
  Future<void> _initBluetooth() async {
    try {
      final isAvailable = _bluetoothService.isBluetoothSupported;
      if (!isAvailable) {
        _showError('蓝牙不可用，请确保设备已开启蓝牙功能');
      }
    } catch (e) {
      _logger.e('初始化蓝牙失败', error: e);
      _showError('初始化蓝牙失败');
    }
  }
  
  // 开始扫描蓝牙设备
  Future<void> startScanning() async {
    if (isScanning.value) return;
    
    devices.clear();
    isScanning.value = true;
    
    try {
      // 检查蓝牙是否开启
      final isBluetoothOn = _bluetoothService.bluetoothState == BluetoothAdapterState.on;
      if (!isBluetoothOn) {
        // 请求开启蓝牙
        await _bluetoothService.enableBluetooth();
        // 检查蓝牙是否成功开启
        if (_bluetoothService.bluetoothState != BluetoothAdapterState.on) {
          _showError('请开启蓝牙以继续');
          isScanning.value = false;
          return;
        }
      }
      
      // 订阅设备发现事件
      _bluetoothService.startScan();
      
      // 监听蓝牙设备
      final subscription = _bluetoothService.scanResults.listen((scanResultsList) {
        // 转换ScanResult到BluetoothDeviceInfo
        devices.value = scanResultsList.map((result) => BluetoothDeviceInfo(
          id: result.device.remoteId.str,
          name: _bluetoothService.getDeviceName(result.device),
          rssi: result.rssi,
        )).toList();
      });
      
      // 设置扫描超时
      _scanTimer = Timer(const Duration(seconds: 30), () {
        stopScanning();
        subscription.cancel();
      });
    } catch (e) {
      _logger.e('开始扫描失败', error: e);
      _showError('扫描设备失败');
      isScanning.value = false;
    }
  }
  
  // 停止扫描
  void stopScanning() {
    if (!isScanning.value) return;
    
    isScanning.value = false;
    _bluetoothService.stopScan();
    _scanTimer?.cancel();
  }
  
  // 生成配对码
  Future<void> generatePairingCode() async {
    if (isGeneratingCode.value) return;
    
    isGeneratingCode.value = true;
    
    try {
      final code = PairingInfo.generatePairingCode();
      pairingCode.value = code;
      pairingStatus.value = PairingStatus.PENDING;
      
      // 保存配对信息
      final deviceInfo = await _bluetoothService.createPairingInfo();
      final pairingInfo = PairingInfo(
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        pairingCode: code,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        status: PairingStatus.PENDING,
      );
      
      await _storageService.savePairingInfo(pairingInfo);
      
      // 设置配对码过期定时器
      _pairingCodeTimer = Timer(const Duration(minutes: 5), () {
        if (pairingStatus.value == PairingStatus.PENDING) {
          pairingStatus.value = PairingStatus.EXPIRED;
          Get.snackbar('提示', '配对码已过期，请重新生成');
        }
      });
    } catch (e) {
      _logger.e('生成配对码失败', error: e);
      _showError('生成配对码失败');
    } finally {
      isGeneratingCode.value = false;
    }
  }
  
  // 选择设备配对
  Future<void> selectDevice(BluetoothDeviceInfo device) async {
    stopScanning();
    
    try {
      // 查找扫描结果中对应的BluetoothDevice
      final scanDevice = _bluetoothService.scanResults
          .firstWhere((result) => result.device.remoteId.str == device.id)
          .device;
      
      // 连接设备
      await _bluetoothService.connectToDevice(scanDevice);
      
      // 检查连接状态
      if (_bluetoothService.isConnected.value) {
        pairingDeviceId.value = device.id;
        pairingDeviceName.value = device.name;
        pairingStatus.value = PairingStatus.PENDING;
        
        // 显示配对码输入对话框
        _showPairingCodeInputDialog();
      } else {
        _showError('连接设备失败');
      }
    } catch (e) {
      _logger.e('选择设备失败', error: e);
      _showError('选择设备失败');
    }
  }
  
  // 验证配对码
  Future<void> verifyPairingCode(String code) async {
    try {
      final pairingInfo = await _storageService.getPairingInfoByCode(code);
      
      if (pairingInfo == null || pairingInfo.isExpired()) {
        Get.back(); // 关闭对话框
        _showError('配对码无效或已过期');
        return;
      }
      
      // 配对成功
      isPaired.value = true;
      pairingStatus.value = PairingStatus.PAIRED;
      
      // 更新配对信息
      final updatedPairingInfo = pairingInfo.copyWith(
        status: PairingStatus.PAIRED,
      );
      
      await _storageService.savePairingInfo(updatedPairingInfo);
      
      Get.back(); // 关闭对话框
      
      // 显示配对成功对话框
      _showPairingSuccessDialog();
    } catch (e) {
      _logger.e('验证配对码失败', error: e);
      _showError('验证配对码失败');
    }
  }
  
  // 进入记录流程
  void proceedToRecord() {
    Get.toNamed(Routes.RECORD);
  }
  
  // 返回上一页
  void goBack() {
    stopScanning();
    Get.back();
  }
  
  // 显示配对码输入对话框
  void _showPairingCodeInputDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('输入配对码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入对方设备显示的6位配对码'),
            const SizedBox(height: 16),
            TextField(
              controller: codeInputController,
              decoration: const InputDecoration(
                hintText: '请输入配对码',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => verifyPairingCode(codeInputController.text),
            child: const Text('确认'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  // 显示配对成功对话框
  void _showPairingSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('配对成功'),
        content: const Text('设备配对成功，现在可以开始记录同意过程'),
        actions: [
          TextButton(
            onPressed: proceedToRecord,
            child: const Text('开始记录'),
          ),
        ],
      ),
    );
  }
  
  // 显示权限被拒绝对话框
  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('权限请求'),
        content: const Text('需要蓝牙和位置权限才能进行设备配对。请在设置中开启这些权限。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
  
  // 显示错误提示
  void _showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }
}

// 蓝牙设备信息类
class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  
  const BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
  });
} 