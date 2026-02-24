import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';

/// 장비 상태 유형
enum DeviceStatus {
  online('Online', '시스템 연결됨'),
  ready('Ready', '준비 완료'),
  run('Run', '치료 진행중'),
  emergency('Emergency', '비상정지');

  const DeviceStatus(this.label, this.subLabel);
  final String label;
  final String subLabel;
}

/// 우상단 장비 상태 배지
/// Figma: status 컴포넌트, 170×70, borderRadius 10px
/// 위치: x=1076, y=42 (AppScaffold에서 Positioned)
class DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const DeviceStatusBadge({
    super.key,
    this.status = DeviceStatus.ready,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Figma: Ellipse 20.55×20.55
          Container(
            width: AppDimensions.iconSizeSmall,
            height: AppDimensions.iconSizeSmall,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Figma: column gap=4px
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Figma: 22px bold (style_R08HBA)
                Text(
                  status.label,
                  style: AppTextStyles.titleSmall.copyWith(color: _labelColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.gapTiny),
                // Figma: 16px bold #404040
                Text(
                  status.subLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _dotColor {
    switch (status) {
      case DeviceStatus.online:
        return AppColors.blueDeep;
      case DeviceStatus.ready:
        return AppColors.green;
      case DeviceStatus.run:
        return AppColors.blue;
      case DeviceStatus.emergency:
        return AppColors.red;
    }
  }

  Color get _labelColor {
    switch (status) {
      case DeviceStatus.online:
        return AppColors.blueDeep;
      case DeviceStatus.ready:
        return AppColors.green;
      case DeviceStatus.run:
        return AppColors.blue;
      case DeviceStatus.emergency:
        return AppColors.red;
    }
  }
}
