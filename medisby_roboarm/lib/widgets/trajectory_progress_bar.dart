import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 궤적 내 위치 프로그레스 바
/// Figma: Treatment 화면 하단, 924px 너비
///   - 완료 영역: rgba(16,185,129,0.4) — 초록 40% 투명
///   - 미완료 영역: rgba(48,87,185,0.5) — 파랑 50% 투명
///   - 구분선: #6C6A6A (현재 위치 마커)
///   - 라벨: "궤적 시작"(좌측), "궤적 끝"(우측)
///
/// value: 0.0~1.0 (궤적 내 현재 위치 비율)
class TrajectoryProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final String startLabel;
  final String endLabel;

  const TrajectoryProgressBar({
    super.key,
    required this.value,
    this.height = 32,
    this.startLabel = '궤적 시작',
    this.endLabel = '궤적 끝',
  });

  // Figma 색상 토큰
  static const _completedColor = Color(0x6610B981); // rgba(16,185,129,0.4)
  static const _remainingColor = Color(0x803057B9); // rgba(48,87,185,0.5)
  static const _markerColor = Color(0xFF6C6A6A);
  static const _trackBorderColor = Color(0xFFA6A6A6);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 프로그레스 바 본체 ──
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final completedWidth = totalWidth * value.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // 전체 배경 (미완료)
                    Container(
                      width: totalWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color: _remainingColor,
                        border: Border.all(
                          color: _trackBorderColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    // 완료 영역 (좌측)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: completedWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color: _completedColor,
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(6),
                          right: value >= 1.0
                              ? const Radius.circular(6)
                              : Radius.zero,
                        ),
                      ),
                    ),

                    // 현재 위치 마커 (세로선)
                    if (value > 0 && value < 1.0)
                      Positioned(
                        left: completedWidth - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          color: _markerColor,
                        ),
                      ),

                    // 현재 위치 도트
                    if (value > 0 && value < 1.0)
                      Positioned(
                        left: completedWidth - 6,
                        top: height / 2 - 6,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.green,
                              width: 2.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── 라벨 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startLabel,
              style: AppTextStyles.captionLight.copyWith(fontSize: 14),
            ),
            // 현재 위치 퍼센트
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.green,
                fontSize: 14,
              ),
            ),
            Text(
              endLabel,
              style: AppTextStyles.captionLight.copyWith(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
