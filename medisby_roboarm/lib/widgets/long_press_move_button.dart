import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 롱프레스 → 이동중 버튼 (Home 화면 + Reset 플로우 공통)
/// [isMoving] false: 민트그린 배경 "길게 눌러서 홈 위치로 이동"
/// [isMoving] true:  초록 배경 "이동중..."
class LongPressMoveButton extends StatelessWidget {
  final bool isMoving;
  final VoidCallback? onLongPress;

  /// 이동 중 상태 배경색 (기본: AppColors.green)
  final Color? movingColor;

  /// 대기 상태 라벨 (기본: '길게 눌러서 홈 위치로 이동')
  final String? label;

  const LongPressMoveButton({
    super.key,
    required this.isMoving,
    this.onLongPress,
    this.movingColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (isMoving) {
      return Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: movingColor ?? AppColors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync, color: AppColors.textWhite, size: 28),
            const SizedBox(width: 12),
            Text(
              '이동중...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onLongPressDown: onLongPress != null ? (_) => onLongPress!() : null,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.mintGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.green, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, color: AppColors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              label ?? '길게 눌러서 홈 위치로 이동',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
