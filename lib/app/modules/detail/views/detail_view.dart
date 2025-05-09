import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/buttons/buttons.dart';
import '../../../theme/color_theme.dart';
import '../controllers/detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录详情'),
        backgroundColor: ColorTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
          color: Colors.white,
        ),
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
          
          return _buildDetailContent();
        }),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildDetailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPartnerInfo(),
          const SizedBox(height: 20),
          _buildRecordSection(),
          const SizedBox(height: 20),
          _buildConsentSection(),
          const SizedBox(height: 20),
          _buildEvidenceSection(),
          const SizedBox(height: 20),
          _buildTechnicalSection(),
        ],
      ),
    );
  }

  Widget _buildPartnerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: ColorTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.record.value?.partnerName ?? '未知',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.record.value?.createdAt.toString().substring(0, 19) ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorTheme.verified.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '已验证',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorTheme.verified,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSection() {
    return _buildSectionContainer(
      title: '记录信息',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow(
            label: '记录ID',
            value: controller.record.value?.id.substring(0, 8) ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: '记录时间',
            value: controller.record.value?.createdAt.toString().substring(0, 19) ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: '记录地点',
            value: controller.record.value?.location ?? '未知位置',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: '记录状态',
            value: controller.record.value?.status.name ?? '未知状态',
            valueColor: controller.record.value?.isCompleted == true
                ? ColorTheme.verified
                : ColorTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentSection() {
    return _buildSectionContainer(
      title: '同意陈述',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.record.value?.consentStatement ?? '未填写同意陈述',
              style: TextStyle(
                fontSize: 15,
                color: controller.record.value?.consentStatement != null
                    ? ColorTheme.textPrimary
                    : ColorTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          if (controller.record.value?.hasAudioRecord() == true) ...[
            const SizedBox(height: 16),
            _buildAudioPlayer(),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: ColorTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '口头同意录音',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 4,
                  child: Stack(
                    children: const [
                      SizedBox(
                        width: double.infinity,
                        child: ColoredBox(color: Colors.white),
                      ),
                      SizedBox(
                        width: 100,
                        child: ColoredBox(color: ColorTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '00:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '01:30',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return _buildSectionContainer(
      title: '证据记录',
      icon: Icons.verified_outlined,
      child: Column(
        children: [
          if (controller.record.value?.hasFaceRecognition() == true) ...[
            _buildEvidenceItem(
              title: '人脸识别',
              description: '点击查看人脸验证图片',
              icon: Icons.face,
              onTap: controller.viewFaceEvidence,
            ),
            const SizedBox(height: 12),
          ],
          if (controller.record.value?.hasPhotos() == true) ...[
            _buildEvidenceItem(
              title: '场景照片',
              description: '点击查看 ${controller.record.value?.getPhotoCount() ?? 0} 张场景照片',
              icon: Icons.camera_alt,
              onTap: controller.viewPhotoEvidence,
            ),
          ],
          if (!controller.record.value!.hasFaceRecognition() && !controller.record.value!.hasPhotos()) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.warning,
                    color: ColorTheme.warning,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '未检测到图片证据',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechnicalSection() {
    return _buildSectionContainer(
      title: '技术信息',
      icon: Icons.code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据哈希值',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Text(
              controller.record.value?.hashValue ?? '未生成哈希值',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: ColorTheme.info,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: '设备ID',
            value: controller.record.value?.partnerDeviceId ?? '未知设备',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ColorTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? ColorTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceItem({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ColorTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: '分享记录',
              onPressed: controller.isGeneratingShareData.value
                  ? null
                  : controller.shareRecord,
              isLoading: controller.isGeneratingShareData.value,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: controller.deleteRecord,
            icon: const Icon(
              Icons.delete,
              color: ColorTheme.error,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}