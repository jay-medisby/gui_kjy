import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/settings_modal_base.dart';
import '../../widgets/flow_step_widgets.dart';

/// 종료 플로우 (showDialog 모달)
/// 스크린샷: 62~64 — 종료 확인 → 구동장착부 탈착 → 홈 이동 → 완료
enum _ExitStep {
  confirm,  // 프로그램을 종료하시겠습니까?
  detach,   // 구동장착부 탈착
  moving,   // 홈 위치 이동 (롱프레스)
  done,     // 이동 완료, 프로그램 종료
}

class ExitFlow extends StatefulWidget {
  const ExitFlow({super.key});

  /// 모달로 호출
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => const ExitFlow(),
    );
  }

  @override
  State<ExitFlow> createState() => _ExitFlowState();
}

class _ExitFlowState extends State<ExitFlow> {
  _ExitStep _step = _ExitStep.confirm;

  @override
  Widget build(BuildContext context) {
    return SettingsModalBase(
      title: '종료',
      showBack: false,
      showClose: false,
      child: switch (_step) {
        _ExitStep.confirm => _buildConfirm(),
        _ExitStep.detach => _buildDetach(),
        _ExitStep.moving => _buildMoving(),
        _ExitStep.done => _buildDone(),
      },
    );
  }

  // ── 종료 확인 ──

  Widget _buildConfirm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '프로그램을 종료하시겠습니까?',
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
              onPressed: () => setState(() => _step = _ExitStep.detach),
            ),
          ],
        ),
      ],
    );
  }

  // ── 구동장착부 탈착 ──

  Widget _buildDetach() {
    return DetachStepView(
      onConfirmed: () => setState(() => _step = _ExitStep.moving),
    );
  }

  // ── 홈 위치 이동 ──

  Widget _buildMoving() {
    return MovingStepView(
      onComplete: () {
        setState(() => _step = _ExitStep.done);
        // 실제 앱에서는 프로그램 종료 처리
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pop();
        });
      },
    );
  }

  // ── 이동 완료 ──

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '장비의 암이 홈 위치로 이동을 완료하였습니다\n프로그램을 종료합니다',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}
