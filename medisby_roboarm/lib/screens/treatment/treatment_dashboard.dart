import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/gauge_meter.dart';
import '../../widgets/trajectory_progress_bar.dart';
import '../../widgets/confirm_dialog.dart';
import 'trajectory_add_flow.dart';

class TreatmentDashboard extends StatefulWidget {
  const TreatmentDashboard({super.key});

  @override
  State<TreatmentDashboard> createState() => _TreatmentDashboardState();
}

class _TreatmentDashboardState extends State<TreatmentDashboard> {
  int _speed = 5;
  int _remainingSeconds = 28 * 60 + 39; // 28:39 demo
  final double _loadValue = 0.60; // 부하도 60%
  final double _trajectoryProgress = 0.45; // 궤적 내 위치
  bool _hasAddedTrajectory = false;
  double _seg1Ratio = 0.5; // 1번 궤적이 전체에서 차지하는 비율 (동적, 데모 0.5)

  // ════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          children: [
            // ── Header: title + pause ──
            _buildHeader(),
            const SizedBox(height: 16),
            // ── Main controls ──
            SizedBox(height: 260, child: _buildControls()),
            const SizedBox(height: 16),
            // ── Trajectory bar ──
            _buildTrajectorySection(),
            const Spacer(),
            // ── Bottom buttons ──
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            '치료 중',
            style:
                AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
          ),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: _showPauseOverlay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.settingsCardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                '일시정지',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textWhite),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Main Controls: speed / gauge / time ──

  Widget _buildControls() {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final hours = mins ~/ 60;
    final displayMins = mins % 60;
    final timeStr =
        '${hours.toString().padLeft(2, '0')}:${displayMins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 속도
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('속도',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.textBlack)),
                const SizedBox(height: 12),
                _arrowButton(Icons.keyboard_arrow_up, () {
                  if (_speed < 10) setState(() => _speed++);
                }),
                const SizedBox(height: 8),
                Text('$_speed',
                    style: AppTextStyles.headingLarge
                        .copyWith(color: AppColors.textBlack)),
                const SizedBox(height: 8),
                _arrowButton(Icons.keyboard_arrow_down, () {
                  if (_speed > 1) setState(() => _speed--);
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 부하도
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('부하도',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.textBlack)),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: GaugeMeter(value: _loadValue, size: 240),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 남은 시간
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('남은 시간',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.textBlack)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _timeButton('+1분', 60),
                    const SizedBox(width: 8),
                    _timeButton('+5분', 300),
                  ],
                ),
                const SizedBox(height: 8),
                Text(timeStr,
                    style: AppTextStyles.headingLarge
                        .copyWith(color: AppColors.textBlack)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _timeButton('-1분', -60),
                    const SizedBox(width: 8),
                    _timeButton('-5분', -300),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Trajectory section ──

  Widget _buildTrajectorySection() {
    return Column(
      children: [
        Text('궤적 내 위치',
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack)),
        const SizedBox(height: 8),
        _hasAddedTrajectory
            ? TrajectoryProgressBar(
                value: _trajectoryProgress * _seg1Ratio, // 전체 궤적 기준 재계산
                startLabel: '궤적 시작',
                endLabel: '',
                bookmarks: [
                  TrajectoryBookmark(
                    position: _seg1Ratio,
                    isActive: false,
                    label: '1번 궤적 끝',
                  ),
                  TrajectoryBookmark(
                    position: 1.0,
                    isActive: true,
                    label: '2번 궤적 끝',
                  ),
                ],
              )
            : TrajectoryProgressBar(
                value: _trajectoryProgress,
                startLabel: '궤적 시작',
                endLabel: '',
                bookmarks: [
                  TrajectoryBookmark(
                    position: 1.0,
                    isActive: true,
                    label: '궤적 끝',
                  ),
                ],
              ),
      ],
    );
  }

  // ── Bottom buttons ──

  Widget _buildBottomButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: _showTrajectoryAddConfirm,
          child: Container(
            width: AppDimensions.navButtonWidth,
            height: AppDimensions.navButtonHeight,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('궤적 추가',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textWhite)),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showQuitConfirm,
          child: Container(
            width: AppDimensions.navButtonWidth,
            height: AppDimensions.navButtonHeight,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('치료 종료',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textWhite)),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textWhite, size: 32),
      ),
    );
  }

  Widget _timeButton(String label, int deltaSeconds) {
    return GestureDetector(
      onTap: () {
        final newVal = _remainingSeconds + deltaSeconds;
        if (newVal >= 0 && newVal <= 7200) {
          setState(() => _remainingSeconds = newVal);
        }
      },
      child: Container(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite)),
      ),
    );
  }

  // ════════════════════════════════════════════
  // Modals
  // ════════════════════════════════════════════

  /// 일시정지 오버레이
  void _showPauseOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDialog(
        title: '일시 정지',
        message: "치료 재개를 원하시면 '치료 재개' 버튼을 누르거나\n핸드 스위치의 'START' 버튼을 누르세요",
        confirmLabel: '치료 재개',
        onConfirm: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  /// 치료 종료 확인
  void _showQuitConfirm() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDialog(
        title: '치료를 종료하시겠습니까?',
        cancelLabel: '아니오',
        confirmLabel: '예',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () {
          Navigator.of(ctx).pop();
          context.go('/treatment/result');
        },
      ),
    );
  }

  /// 궤적 추가 플로우
  void _showTrajectoryAddConfirm() async {
    final result = await TrajectoryAddFlow.show(context);
    if (result == true && mounted) {
      setState(() => _hasAddedTrajectory = true);
    }
  }

}
