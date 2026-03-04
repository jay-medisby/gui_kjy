import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/treatment_params_provider.dart';
import '../../models/body_part.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/trajectory_progress_bar.dart';
import '../../widgets/video_popup.dart';

/// 환자군 (3종)
enum PatientGroup { low, medium, high }

class PreTreatmentFlow extends StatefulWidget {
  final int initialStep;
  const PreTreatmentFlow({super.key, this.initialStep = 0});

  @override
  State<PreTreatmentFlow> createState() => _PreTreatmentFlowState();
}

class _PreTreatmentFlowState extends State<PreTreatmentFlow> {
  static const int _totalSteps = 12;

  late int _currentStep = widget.initialStep; // 0-indexed (0~11)

  // Step 1
  PatientGroup? _selectedGroup;
  // Step 2
  BodyPartSelection? _selectedBodyPart;
  // Step 3
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
                        '이동을 멈추려면 즉시 버튼에서 손을 떼주세요',
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
      });
    } else {
      context.go('/');
    }
  }

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        // Step 10 → 11 전환 시 검증 속도를 치료 속도 초기값으로 반영
        if (_currentStep == 9) {
          _treatmentSpeed = _verifySpeed;
        }
        _currentStep++;
        _showTooltip = false;
        _isPaused = false;
      });
    } else {
      // 치료 시작 — 설정값을 Provider에 저장
      final params = context.read<TreatmentParamsProvider>();
      params.setSpeed(_treatmentSpeed);
      params.setMinutes(_treatmentMinutes);
      if (_selectedBodyPart != null) {
        params.setBodyPart(_selectedBodyPart!);
      }
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
      (PatientGroup.low, '저부하', '(골다공증, 뇌졸증, 소아)', 'assets/images/group1.png'),
      (PatientGroup.medium, '중부하', '(동결견, 수술 후 기능회복)', 'assets/images/group2.png'),
      (PatientGroup.high, '고부하', '(근력 강화)', 'assets/images/group3.png'),
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
                'assets/images/fullbody.png',
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
        const SizedBox(height: 24),
        // Body part badge + description
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
              text: bp?.label ?? '',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.green, fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: " 치료를 위해 '이동' 버튼을 눌러 장비의 암을 구동장착부 준비 자세로 이동시켜 주세요.",
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          "'이동' 버튼을 누르는 동안에만 장비의 암이 움직입니다.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textGreen, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warningBgLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE65100)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: const Color(0xFFE65100), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '안전을 위해 장비의 암과 구동장착부를 체결하지 마시고, 장비 주변에 장애물이 없도록 해주세요.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: const Color(0xFFE65100)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Robot arm image — 버튼 영역과 겹쳐도 OK (중앙에 버튼 없음)
        Expanded(
          child: FractionallySizedBox(
            heightFactor: 1.3,
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/arm.png',
              fit: BoxFit.contain,
            ),
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
        label: '이동',
        onComplete: _showMoveCompleteDialog,
      ),
    );
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
                child: FractionallySizedBox(
                  heightFactor: 0.90,
                  child: Center(
                    child: Image.asset(
                      'assets/images/position_$_positionImageKey.png',
                      fit: BoxFit.contain,
                    ),
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
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.90,
                  child: Center(
                    child: Image.asset(
                      'assets/images/position_${_positionImageKey}2.png',
                      fit: BoxFit.contain,
                    ),
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
        const SizedBox(height: 24),
        Text(
          '바퀴 잠금장치를 밟아 장비를 고정해주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 두 앞바퀴 잠금
              Expanded(
                child: Column(
                  children: [
                    _darkBadge('두 앞바퀴 잠금'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.5,
                        child: Image.asset(
                          'assets/images/wheel_front.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // 뒷바퀴 잠금
              Expanded(
                child: Column(
                  children: [
                    _darkBadge('뒷바퀴 잠금'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Image.asset(
                        'assets/images/wheel_rear.png',
                        fit: BoxFit.contain,
                      ),
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
        const SizedBox(height: 24),
        Text(
          isUpper
              ? '$limb 구동장착부를 환자의 전완부에 올바르게 착용시켜 주세요'
              : '$limb 구동장착부를 환자의 하퇴부에 올바르게 착용시켜 주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 착용 이미지
                isUpper
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                        child: Image.asset(
                          'assets/images/upper_wearing.png',
                          width: 400,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 400,
                        height: 280,
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
                const SizedBox(width: 16),
                // 착용 동영상 버튼
                _videoButton(
                  '착용 동영상',
                  isUpper ? 'assets/videos/upper_wearing.mp4' : null,
                ),
              ],
            ),
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
        const SizedBox(height: 24),
        Text(
          '왼쪽 발판을 밟은 상태에서 장비의 암을 이동시켜 장비의 암과 $limb 구동장착부를 체결해 주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 발판 이미지
              Image.asset(
                'assets/images/stepper_ver1_text.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 40),
              // 체결 이미지 + 동영상 버튼
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                    child: Image.asset(
                      (_selectedBodyPart?.isUpper ?? true)
                          ? 'assets/images/upper_mounting.png'
                          : 'assets/images/lower_mounting.png',
                      width: 400,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _videoButton(
                    '체결 동영상',
                    (_selectedBodyPart?.isUpper ?? true)
                        ? 'assets/videos/upper_mounting.mp4'
                        : 'assets/videos/lower_mounting.mp4',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '체결이 완료되면 오른쪽 발판을 밟거나 다음 버튼을 눌러주세요',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Step 8: 시작 자세 입력
  // ──────────────────────────────────────────

  Widget _buildStep8StartPosition() {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: 시작 자세 입력
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.contentBgGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '시작 자세 입력',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: '왼쪽 발판을 밟은 상태',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.green),
                        ),
                        TextSpan(
                          text: '에서 장비의 암을 이동시켜\n시작 자세로 이동해 주세요',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textBlack, fontSize: 20),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                    const SizedBox(height: 8),
                    _bulletText('필요시 왼쪽 발판을 다시 밟아 이동을 이어가 주세요.'),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      '시작 자세 입력 완료',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '오른쪽 발판을 밟거나\n\'다음\' 버튼을 눌러주세요',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textBlack, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // 발판 이미지 — 중앙 하단, 양쪽 패널에 걸침
        Positioned(
          bottom: 5,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/stepper_ver1_text.png',
              height: 180,
              fit: BoxFit.contain,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: 궤적 입력
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.contentBgGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '궤적 입력',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: '왼쪽 발판을 밟은 상태',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.green),
                        ),
                        TextSpan(
                          text: '에서 장비의 암을 이동시켜\n궤적을 ',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textBlack, fontSize: 20),
                        ),
                        TextSpan(
                          text: '한 방향으로만',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.green),
                        ),
                        TextSpan(
                          text: ' 기록해주세요',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textBlack, fontSize: 20),
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
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EDDA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb,
                                color: AppColors.green, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '한 방향 궤적이란?',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.green, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                    const SizedBox(height: 8),
                    _bulletText('필요시 왼쪽 발판을 다시 밟아 기록을 이어가 주세요.'),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      '궤적 입력 완료',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '오른쪽 발판을 밟거나\n\'다음\' 버튼을 눌러주세요',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textBlack, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // 발판 이미지 — 중앙 하단, 양쪽 패널에 걸침
        Positioned(
          bottom: 5,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/stepper_ver1_text.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Tooltip popup
        if (_showTooltip)
          Positioned(
            left: 24,
            top: 190,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 삼각형 화살표 (버튼 방향)
                Transform.translate(
                  offset: const Offset(0, 1),
                  child: CustomPaint(
                    size: const Size(20, 10),
                    painter: _TrianglePainter(color: AppColors.darkGray),
                  ),
                ),
                // 팝업 본체
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkGray,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.mediumBorderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
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
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/oneway.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
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
        const SizedBox(height: 24),
        Text(
          '장비의 암이 입력한 궤적을 따라 이동합니다.\n입력한 궤적을 확인해 주세요.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Trajectory progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TrajectoryProgressBar(value: _isPaused ? 0.6 : 0.6),
        ),
        const Spacer(),
        // Speed control + pause
        Center(
          child: Container(
            width: 720,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.contentBgGray,
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
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.textBlack),
                ),
              ),
              _speedButton(Icons.chevron_right, () {
                if (_verifySpeed < 10) {
                  setState(() => _verifySpeed++);
                }
              }),
              const SizedBox(width: 120),
              GestureDetector(
                onTap: () => setState(() => _isPaused = !_isPaused),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isPaused ? AppColors.blue : AppColors.settingsCardBg,
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
        ),
        const SizedBox(height: 70),
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
                      style: AppTextStyles.headingLarge
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
                      style: AppTextStyles.headingLarge
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
                AppColors.blueDeep,
              ),
            ],
          ),
        ),
        const Spacer(),
        // Hand switch image
        Center(
          child: Image.asset(
            'assets/images/handswitch.png',
            height: 260,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Data Helpers
  // ════════════════════════════════════════════

  String _bodyPartImage(BodyPartSelection part) {
    return switch (part) {
      BodyPartSelection.leftUpper => 'assets/images/upper_left3.png',
      BodyPartSelection.rightUpper => 'assets/images/upper_right3.png',
      BodyPartSelection.leftLower => 'assets/images/lower_left3.png',
      BodyPartSelection.rightLower => 'assets/images/lower_right3.png',
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

  Widget _videoButton(String label, String? videoPath) {
    final enabled = videoPath != null;
    final color = enabled ? AppColors.green : AppColors.grayHighlight;
    return GestureDetector(
      onTap: enabled
          ? () => showVideoPopup(context, videoPath)
          : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.captionLight.copyWith(
                color: color,
                fontSize: 14,
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
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.tips_and_updates, color: AppColors.textGray, size: 20),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style:
                AppTextStyles.captionLight.copyWith(color: AppColors.textGray, fontSize: 18),
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
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack, fontSize: 20),
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
                    .copyWith(color: AppColors.textBlack, fontSize: 20),
              ),
              TextSpan(
                text: bold,
                style: AppTextStyles.bodyLarge.copyWith(color: boldColor),
              ),
              TextSpan(
                text: after,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textBlack, fontSize: 20),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
