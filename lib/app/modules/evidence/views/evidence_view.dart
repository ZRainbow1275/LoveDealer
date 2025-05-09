import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../theme/color_theme.dart';
import '../controllers/evidence_controller.dart';

class EvidenceView extends GetView<EvidenceController> {
  const EvidenceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.getPhotoTypeTitle())),
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.isSharing.value 
                ? null 
                : controller.shareCurrentPhoto,
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorTheme.primaryColor,
              ),
            );
          }
          
          if (controller.photosPaths.isEmpty) {
            return _buildNoEvidenceView();
          }
          
          return _buildEvidenceView();
        }),
      ),
    );
  }

  Widget _buildNoEvidenceView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.evidenceType.value == 'face' 
                ? Icons.face
                : Icons.no_photography,
            size: 70,
            color: ColorTheme.warning,
          ),
          const SizedBox(height: 16),
          Text(
            controller.evidenceType.value == 'face' 
                ? '未找到人脸验证图片' 
                : '未找到场景照片',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '可能未完成该步骤或者数据已删除',
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: SecondaryButton(
              text: '返回详情',
              onPressed: controller.goBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceView() {
    return Column(
      children: [
        Expanded(
          child: _buildPhotoViewer(),
        ),
        if (controller.photosPaths.length > 1)
          _buildNavigationControls(),
      ],
    );
  }

  Widget _buildPhotoViewer() {
    final currentPhotoPath = controller.photosPaths[controller.currentPhotoIndex.value];
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 照片查看器
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Hero(
              tag: 'evidence_${controller.evidenceType.value}_${controller.currentPhotoIndex.value}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.file(
                  File(currentPhotoPath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        
        // 左箭头导航（大于1张照片时显示）
        if (controller.photosPaths.length > 1)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: controller.previousPhoto,
              child: Container(
                width: 60,
                color: Colors.transparent,
                child: const Center(
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 40,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        
        // 右箭头导航（大于1张照片时显示）
        if (controller.photosPaths.length > 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: controller.nextPhoto,
              child: Container(
                width: 60,
                color: Colors.transparent,
                child: const Center(
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 40,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        
        // 图片元数据信息
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  controller.evidenceType.value == 'face' 
                      ? Icons.face
                      : Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.evidenceType.value == 'face' 
                      ? '面部验证' 
                      : '场景照片',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 分享按钮
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: controller.isSharing.value 
                ? null 
                : controller.shareCurrentPhoto,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.share,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        
        // Loading indicator
        if (controller.isSharing.value)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < controller.photosPaths.length; i++)
                GestureDetector(
                  onTap: () => controller.currentPhotoIndex.value = i,
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == controller.currentPhotoIndex.value 
                          ? ColorTheme.primaryColor 
                          : ColorTheme.background,
                      border: Border.all(
                        color: ColorTheme.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: controller.previousPhoto,
                color: ColorTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              Text(
                '${controller.currentPhotoIndex.value + 1} / ${controller.photosPaths.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: controller.nextPhoto,
                color: ColorTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 