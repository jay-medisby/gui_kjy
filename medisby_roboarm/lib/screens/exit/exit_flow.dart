import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/settings_modal_base.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';

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
  bool _isMoving = false;

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
            _whiteButton('아니오', () => Navigator.of(context).pop()),
            const SizedBox(width: 24),
            _whiteButton('예', () => setState(() => _step = _ExitStep.detach)),
          ],
        ),
      ],
    );
  }

  // ── 구동장착부 탈착 ──

  Widget _buildDetach() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "구동장착부를 탈착한 후 '확인' 버튼을 눌러주세요.",
          style: AppTextStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => setState(() => _step = _ExitStep.moving),
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text('확인', style: AppTextStyles.headingMedium),
          ),
        ),
      ],
    );
  }

  // ── 홈 위치 이동 ──

  Widget _buildMoving() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '버튼을 누른 상태를 유지하여 암을\n홈 위치로 이동시켜 주세요.',
          style: AppTextStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const WarningBox(boxed: true),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: LongPressMoveButton(
            isMoving: _isMoving,
            onLongPress: () {
              setState(() => _isMoving = true);
              _simulateMovement();
            },
          ),
        ),
      ],
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

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _step = _ExitStep.done);
      // 실제 앱에서는 프로그램 종료 처리
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
    });
  }

  // ── Helpers ──

  Widget _whiteButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style:
              AppTextStyles.headingMedium.copyWith(color: AppColors.textBlack),
        ),
      ),
    );
  }
}
