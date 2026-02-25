import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 반원형 부하도 미터 (CustomPainter)
/// Figma: Treatment 카드 내부, 260×257 컨테이너
///
/// value: 0.0~1.0 (현재 부하 비율)
/// 색상 구간: 초록(0~0.5) → 노랑(0.5~0.75) → 빨강(0.75~1.0)
class GaugeMeter extends StatelessWidget {
  final double value;
  final double size;
  final String? label;
  final String? unit;

  const GaugeMeter({
    super.key,
    required this.value,
    this.size = 200,
    this.label,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.7,
      child: CustomPaint(
        painter: _GaugePainter(value: value.clamp(0.0, 1.0)),
        child: Align(
          alignment: const Alignment(0, 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(value * 100).toInt()}',
                style: AppTextStyles.headingLarge.copyWith(
                  color: _valueColor,
                  fontSize: size * 0.18,
                ),
              ),
              if (unit != null)
                Text(
                  unit!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGray,
                    fontSize: size * 0.08,
                  ),
                ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label!,
                    style: AppTextStyles.captionLight.copyWith(
                      fontSize: size * 0.07,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _valueColor {
    if (value < 0.5) return AppColors.green;
    if (value < 0.75) return AppColors.gaugeYellow;
    return AppColors.red;
  }
}

class _GaugePainter extends CustomPainter {
  final double value;

  _GaugePainter({required this.value});

  // 게이지 구간 색상 (Figma Treatment 섹션 색상 토큰 기반)
  static const _segments = [
    (0.0, 0.5, AppColors.green),          // 초록: 정상
    (0.5, 0.75, AppColors.gaugeYellow),   // 노랑: 주의
    (0.75, 1.0, AppColors.red),           // 빨강: 위험
  ];

  static const double _startAngle = math.pi; // 180° (좌측 수평)
  static const double _sweepTotal = math.pi; // 180° (반원)

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = math.min(size.width, size.height * 1.2) / 2 * 0.85;
    const strokeWidth = 18.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── 배경 트랙 (연한 회색) ──
    final bgPaint = Paint()
      ..color = AppColors.gaugeBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _startAngle, _sweepTotal, false, bgPaint);

    // ── 색상 구간별 호 그리기 ──
    for (final (start, end, color) in _segments) {
      final segStart = start.clamp(0.0, value);
      final segEnd = end.clamp(0.0, value);
      if (segEnd <= segStart) continue;

      final sweepStart = _startAngle + segStart * _sweepTotal;
      final sweep = (segEnd - segStart) * _sweepTotal;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, sweepStart, sweep, false, paint);
    }

    // ── 니들 (현재 값 표시) ──
    final needleAngle = _startAngle + value * _sweepTotal;
    final needleLength = radius * 0.65;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = AppColors.grayDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // ── 중심 점 ──
    final dotPaint = Paint()
      ..color = AppColors.grayDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, dotPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}
