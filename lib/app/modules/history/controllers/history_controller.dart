import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/history_record.dart';
import '../../../services/storage_service.dart';

class HistoryController extends GetxController {
  final RxList<HistoryRecord> records = <HistoryRecord>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  final RxInt selectedIndex = 1.obs; // 底部导航栏默认选中历史记录

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // 加载历史记录
  Future<void> loadRecords() async {
    isLoading.value = true;
    try {
      final storageService = Get.find<StorageService>();
      final results = await storageService.getHistoryRecords();
      records.value = results;
    } catch (e) {
      debugPrint('加载历史记录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 搜索历史记录
  void search(String query) {
    searchQuery.value = query;
  }

  // 清除搜索
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // 查看记录详情
  void viewDetail(String id) {
    Get.toNamed(Routes.DETAIL, arguments: {'id': id});
  }

  // 底部导航切换
  void changePage(int index) {
    // 如果点击的不是当前页，则跳转
    if (index != selectedIndex.value) {
      selectedIndex.value = index;
      switch (index) {
        case 0:
          Get.offAllNamed(Routes.HOME);
          break;
        case 1:
          // 已经在历史页面，不需要操作
          break;
        case 2:
          Get.offAllNamed(Routes.PROFILE);
          break;
      }
    }
  }

  // 获取筛选后的记录
  List<HistoryRecord> get filteredRecords {
    if (searchQuery.value.isEmpty) {
      return records;
    }
    
    return records.where((record) =>
      record.partnerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      (record.location?.toLowerCase() ?? '').contains(searchQuery.value.toLowerCase())
    ).toList();
  }
} 