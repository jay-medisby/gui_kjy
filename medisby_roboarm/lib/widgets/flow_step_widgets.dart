import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import 'app_button.dart';
import 'long_press_move_button.dart';
import 'warning_box.dart';

/// 구동장착부 탈착 단계 (Exit / GoHome 플로우 공통)
///
/// 사용자에게 구동장착부 탈착 후 확인 버튼을 누르도록 안내한다.
/// [message] 기본값: "구동장착부를 탈착한 후 '확인' 버튼을 눌러주세요."
/// [onConfirmed] 확인 버튼 콜백
class DetachStepView extends StatelessWidget {
  final String message;
  final VoidCallback onConfirmed;

  const DetachStepView({
    super.key,
    this.message = "구동장착부를 탈착한 후 '확인' 버튼을 눌러주세요.",
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: AppTextStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: '확인',
          variant: ButtonVariant.green,
          size: ButtonSize.dialog,
          onPressed: onConfirmed,
        ),
      ],
    );
  }
}

/// 홈 위치 이동 단계 (Exit / GoHome 플로우 공통)
///
/// 롱프레스 버튼으로 암을 홈 위치로 이동시키는 UI.
/// [message] 안내 텍스트 (기본값: '버튼을 누른 상태를 유지하여 암을\n홈 위치로 이동시켜 주세요.')
/// [isMoving] 이동 중 여부
/// [onLongPress] 롱프레스 콜백
class MovingStepView extends StatelessWidget {
  final String message;
  final bool isMoving;
  final VoidCallback? onLongPress;

  const MovingStepView({
    super.key,
    this.message = '버튼을 누른 상태를 유지하여 암을\n홈 위치로 이동시켜 주세요.',
    required this.isMoving,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: AppTextStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const WarningBox(boxed: true),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: LongPressMoveButton(
            isMoving: isMoving,
            onLongPress: onLongPress,
          ),
        ),
      ],
    );
  }
}
