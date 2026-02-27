import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 홀드(누르고 있기) 버튼
///
/// 누르고 있는 동안만 "이동중..." 상태로 전환되고,
/// 손을 떼면 대기 상태로 복귀합니다.
/// 누적 홀드 시간이 [holdDuration]에 도달하면 [onComplete] 콜백을 호출합니다.
class LongPressMoveButton extends StatefulWidget {
  /// 누적 홀드 시간이 도달했을 때 호출
  final VoidCallback? onComplete;

  /// 완료까지 필요한 누적 홀드 시간 (기본: 3초)
  final Duration holdDuration;


  /// 이동 중 상태 배경색 (기본: AppColors.green)
  final Color? movingColor;

  /// 대기 상태 테마 색상 (기본: null → green 계열)
  final Color? idleColor;

  /// 대기 상태 라벨 (기본: '길게 눌러서 홈 위치로 이동')
  final String? label;

  const LongPressMoveButton({
    super.key,
    this.onComplete,
    this.holdDuration = const Duration(milliseconds: 1500),
    this.movingColor,
    this.idleColor,
    this.label,
  });

  @override
  State<LongPressMoveButton> createState() => _LongPressMoveButtonState();
}

class _LongPressMoveButtonState extends State<LongPressMoveButton> {
  bool _isPressed = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _checkTimer;

  @override
  void dispose() {
    _checkTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _onPressStart() {
    setState(() => _isPressed = true);
    _stopwatch.start();
    _checkTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_stopwatch.elapsed >= widget.holdDuration) {
        _checkTimer?.cancel();
        _stopwatch
          ..stop()
          ..reset();
        setState(() => _isPressed = false);
        widget.onComplete?.call();
      }
    });
  }

  void _onPressEnd() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _stopwatch.stop();
    _checkTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.idleColor ?? AppColors.green;
    final mColor = widget.movingColor ?? AppColors.green;

    return GestureDetector(
      onLongPressDown: widget.onComplete != null ? (_) => _onPressStart() : null,
      onLongPressUp: _onPressEnd,
      onLongPressCancel: _onPressEnd,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: _isPressed
              ? mColor
              : (widget.idleColor != null
                  ? color.withValues(alpha: 0.15)
                  : AppColors.mintGreen),
          borderRadius: BorderRadius.circular(10),
          border: _isPressed ? null : Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPressed ? Icons.sync : Icons.touch_app,
              color: _isPressed ? AppColors.textWhite : color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _isPressed
                  ? '이동중...'
                  : (widget.label ?? '길게 눌러서 홈 위치로 이동'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: _isPressed ? AppColors.textWhite : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
