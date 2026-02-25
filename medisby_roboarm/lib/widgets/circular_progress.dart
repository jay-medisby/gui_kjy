import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 원형 프로그레스 링 (CustomPainter)
/// Figma: Treatment 결과 카드, 260×257 컨테이너
///
/// value: 0.0~1.0 (완료 비율)
/// 중앙에 퍼센트(%) 텍스트 표시
class CircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final Color? activeColor;
  final Color? trackColor;
  final double strokeWidth;
  final String? centerLabel;

  /// true이면 퍼센트(%) 텍스트를 숨기고 centerLabel만 표시
  final bool hidePercent;

  const CircularProgress({
    super.key,
    required this.value,
    this.size = 200,
    this.activeColor,
    this.trackColor,
    this.strokeWidth = 16,
    this.centerLabel,
    this.hidePercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.green;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          value: value.clamp(0.0, 1.0),
          activeColor: color,
          trackColor: trackColor ?? AppColors.gaugeBg,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hidePercent)
                Text(
                  '${(value * 100).toInt()}%',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: color,
                    fontSize: size * 0.2,
                  ),
                ),
              if (centerLabel != null)
                Padding(
                  padding: EdgeInsets.only(top: hidePercent ? 0 : 4),
                  child: Text(
                    centerLabel!,
                    style: AppTextStyles.captionLight.copyWith(
                      fontSize: size * 0.08,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.value,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 12시 방향에서 시작 (-90°)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    // ── 배경 트랙 ──
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // ── 프로그레스 호 ──
    if (value > 0) {
      final fgPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.activeColor != activeColor;
}
