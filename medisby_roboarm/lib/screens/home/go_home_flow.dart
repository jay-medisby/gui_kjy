import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/settings_modal_base.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';

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
  bool _isMoving = false;

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
            _whiteButton('아니오', () => Navigator.of(context).pop()),
            const SizedBox(width: 24),
            _whiteButton('예', () => setState(() => _step = _GoHomeStep.detach)),
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
          onTap: () => setState(() => _step = _GoHomeStep.moving),
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
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            context.go('/');
          },
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

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isMoving = false;
        _step = _GoHomeStep.done;
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
