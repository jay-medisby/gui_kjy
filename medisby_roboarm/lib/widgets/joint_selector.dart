import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';
import 'app_button.dart';

/// J1~J6 관절 선택 UI
/// 스크린샷: 16_romtest, 20_veltest — 동일한 관절 선택 UI 재사용
///
/// [selectedJoint] 현재 선택된 관절 (1~6, null이면 미선택)
/// [onJointSelected] 관절 선택 콜백
/// [onConfirm] 확인 버튼 콜백
class JointSelector extends StatelessWidget {
  final int? selectedJoint;
  final ValueChanged<int> onJointSelected;
  final VoidCallback? onConfirm;

  const JointSelector({
    super.key,
    this.selectedJoint,
    required this.onJointSelected,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '테스트를 원하는 관절을 선택해 주세요',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 30),
        // J1~J6 버튼 그리드
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final joint = i + 1;
            final isSelected = selectedJoint == joint;
            return Padding(
              padding: EdgeInsets.only(right: i < 5 ? 12 : 0),
              child: GestureDetector(
                onTap: () => onJointSelected(joint),
                child: Container(
                  width: AppDimensions.jointButtonSize,
                  height: AppDimensions.jointButtonSize,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'J$joint',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isSelected ? AppColors.textWhite : AppColors.textBlack,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),
        // 확인 버튼
        AppButton(
          label: '확인',
          variant: ButtonVariant.green,
          size: ButtonSize.medium,
          enabled: selectedJoint != null,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
