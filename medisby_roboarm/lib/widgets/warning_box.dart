import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 경고 텍스트 박스 (오렌지 테두리)
/// Home 화면(armNotHome/moving), Reset 플로우 등에서 공통 사용
class WarningBox extends StatelessWidget {
  /// 첫 번째 줄 메시지
  final String message1;

  /// 두 번째 줄 메시지
  final String message2;

  /// 테두리 색상 (기본: AppColors.orange)
  final Color borderColor;

  /// 아이콘 색상 (기본: AppColors.orange)
  final Color iconColor;

  /// 텍스트 색상 (기본: AppColors.orange)
  final Color textColor;

  /// 배경색 (기본: 투명)
  final Color? backgroundColor;

  /// 폰트 크기 (기본: null → caption 기본 크기)
  final double? fontSize;

  /// 아이콘 크기 (기본: 36)
  final double iconSize;

  /// 컴팩트 모드: 아이콘이 첫째 줄에만, 둘째 줄은 들여쓰기
  final bool compact;

  const WarningBox({
    super.key,
    this.message1 = '장비의 암 이동 시 주변 사람 및 장애물을 확인해 주세요.',
    this.message2 = '필요시 장애물을 제거하거나 장비를 이동해 주세요.',
    this.borderColor = AppColors.orange,
    this.iconColor = AppColors.orange,
    this.textColor = AppColors.orange,
    this.backgroundColor,
    this.fontSize,
    this.iconSize = 36,
    this.compact = false,
  });

  TextStyle get _textStyle => AppTextStyles.caption.copyWith(
        color: textColor,
        fontSize: fontSize,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: iconColor, size: iconSize),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message1,
                        style: _textStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(left: iconSize + 6),
                  child: Text(message2, style: _textStyle),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.warning_amber, color: iconColor, size: iconSize),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message1, style: _textStyle),
                      const SizedBox(height: 2),
                      Text(message2, style: _textStyle),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
