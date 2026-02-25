import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/body_part.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';
import '../../widgets/trajectory_progress_bar.dart';

/// 환자군 (3종)
enum PatientGroup { low, medium, high }

class PreTreatmentFlow extends StatefulWidget {
  const PreTreatmentFlow({super.key});

  @override
  State<PreTreatmentFlow> createState() => _PreTreatmentFlowState();
}

class _PreTreatmentFlowState extends State<PreTreatmentFlow> {
  static const int _totalSteps = 12;

  int _currentStep = 0; // 0-indexed (0~11)

  // Step 1
  PatientGroup? _selectedGroup;
  // Step 2
  BodyPartSelection? _selectedBodyPart;
  // Step 3
  bool _isMoving = false;
  // Step 9
  bool _showTooltip = false;
  // Step 10
  int _verifySpeed = 5;
  bool _isPaused = false;
  // Step 11
  int _treatmentSpeed = 5;
  int _treatmentMinutes = 30;

  // ════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Column(
          children: [
            _buildStepHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 8),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  // ── Header: "N / 12단계" + StepIndicator dots ──

  Widget _buildStepHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: StepIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            dotSize: 16,
            gap: 10,
          ),
        ),
        Positioned(
          left: 0,
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '${_currentStep + 1}',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.green),
              ),
              TextSpan(
                text: ' / $_totalSteps단계',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textBlack),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Navigation buttons ──

  Widget _buildNavButtons() {
    String prevLabel = '← 이전';
    String nextLabel = '다음 →';

    if (_currentStep == 8) prevLabel = '← 궤적 재설정';
    if (_currentStep == 9) {
      prevLabel = '← 궤적 재설정';
      nextLabel = '궤적 확인 완료 →';
    }
    if (_currentStep == _totalSteps - 1) nextLabel = '치료 시작 →';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Prev
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: _navButton(prevLabel, _goBack),
          ),
        ),
        // Next (or move button for step 3)
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: _currentStep == 2
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '버튼에서 손을 떼면 이동이 중단됩니다',
                        style: AppTextStyles.captionLight
                            .copyWith(color: AppColors.textBlack),
                      ),
                      const SizedBox(height: 6),
                      _buildMoveButton(),
                    ],
                  )
                : _navButton(nextLabel, _canGoNext ? _goNext : null),
          ),
        ),
      ],
    );
  }

  Widget _navButton(String label, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppDimensions.navButtonWidth,
        height: AppDimensions.navButtonHeight,
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppColors.green
              : AppColors.green.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite),
        ),
      ),
    );
  }

  bool get _canGoNext => switch (_currentStep) {
        0 => _selectedGroup != null,
        1 => _selectedBodyPart != null,
        _ => true,
      };

  void _goBack() {
    if (_currentStep == 8 || _currentStep == 9) {
      // 궤적 재설정 → step 8
      setState(() => _currentStep = 7);
    } else if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _isMoving = false;
      });
    } else {
      context.go('/');
    }
  }

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _isMoving = false;
        _showTooltip = false;
        _isPaused = false;
      });
    } else {
      // 치료 시작
      context.go('/treatment');
    }
  }

  // ════════════════════════════════════════════
  // Step Content
  // ════════════════════════════════════════════

  Widget _buildStepContent() {
    return switch (_currentStep) {
      0 => _buildStep1PatientGroup(),
      1 => _buildStep2BodyPart(),
      2 => _buildStep3ArmMovement(),
      3 => _buildStep4EquipmentAlign(),
      4 => _buildStep5WheelLock(),
      5 => _buildStep6DriveUnitWear(),
      6 => _buildStep7ArmConnection(),
      7 => _buildStep8StartPosition(),
      8 => _buildStep9TrajectoryInput(),
      9 => _buildStep10TrajectoryVerify(),
      10 => _buildStep11TreatmentParams(),
      11 => _buildStep12HandSwitch(),
      _ => const SizedBox(),
    };
  }

  // ──────────────────────────────────────────
  // Step 1: 환자군을 선택해주세요
  // ──────────────────────────────────────────

  Widget _buildStep1PatientGroup() {
    const groups = [
      (PatientGroup.low, '저부하', '(골다공증, 뇌졸증, 소아)', 'assets/images/img_group1.png'),
      (PatientGroup.medium, '중부하', '(동결견, 수술 후 기능회복)', 'assets/images/img_group2.png'),
      (PatientGroup.high, '고부하', '(근력 강화)', 'assets/images/img_group3.png'),
    ];

    return Column(
      children: [
        Text(
          '환자군을 선택해주세요',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: groups.map((g) {
              final isSelected = _selectedGroup == g.$1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGroup = g.$1),
                  child: Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.green
                            : AppColors.buttonDisabled,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                          child: Image.asset(g.$4, width: 160, height: 150, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          g.$2,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: isSelected
                                ? AppColors.green
                                : AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.$3,
                          style: AppTextStyles.captionLight
                              .copyWith(color: AppColors.textBlack),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 2: 치료할 부위를 선택해 주세요
  // ──────────────────────────────────────────

  Widget _buildStep2BodyPart() {
    return Column(
      children: [
        Text(
          '치료할 부위를 선택해 주세요',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bodyPartCard(BodyPartSelection.rightUpper),
                  const SizedBox(height: 12),
                  _bodyPartCard(BodyPartSelection.rightLower),
                ],
              ),
              const SizedBox(width: 12),
              // Center: body figure
              Image.asset(
                'assets/images/img_fullbody.png',
                width: 160,
                height: 340,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              // Right column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bodyPartCard(BodyPartSelection.leftUpper),
                  const SizedBox(height: 12),
                  _bodyPartCard(BodyPartSelection.leftLower),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bodyPartCard(BodyPartSelection part) {
    final isSelected = _selectedBodyPart == part;
    return GestureDetector(
      onTap: () => setState(() => _selectedBodyPart = part),
      child: Container(
        width: 160,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.buttonDisabled,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _bodyPartImage(part),
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              part.label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? AppColors.green : AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Step 3: 구동장착부 장착 준비 자세 이동
  // ──────────────────────────────────────────

  Widget _buildStep3ArmMovement() {
    final bp = _selectedBodyPart;
    return Column(
      children: [
        Text(
          '구동장착부 장착 준비 자세 이동',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 12),
        // Body part badge + description
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            WidgetSpan(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bp?.label ?? '',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textWhite),
                ),
              ),
            ),
            TextSpan(
              text: ' 치료를 위해 장비의 암을 구동장착부 준비 자세로 이동시켜 주세요.',
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
              text: "'이동' 버튼을 누르는 동안 장비의 암이 ",
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
            ),
            TextSpan(
              text: bp?.label ?? '',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.green),
            ),
            TextSpan(
              text: '의 ',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
            ),
            TextSpan(
              text: '$_entryDirection 진입',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.green),
            ),
            TextSpan(
              text: ' 방향으로 움직입니다.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Warning
        const WarningBox(),
        const SizedBox(height: 16),
        // Robot arm image
        Expanded(
          child: Image.asset(
            'assets/images/img_arm.png',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildMoveButton() {
    return SizedBox(
      width: 300,
      height: 70,
      child: LongPressMoveButton(
        isMoving: _isMoving,
        onLongPress: () {
          setState(() => _isMoving = true);
          _simulateMovement();
        },
      ),
    );
  }

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _showMoveCompleteDialog();
    });
  }

  void _showMoveCompleteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDialog(
        title: '장비의 암 이동이 완료되었습니다',
        confirmLabel: '확인',
        onConfirm: () {
          Navigator.of(ctx).pop();
          setState(() {
            _isMoving = false;
            _currentStep = 3; // Advance to step 4
          });
        },
      ),
    );
  }

  // ──────────────────────────────────────────
  // Step 4: 장비 위치 정렬
  // ──────────────────────────────────────────

  Widget _buildStep4EquipmentAlign() {
    final side = _selectedBodyPart?.sideLabel ?? '좌측';
    final limb = _selectedBodyPart?.limbLabel ?? '상지';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: 장비 위치 정렬
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  '장비 위치 정렬',
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.textBlack),
                ),
              ),
              const SizedBox(height: 12),
              _numberedTextWithEmphasis(1,
                  '$side $limb', ' 치료를 위해 환자의 ', _entryDirection, '에서 진입해 주세요'),
              const SizedBox(height: 8),
              _numberedText(
                  2, '환자에 대해 수직이 되도록 손잡이를 잡고 장비를 정렬해 주세요'),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/img_position_$_positionImageKey.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Container(width: 1, color: AppColors.divider),
        const SizedBox(width: 16),
        // Right column: 장비의 암의 끝 위치 정렬
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  '장비의 암의 끝 위치 정렬',
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.textBlack),
                ),
              ),
              const SizedBox(height: 12),
              _numberedText(3, '장비의 암의 끝이 치료 관절을 향하게 해주세요.'),
              const SizedBox(height: 8),
              _numberedText(
                  4, '필요에 따라 사용환경에 맞추어 추가적으로 위치를 조정해 주세요.'),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/img_position_${_positionImageKey}2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 5: 장비 바퀴 고정
  // ──────────────────────────────────────────

  Widget _buildStep5WheelLock() {
    return Column(
      children: [
        Text(
          '장비 바퀴 고정',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 8),
        Text(
          '바퀴 잠금장치를 밟아 장비를 고정해주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 두 앞바퀴 잠금
              Column(
                children: [
                  _darkBadge('두 앞바퀴 잠금'),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _imagePlaceholder(
                        280, 200, Icons.lock, '앞바퀴 잠금'),
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // 뒷바퀴 잠금
              Column(
                children: [
                  _darkBadge('뒷바퀴 잠금'),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _imagePlaceholder(
                        280, 200, Icons.lock, '뒷바퀴 잠금'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 6: 구동장착부 착용
  // ──────────────────────────────────────────

  Widget _buildStep6DriveUnitWear() {
    final isUpper = _selectedBodyPart?.isUpper ?? true;
    final limb = _selectedBodyPart?.limbLabel ?? '상지';

    return Column(
      children: [
        Text(
          '$limb 구동장착부 착용',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 8),
        Text(
          isUpper
              ? '$limb 구동장착부를 환자의 전완부에 올바르게 착용시켜 주세요'
              : '$limb 구동장착부를 환자의 하퇴부에 올바르게 착용시켜 주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              // 이전 이미지
              Column(
                children: [
                  Expanded(
                    child: _imagePlaceholder(
                      180,
                      200,
                      isUpper
                          ? Icons.back_hand
                          : Icons.directions_walk,
                      '이전 이미지',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '이전 이미지',
                    style: AppTextStyles.captionLight
                        .copyWith(color: AppColors.textOrange),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // 착용 이미지 (placeholder)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.placeholderBg,
                    borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '착용 이미지',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.grayHighlight),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 착용 동영상 버튼
              _videoButton('착용 동영상'),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 7: 장비의 암과 구동장착부 체결
  // ──────────────────────────────────────────

  Widget _buildStep7ArmConnection() {
    final limb = _selectedBodyPart?.limbLabel ?? '상지';

    return Column(
      children: [
        Text(
          '장비의 암과 $limb 구동장착부 체결',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 8),
        Text(
          '왼쪽 발판을 밟은 상태에서 장비의 암을 이동시켜\n장비의 암과 $limb 구동장착부를 체결해 주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              // 발판 이미지
              Expanded(
                child: _imagePlaceholder(
                    260, 200, Icons.gamepad, '발판'),
              ),
              const SizedBox(width: 16),
              // 체결 이미지
              Expanded(
                child: _imagePlaceholder(
                    260, 200, Icons.handyman, '체결'),
              ),
              const SizedBox(width: 12),
              _videoButton('체결 동영상'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '체결이 완료되면 오른쪽 발판을 밟거나 다음 버튼을 눌러주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 8: 시작 자세 입력
  // ──────────────────────────────────────────

  Widget _buildStep8StartPosition() {
    return Row(
      children: [
        // Left: 시작 자세 입력
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.contentBgGreen,
              borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '시작 자세 입력',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.textBlack),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '왼쪽 발판을 밟은 상태',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.green),
                    ),
                    TextSpan(
                      text: '에서\n장비의 암을 이동시켜\n시작 자세로 이동해 주세요',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                const SizedBox(height: 8),
                _bulletText('필요시 왼쪽 발판을 다시 밟아 이동을 이어가 주세요'),
                const Spacer(),
                Center(
                  child: _imagePlaceholder(
                      280, 100, Icons.gamepad, '발판'),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: AppColors.divider),
        // Right: 시작 자세 입력 완료
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.contentBgGray,
              borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '시작 자세 입력 완료',
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.textBlack),
                ),
                const Spacer(),
                Text(
                  '오른쪽 발판을 밟거나\n\'다음\' 버튼을 눌러주세요',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.green),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 9: 궤적 입력
  // ──────────────────────────────────────────

  Widget _buildStep9TrajectoryInput() {
    return Stack(
      children: [
        Row(
          children: [
            // Left: 궤적 입력
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.contentBgGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        '궤적 입력',
                        style: AppTextStyles.headingMedium
                            .copyWith(color: AppColors.textBlack),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '왼쪽 발판을 밟은 상태',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.green),
                        ),
                        TextSpan(
                          text: '에서\n장비의 암을 이동시켜\n궤적을 ',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textBlack),
                        ),
                        TextSpan(
                          text: '한 방향으로만',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.green),
                        ),
                        TextSpan(
                          text: ' 기록해주세요',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textBlack),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    // 한 방향 궤적이란? tooltip toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showTooltip = !_showTooltip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warningBgLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.warningYellow),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb,
                                color: AppColors.warningAmber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '한 방향 궤적이란?',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warningOrangeDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                    const SizedBox(height: 8),
                    _bulletText('필요시 왼쪽 발판을 다시 밟아 기록을 이어가 주세요'),
                    const Spacer(),
                    Center(
                      child: _imagePlaceholder(
                          280, 100, Icons.gamepad, '발판'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.divider),
            // Right: 궤적 입력 완료
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.contentBgGray,
                  borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '궤적 입력 완료',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const Spacer(),
                    Text(
                      '오른쪽 발판을 밟거나\n\'다음\' 버튼을 눌러주세요',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.green),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Tooltip popup
        if (_showTooltip)
          Positioned(
            left: 24,
            top: 200,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '시작점에서 끝점까지의 이동',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textWhite),
                        ),
                        TextSpan(
                          text: '입니다.\n돌아오는 궤적은 기록하지 마세요.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textWhite),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.swap_horiz, color: AppColors.green, size: 48),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 10: 궤적 확인
  // ──────────────────────────────────────────

  Widget _buildStep10TrajectoryVerify() {
    return Column(
      children: [
        Text(
          '궤적 확인',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 8),
        Text(
          '장비의 암이 입력한 궤적을 따라 이동합니다\n입력한 궤적을 확인해 주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Trajectory progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TrajectoryProgressBar(value: _isPaused ? 0.6 : 0.6),
        ),
        const Spacer(),
        // Speed control + pause
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
          ),
          child: Row(
            children: [
              Text(
                '속도 조절',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textBlack),
              ),
              const Spacer(),
              _speedButton(Icons.chevron_left, () {
                if (_verifySpeed > 1) {
                  setState(() => _verifySpeed--);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '$_verifySpeed',
                  style: AppTextStyles.headingLarge
                      .copyWith(color: AppColors.textBlack),
                ),
              ),
              _speedButton(Icons.chevron_right, () {
                if (_verifySpeed < 10) {
                  setState(() => _verifySpeed++);
                }
              }),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: () => setState(() => _isPaused = !_isPaused),
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.settingsCardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isPaused ? '재개' : '일시정지',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 11: 치료 파라미터 설정
  // ──────────────────────────────────────────

  Widget _buildStep11TreatmentParams() {
    final hours = _treatmentMinutes ~/ 60;
    final mins = _treatmentMinutes % 60;
    final timeStr =
        '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:00';

    return Column(
      children: [
        Text(
          '치료 파라미터 설정',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 속도 카드
              Container(
                width: 260,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '속도',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 16),
                    _arrowButton(Icons.keyboard_arrow_up, () {
                      if (_treatmentSpeed < 10) {
                        setState(() => _treatmentSpeed++);
                      }
                    }),
                    const SizedBox(height: 8),
                    Text(
                      '$_treatmentSpeed',
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 8),
                    _arrowButton(Icons.keyboard_arrow_down, () {
                      if (_treatmentSpeed > 1) {
                        setState(() => _treatmentSpeed--);
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // 시간 카드
              Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '시간',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _timeButton('+5분', 5),
                        const SizedBox(width: 12),
                        _timeButton('+10분', 10),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      timeStr,
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _timeButton('-5분', -5),
                        const SizedBox(width: 12),
                        _timeButton('-10분', -10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _timeButton(String label, int delta) {
    return GestureDetector(
      onTap: () {
        final newVal = _treatmentMinutes + delta;
        if (newVal >= 5 && newVal <= 120) {
          setState(() => _treatmentMinutes = newVal);
        }
      },
      child: Container(
        width: 80,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Step 12: 핸드 스위치 작동 안내
  // ──────────────────────────────────────────

  Widget _buildStep12HandSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            '핸드 스위치 작동 안내',
            style: AppTextStyles.headingLarge
                .copyWith(color: AppColors.textBlack),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _numberedInstruction(1, '환자분께 핸드 스위치를 전달해주세요.'),
              const SizedBox(height: 12),
              _numberedRichInstruction(
                2,
                '작동 중 ',
                'STOP',
                ' 버튼을 눌러 장비의 작동을 정지시킬 수 있습니다.',
                AppColors.red,
              ),
              const SizedBox(height: 12),
              _numberedRichInstruction(
                3,
                '정지 사유가 해소되면 ',
                'START',
                ' 버튼을 눌러 장비의 작동을 재개시킬 수 있습니다.',
                AppColors.green,
              ),
            ],
          ),
        ),
        const Spacer(),
        // Hand switch image
        Center(
          child: _imagePlaceholder(
              200, 180, Icons.radio_button_on, 'START/STOP'),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Data Helpers
  // ════════════════════════════════════════════

  String _bodyPartImage(BodyPartSelection part) {
    return switch (part) {
      BodyPartSelection.leftUpper => 'assets/images/img_upper_left3.png',
      BodyPartSelection.rightUpper => 'assets/images/img_upper_right3.png',
      BodyPartSelection.leftLower => 'assets/images/img_lower_left3.png',
      BodyPartSelection.rightLower => 'assets/images/img_lower_right3.png',
    };
  }

  String get _entryDirection {
    final bp = _selectedBodyPart;
    if (bp == null) return '좌측';
    if (bp.isUpper) return bp.sideLabel;
    return bp.isLeft ? '우측' : '좌측';
  }

  String get _positionImageKey {
    return switch (_selectedBodyPart) {
      BodyPartSelection.leftUpper => 'upper_left',
      BodyPartSelection.rightUpper => 'upper_right',
      BodyPartSelection.leftLower => 'lower_left',
      BodyPartSelection.rightLower => 'lower_right',
      _ => 'upper_left',
    };
  }

  // ════════════════════════════════════════════
  // Shared Helpers
  // ════════════════════════════════════════════

  Widget _imagePlaceholder(double w, double h, IconData icon,
      [String? label]) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.contentBgGray,
        borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.grayHighlight),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionLight
                  .copyWith(color: AppColors.grayHighlight, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _darkBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio_button_checked,
              color: AppColors.textWhite, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }

  Widget _videoButton(String label) {
    return GestureDetector(
      onTap: () {
        // TODO: open video
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.green, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: AppColors.green, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionLight.copyWith(
                color: AppColors.green,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _speedButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textWhite, size: 32),
      ),
    );
  }

  /// 번호 + 부위/방향 강조 텍스트
  Widget _numberedTextWithEmphasis(
      int num, String bodyPart, String mid, String direction, String after) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$num. ',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: bodyPart,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.green),
              ),
              TextSpan(
                text: mid,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
              ),
              TextSpan(
                text: direction,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.green),
              ),
              TextSpan(
                text: after,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _numberedText(int num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$num. ',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
        Expanded(
          child: Text(
            text,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          ),
        ),
      ],
    );
  }

  Widget _bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' \u2022  ',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
        Expanded(
          child: Text(
            text,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
          ),
        ),
      ],
    );
  }

  Widget _numberedInstruction(int num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$num.  ',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
        Expanded(
          child: Text(
            text,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
          ),
        ),
      ],
    );
  }

  Widget _numberedRichInstruction(
      int num, String before, String bold, String after, Color boldColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$num.  ',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: before,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textBlack),
              ),
              TextSpan(
                text: bold,
                style: AppTextStyles.bodyLarge.copyWith(color: boldColor),
              ),
              TextSpan(
                text: after,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textBlack),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
