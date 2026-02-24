import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 도트 네비게이션 (스텝 인디케이터)
/// Figma: Pre-treatment 섹션, 각 스텝 화면 상단
/// Ellipse 20×20, 활성=#10B981(초록), 비활성=#A6A6A6(회색)
/// 간격: x좌표 548→582→615... 약 34px center-to-center (gap ≈14px)
///
/// 최대 12단계 도트 지원
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  /// 도트 크기 (Figma: 20px)
  final double dotSize;

  /// 도트 간 간격 (Figma: ~14px)
  final double gap;

  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.dotSize = 20,
    this.gap = 14,
    this.activeColor = AppColors.green,
    this.inactiveColor = const Color(0xFFA6A6A6),
    this.completedColor = AppColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        return Padding(
          padding: EdgeInsets.only(right: index < totalSteps - 1 ? gap : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? activeColor
                  : isCompleted
                      ? completedColor
                      : inactiveColor,
              // 활성 도트에 약간의 강조 효과
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
