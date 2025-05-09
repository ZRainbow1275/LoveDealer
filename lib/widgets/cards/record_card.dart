import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/color_theme.dart';
import '../../app/routes/app_pages.dart';

class RecordCard extends StatelessWidget {
  final String id;
  final String partnerName;
  final DateTime createdAt;
  final String? partnerAvatar;
  final bool isVerified;
  final VoidCallback? onTap;

  const RecordCard({
    Key? key,
    required this.id,
    required this.partnerName,
    required this.createdAt,
    this.partnerAvatar,
    this.isVerified = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap ?? () => Get.toNamed(Routes.DETAIL, arguments: {'id': id}),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            partnerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildVerificationBadge(),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: ColorTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24.0,
      backgroundColor: ColorTheme.primaryLightColor,
      backgroundImage: partnerAvatar != null ? NetworkImage(partnerAvatar!) : null,
      child: partnerAvatar == null
          ? Text(
              partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isVerified ? ColorTheme.verified.withOpacity(0.1) : ColorTheme.unverified.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.access_time,
            size: 14.0,
            color: isVerified ? ColorTheme.verified : ColorTheme.unverified,
          ),
          const SizedBox(width: 4.0),
          Text(
            isVerified ? '已确认' : '待确认',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: isVerified ? ColorTheme.verified : ColorTheme.unverified,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 