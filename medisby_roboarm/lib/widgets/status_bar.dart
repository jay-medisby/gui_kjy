import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';

class StatusBar extends StatefulWidget {
  /// 연결 상태 (true: 연결됨, false: 연결 안 됨)
  final bool isConnected;

  const StatusBar({
    super.key,
    this.isConnected = true,
  });

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Figma: y=691, h=29, w=1280
    // fill: rgba(255,255,255,0.1), stroke-top: rgba(0,0,0,0.3) 1px
    return Container(
      height: AppDimensions.statusBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.statusBarBg,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDark,
            width: AppDimensions.strokeThin,
          ),
        ),
      ),
      // Figma: 좌측 x=29, 우측 시간 텍스트 x=989
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Row(
        children: [
          // ── 좌측: 연결 상태 인디케이터 ──
          // Figma: row, gap=15px (layout_1CIS8Y)
          _buildConnectionIndicator(),
          const Spacer(),
          // ── 우측: 현재 시각 ──
          _buildTimeText(),
        ],
      ),
    );
  }

  /// 연결 상태 점 + 텍스트
  /// Figma: 11px 초록 원 + "연결됨" 텍스트, gap=15
  Widget _buildConnectionIndicator() {
    final color = widget.isConnected ? AppColors.green : AppColors.red;
    final label = widget.isConnected ? '연결됨' : '연결 안 됨';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.statusEllipseSize,
          height: AppDimensions.statusEllipseSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.gapStatusBar),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textWhite,
          ),
        ),
      ],
    );
  }

  /// 현재 시각 (Figma: "현재시각 2026년 1월 30일 3:02:43 pm", 16px bold)
  Widget _buildTimeText() {
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    final period = _now.hour < 12 ? 'am' : 'pm';
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;

    final text =
        '현재시각 ${_now.year}년 ${_now.month}월 ${_now.day}일 '
        '$hour12:$m:$s $period';

    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textWhite,
      ),
    );
  }
}
