import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/cards/record_card.dart';
import '../../../theme/color_theme.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed('/profile'),
            color: ColorTheme.textSecondary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildRecordsList(),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: '搜索历史记录...',
          fillColor: ColorTheme.background,
          filled: true,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final filteredRecords = controller.filteredRecords;
      
      if (filteredRecords.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          final record = filteredRecords[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RecordCard(
              id: record.id,
              partnerName: record.partnerName,
              partnerAvatar: record.partnerAvatar,
              createdAt: record.createdAt,
              isVerified: record.isVerified,
              onTap: () => controller.viewDetail(record.id),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Obx(() {
      final message = controller.searchQuery.value.isNotEmpty
          ? '没有找到符合条件的记录'
          : '暂无历史记录';
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.searchQuery.value.isNotEmpty
                  ? Icons.search_off
                  : Icons.history,
              size: 80,
              color: ColorTheme.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: ColorTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? '请尝试其他搜索关键词'
                  : '点击首页的"发起新的记录"开始记录',
              style: const TextStyle(
                fontSize: 14,
                color: ColorTheme.textHint,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '历史',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
} 