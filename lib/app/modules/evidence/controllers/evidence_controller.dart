import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../../data/models/history_record.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class EvidenceController extends GetxController {
  // 服务
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();
  
  // 状态变量
  final RxBool isLoading = true.obs;
  final Rx<HistoryRecord?> record = Rx<HistoryRecord?>(null);
  final RxString recordId = ''.obs;
  final RxString evidenceType = ''.obs; // 'face' 或 'photo'
  final RxInt currentPhotoIndex = 0.obs;
  final RxList<String> photosPaths = <String>[].obs;
  final RxBool isSharing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    recordId.value = Get.arguments['recordId'] ?? '';
    evidenceType.value = Get.arguments['type'] ?? '';
    
    if (recordId.isEmpty || evidenceType.isEmpty) {
      Get.back();
      return;
    }
    
    _loadRecord();
  }
  
  // 加载记录
  Future<void> _loadRecord() async {
    isLoading.value = true;
    try {
      final historyRecord = await _storageService.getHistoryRecordById(recordId.value);
      if (historyRecord == null) {
        Get.snackbar('错误', '未找到记录', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        return;
      }
      
      record.value = historyRecord;
      
      if (evidenceType.value == 'face') {
        if (historyRecord.faceRecognitionPath != null && historyRecord.faceRecognitionPath!.isNotEmpty) {
          photosPaths.add(historyRecord.faceRecognitionPath!);
        }
      } else if (evidenceType.value == 'photo') {
        if (historyRecord.photosPaths != null && historyRecord.photosPaths!.isNotEmpty) {
          photosPaths.addAll(historyRecord.photosPaths!);
        }
      }
      
      if (photosPaths.isEmpty) {
        Get.snackbar('提示', '没有可查看的证据', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        return;
      }
    } catch (e) {
      _logger.e('加载记录失败', error: e);
      Get.snackbar('错误', '加载记录失败', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
  
  // 上一张照片
  void previousPhoto() {
    if (photosPaths.isEmpty) return;
    
    if (currentPhotoIndex.value > 0) {
      currentPhotoIndex.value--;
    } else {
      currentPhotoIndex.value = photosPaths.length - 1;
    }
  }
  
  // 下一张照片
  void nextPhoto() {
    if (photosPaths.isEmpty) return;
    
    if (currentPhotoIndex.value < photosPaths.length - 1) {
      currentPhotoIndex.value++;
    } else {
      currentPhotoIndex.value = 0;
    }
  }
  
  // 分享当前照片
  Future<void> shareCurrentPhoto() async {
    if (photosPaths.isEmpty || currentPhotoIndex.value >= photosPaths.length) {
      Get.snackbar('提示', '没有可分享的照片', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      isSharing.value = true;
      
      final photoPath = photosPaths[currentPhotoIndex.value];
      
      // 分享文件
      await Share.shareXFiles(
        [XFile(photoPath)],
        text: '记录证据分享',
      );
    } catch (e) {
      _logger.e('分享照片失败', error: e);
      Get.snackbar('错误', '分享照片失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSharing.value = false;
    }
  }
  
  // 返回上一页
  void goBack() {
    Get.back();
  }
  
  // 获取照片类型标题
  String getPhotoTypeTitle() {
    if (evidenceType.value == 'face') {
      return '人脸识别';
    } else if (evidenceType.value == 'photo') {
      return '场景照片';
    }
    return '照片证据';
  }
} 