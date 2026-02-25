import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/dimensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/modal_overlay.dart';
import '../../widgets/long_press_move_button.dart';

/// 비상정지 / 보호정지 타입
enum StopType { emergency, safe }

/// 정지 복구 플로우 (showDialog 모달, 전역 Overlay)
/// 스크린샷: 70~75 (비상정지), 80~85 (보호정지)
///
/// 4단계:
/// 1. 원인 확인 및 해제/재개
/// 2. 구동장착부 분리 (체크박스)
/// 3. 홈 위치 복구 (롱프레스 이동)
/// 4. 복구 완료
enum _StopStep { step1, step2, step3, step4 }

class StopFlow extends StatefulWidget {
  final StopType type;

  const StopFlow({super.key, required this.type});

  /// 어떤 화면에서든 호출 가능
  static Future<void> show(BuildContext context, StopType type) {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => StopFlow(type: type),
    );
  }

  @override
  State<StopFlow> createState() => _StopFlowState();
}

class _StopFlowState extends State<StopFlow> {
  _StopStep _step = _StopStep.step1;
  bool _separated = false;
  bool _isMoving = false;

  // ── 타입별 색상/텍스트 ──
  bool get isEmergency => widget.type == StopType.emergency;

  Color get accentColor =>
      isEmergency ? AppColors.emergencyAccent : AppColors.safeAccent;

  Color get bgColor =>
      isEmergency ? AppColors.emergencyBg : AppColors.safeBg;

  String get title => isEmergency ? '비상 정지' : '보호 정지';

  Color get buttonTextColor =>
      isEmergency ? AppColors.textWhite : AppColors.textBlack;

  @override
  Widget build(BuildContext context) {
    return ModalOverlay(
      dismissible: false,
      child: Container(
        width: AppDimensions.modalCardWidth,
        height: AppDimensions.modalCardHeight,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              BorderRadius.circular(AppDimensions.cardBorderRadius),
          border: Border.all(color: accentColor, width: 2),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── 타이틀 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEmergency ? Icons.error_outline : Icons.shield_outlined,
                  color: accentColor,
                  size: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.headingLarge
                      .copyWith(color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── 콘텐츠 ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: switch (_step) {
                  _StopStep.step1 => _buildStep1(),
                  _StopStep.step2 => _buildStep2(),
                  _StopStep.step3 => _buildStep3(),
                  _StopStep.step4 => _buildStep4(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // Step 1: 원인 확인
  // ════════════════════════════════════════════

  Widget _buildStep1() {
    if (isEmergency) return _buildEmergencyStep1();
    return _buildSafeStep1();
  }

  /// 비상정지 Step 1: 원인 확인 및 해제
  Widget _buildEmergencyStep1() {
    return Column(
      children: [
        _stepHeader(1, '원인 확인 및 해제'),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _contentBox(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '다음 절차를 수행하세요:',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. 비상 정지의 원인을 제거해 주세요.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '2. 비상 정지 버튼을 ',
                              style: AppTextStyles.bodyMedium,
                            ),
                            TextSpan(
                              text: '시계 방향으로 돌려',
                              style: AppTextStyles.bodyLarge.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textWhite,
                              ),
                            ),
                            TextSpan(
                              text: ' 해제해 주세요.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 비상 정지 버튼 이미지 placeholder
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('비상 정지 버튼',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.emergencyAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.emergency,
                      color: AppColors.emergencyAccent,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _actionButton(
          '다음 단계로',
          () => setState(() => _step = _StopStep.step2),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 보호정지 Step 1: 원인 확인 및 재개
  Widget _buildSafeStep1() {
    return Column(
      children: [
        _stepHeader(1, '원인 확인 및 재개'),
        const SizedBox(height: 16),
        _contentBox(
          Text(
            '부하 등 보호 정지의 원인을 제거한 후 재개 버튼을 눌러주세요.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const Spacer(),
        _actionButton(
          '재개',
          () => setState(() => _step = _StopStep.step2),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 2: 구동장착부 분리
  // ════════════════════════════════════════════

  Widget _buildStep2() {
    return Column(
      children: [
        _stepHeader(2, '구동장착부 분리'),
        const SizedBox(height: 16),
        _contentBox(
          Text(
            '복구를 진행하기 전에 구동장착부를 장비의 암에서 분리해 주세요.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _separated = !_separated),
          child: _contentBox(
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _separated ? accentColor : Colors.transparent,
                    border: Border.all(color: accentColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _separated
                      ? Icon(Icons.check, color: buttonTextColor, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  '구동장착부를 분리하였습니다.',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _actionButton(
          '다음 단계로',
          _separated
              ? () => setState(() => _step = _StopStep.step3)
              : () {},
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 3: 홈 위치 복구
  // ════════════════════════════════════════════

  Widget _buildStep3() {
    return Column(
      children: [
        _stepHeader(3, '홈 위치 복구'),
        const SizedBox(height: 16),
        _contentBox(
          Text(
            '아래 버튼을 누르고 있는 동안 장비의 암이 홈 위치로 이동합니다.\n'
            '홈 위치로 이동하는 동안 장비의 암 주변에 장애물이 없도록 해주세요.\n'
            '필요시 장비를 이동시켜 주세요.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: LongPressMoveButton(
            isMoving: _isMoving,
            movingColor: accentColor,
            onLongPress: () {
              setState(() => _isMoving = true);
              _simulateMovement();
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '버튼에서 손을 떼면 이동이 중단됩니다',
          style: AppTextStyles.captionLight,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 4: 복구 완료
  // ════════════════════════════════════════════

  Widget _buildStep4() {
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
          '복구 완료',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.green),
        ),
        const SizedBox(height: 12),
        Text(
          '장비의 암이 홈 위치로 이동했습니다.\n정상적으로 사용을 재개할 수 있습니다.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: '확인',
          variant: ButtonVariant.green,
          size: ButtonSize.dialog,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Movement simulation
  // ════════════════════════════════════════════

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isMoving = false;
        _step = _StopStep.step4;
      });
    });
  }

  // ════════════════════════════════════════════
  // Shared helpers
  // ════════════════════════════════════════════

  /// 단계 헤더: ❶ 제목
  Widget _stepHeader(int number, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: AppTextStyles.bodyLarge.copyWith(color: buttonTextColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyLarge),
      ],
    );
  }

  /// 강조색 테두리 콘텐츠 박스
  Widget _contentBox(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor, width: 1.5),
        borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
      ),
      child: child,
    );
  }

  /// 액션 버튼 (비상: 빨강, 보호: 노랑)
  Widget _actionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.navButtonWidth,
        height: AppDimensions.navButtonHeight,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(color: buttonTextColor),
        ),
      ),
    );
  }
}
