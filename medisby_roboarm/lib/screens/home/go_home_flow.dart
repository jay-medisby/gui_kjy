import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/settings_modal_base.dart';
import '../../widgets/flow_step_widgets.dart';

/// 홈 복귀 플로우 (치료 중 홈 아이콘 탭 시)
/// 스크린샷: 90~94 — 확인 → 구동장착부 탈착 → 홈 이동 → 완료
enum _GoHomeStep {
  confirm,  // 홈 화면으로 돌아가시겠습니까?
  detach,   // 구동장착부 탈착
  moving,   // 홈 위치 이동 (롱프레스)
  done,     // 이동 완료
}

class GoHomeFlow extends StatefulWidget {
  const GoHomeFlow({super.key});

  /// 모달로 호출
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => const GoHomeFlow(),
    );
  }

  @override
  State<GoHomeFlow> createState() => _GoHomeFlowState();
}

class _GoHomeFlowState extends State<GoHomeFlow> {
  _GoHomeStep _step = _GoHomeStep.confirm;

  @override
  Widget build(BuildContext context) {
    return SettingsModalBase(
      title: '홈 화면으로 돌아가기',
      showBack: false,
      showClose: false,
      child: switch (_step) {
        _GoHomeStep.confirm => _buildConfirm(),
        _GoHomeStep.detach => _buildDetach(),
        _GoHomeStep.moving => _buildMoving(),
        _GoHomeStep.done => _buildDone(),
      },
    );
  }

  // ── 확인 ──

  Widget _buildConfirm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '홈 화면으로 돌아가시겠습니까?',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: '아니오',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 24),
            AppButton(
              label: '예',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () => setState(() => _step = _GoHomeStep.detach),
            ),
          ],
        ),
      ],
    );
  }

  // ── 구동장착부 탈착 ──

  Widget _buildDetach() {
    return DetachStepView(
      onConfirmed: () => setState(() => _step = _GoHomeStep.moving),
    );
  }

  // ── 홈 위치 이동 ──

  Widget _buildMoving() {
    return MovingStepView(
      onComplete: () {
        setState(() => _step = _GoHomeStep.done);
      },
    );
  }

  // ── 이동 완료 ──

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.green, width: 3),
          ),
          child: Icon(Icons.check, color: AppColors.green, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          '장비의 암 이동 완료',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.green),
        ),
        const SizedBox(height: 12),
        Text(
          '장비의 암이 홈 위치로 이동했습니다.\n정상적으로 사용을 재개할 수 있습니다.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: '확인',
          variant: ButtonVariant.green,
          size: ButtonSize.dialog,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/');
          },
        ),
      ],
    );
  }

}
