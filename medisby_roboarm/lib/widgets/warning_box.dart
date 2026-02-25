import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 경고 텍스트 박스 (오렌지 테두리)
/// Home 화면(armNotHome/moving), Reset 플로우 등에서 공통 사용
class WarningBox extends StatelessWidget {
  /// 테두리 색상 (기본: AppColors.orange)
  final Color borderColor;

  /// 아이콘 색상 (기본: AppColors.orange)
  final Color iconColor;

  /// 텍스트 색상 (기본: AppColors.orange)
  final Color textColor;

  const WarningBox({
    super.key,
    this.borderColor = AppColors.orange,
    this.iconColor = AppColors.orange,
    this.textColor = AppColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '주변에 사람이나 장애물이 없는지 확인해 주세요.',
                  style: AppTextStyles.caption.copyWith(color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              '필요시 장비를 이동시켜 주세요.',
              style: AppTextStyles.caption.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
