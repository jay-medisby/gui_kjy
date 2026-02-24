import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 오렌지 경고 텍스트 박스
/// 스크린샷: 10_setting_reset_moving — 오렌지 테두리 박스 안 경고 텍스트
/// Home 화면(armNotHome/moving)과 Reset 플로우에서 공통 사용
class WarningBox extends StatelessWidget {
  final String text;

  /// true이면 오렌지 테두리 박스로 감쌈 (Settings 모달 스타일)
  /// false이면 단순 Row (Home 화면 스타일)
  final bool boxed;

  const WarningBox({
    super.key,
    this.text = '주변에 사람이나 장애물이 없는지 확인해 주세요.',
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: boxed ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber, color: AppColors.orange, size: 18),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.captionLight.copyWith(color: AppColors.orange),
            textAlign: boxed ? TextAlign.center : TextAlign.start,
          ),
        ),
      ],
    );

    if (!boxed) return content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: AppColors.orange, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '이동 시 주변에 사람이나 장애물이 없는지 확인해 주세요.',
                  style: AppTextStyles.captionLight.copyWith(
                    color: AppColors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '필요시 장비를 이동시켜 주세요.',
            style: AppTextStyles.captionLight.copyWith(
              color: AppColors.orange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
