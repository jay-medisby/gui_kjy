import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/settings_modal_base.dart';

/// 궤적 추가 플로우 (showDialog 모달)
/// 스크린샷: 45~50 — 확인 → 이동 안내 → 이동중 → 이동 완료 → 궤적 입력 → 궤적 확인 → 저장 확인
enum _AddStep {
  confirm,      // 궤적을 추가하시겠습니까?
  moveWarning,  // '확인' 버튼을 누르면 암이 이동합니다
  moving,       // 이동중입니다
  moveDone,     // 이동 완료
  inputNew,     // 추가 궤적 입력 (2컬럼)
  verify,       // 추가 궤적 확인
  saveConfirm,  // 추가 궤적을 저장하시겠습니까?
}

class TrajectoryAddFlow extends StatefulWidget {
  const TrajectoryAddFlow({super.key});

  /// 모달로 호출
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => const TrajectoryAddFlow(),
    );
  }

  @override
  State<TrajectoryAddFlow> createState() => _TrajectoryAddFlowState();
}

class _TrajectoryAddFlowState extends State<TrajectoryAddFlow> {
  _AddStep _step = _AddStep.confirm;
  int _verifySpeed = 5;
  bool _isPaused = false;
  bool _isMovingPaused = false;

  @override
  Widget build(BuildContext context) {
    // inputNew, verify 단계는 타이틀을 child 내부에서 처리
    final title = switch (_step) {
      _AddStep.inputNew => '',
      _AddStep.verify => '',
      _ => '',
    };

    return SettingsModalBase(
      title: title,
      showBack: false,
      showClose: true,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      onClose: () => Navigator.of(context).pop(false),
      child: switch (_step) {
        _AddStep.confirm => _buildConfirm(),
        _AddStep.moveWarning => _buildMoveWarning(),
        _AddStep.moving => _buildMoving(),
        _AddStep.moveDone => _buildMoveDone(),
        _AddStep.inputNew => _buildInputNew(),
        _AddStep.verify => _buildVerify(),
        _AddStep.saveConfirm => _buildSaveConfirm(),
      },
    );
  }

  // ════════════════════════════════════════════
  // Step 1: 궤적 추가 확인 (45)
  // ════════════════════════════════════════════

  Widget _buildConfirm() {
    return Column(
      children: [
        const Spacer(),
        Text(
          '궤적을 추가하시겠습니까?',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: '아니오',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 24),
            AppButton(
              label: '예',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () =>
                  setState(() => _step = _AddStep.moveWarning),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 2: 암 이동 안내 (46)
  // ════════════════════════════════════════════

  Widget _buildMoveWarning() {
    return Column(
      children: [
        const Spacer(),
        Text(
          "'확인' 버튼을 누르면\n장비의 암이 기존 궤적 끝으로 이동합니다",
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: '취소',
              variant: ButtonVariant.dark,
              size: ButtonSize.dialog,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 24),
            AppButton(
              label: '확인',
              variant: ButtonVariant.green,
              size: ButtonSize.dialog,
              onPressed: () {
                setState(() => _step = _AddStep.moving);
                _simulateArmMovement();
              },
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 3: 암 이동 중 (47)
  // ════════════════════════════════════════════

  Widget _buildMoving() {
    return Column(
      children: [
        const Spacer(),
        Text(
          '장비의 암이 기존 궤적 끝으로 이동중입니다',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        AppButton(
          label: _isMovingPaused ? '재개' : '일시정지',
          variant: _isMovingPaused ? ButtonVariant.blue : ButtonVariant.dark,
          size: ButtonSize.dialog,
          onPressed: () {
            setState(() => _isMovingPaused = !_isMovingPaused);
            // TODO: ROS 통신 연동 시 실제 일시정지/재개 처리
          },
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 4: 암 이동 완료 (48)
  // ════════════════════════════════════════════

  Widget _buildMoveDone() {
    return Column(
      children: [
        const Spacer(),
        Text(
          '장비의 암 이동이 완료되었습니다',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        AppButton(
          label: '확인',
          variant: ButtonVariant.green,
          size: ButtonSize.dialog,
          onPressed: () =>
              setState(() => _step = _AddStep.inputNew),
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 5: 추가 궤적 입력 (49_4)
  // ════════════════════════════════════════════

  Widget _buildInputNew() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 좌측: 추가 궤적 입력
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.smallBorderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '추가 궤적 입력',
                            style: AppTextStyles.headingMedium
                                .copyWith(color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: '왼쪽 발판을 밟은 상태',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.green),
                              ),
                              TextSpan(
                                text: '에서\n장비의 암을 이동시켜\n궤적을 ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textWhite,
                                    fontSize: 20),
                              ),
                              TextSpan(
                                text: '한 방향으로만',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.green),
                              ),
                              TextSpan(
                                text: ' 기록해주세요',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textWhite,
                                    fontSize: 20),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                          const SizedBox(height: 8),
                          _bulletText(
                              '필요시 왼쪽 발판을 다시 밟아 기록을 이어가 \n주세요'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  // 우측: 추가 궤적 입력 완료
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.smallBorderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            '추가 궤적 입력 완료',
                            style: AppTextStyles.headingMedium
                                .copyWith(color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "오른쪽 발판을 밟거나\n'다음' 버튼을 눌러주세요",
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.green, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 발판 이미지
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/img_stepper_ver1_text.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 다음 버튼
        Align(
          alignment: Alignment.centerRight,
          child: _navButton(
              '다음', () => setState(() => _step = _AddStep.verify)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 6: 추가 궤적 확인 (49_5)
  // ════════════════════════════════════════════

  Widget _buildVerify() {
    return Column(
      children: [
        Text(
          '추가 궤적 확인',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          '입력한 추가 궤적을 확인해 주세요',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textWhite, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // 멀티 세그먼트 궤적 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildMultiSegmentBar(),
        ),
        const Spacer(),
        // 속도 조절 + 일시정지
        Transform.translate(
          offset: const Offset(0, -50),
          child: _buildSpeedControl(),
        ),
        const SizedBox(height: 16),
        // 하단 버튼
        Row(
          children: [
            _navButton('궤적 재설정', () {
              setState(() {
                _isMovingPaused = false;
                _step = _AddStep.moveWarning;
              });
            }),
            const Spacer(),
            _navButton('궤적 확인 완료',
                () => setState(() => _step = _AddStep.saveConfirm)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Step 7: 저장 확인 (50)
  // ════════════════════════════════════════════

  Widget _buildSaveConfirm() {
    return Column(
      children: [
        const Spacer(),
        Text(
          '추가 궤적을 저장하시겠습니까?',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: '아니오',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 24),
            AppButton(
              label: '예',
              variant: ButtonVariant.white,
              size: ButtonSize.dialog,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════

  /// 암 이동 시뮬레이션
  void _simulateArmMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _step = _AddStep.moveDone);
    });
  }

  /// 네비게이션 버튼
  Widget _navButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.navButtonWidth,
        height: AppDimensions.navButtonHeight,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textWhite)),
      ),
    );
  }

  /// 불릿 텍스트 (다크 배경용)
  Widget _bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child:
              Icon(Icons.tips_and_updates, color: AppColors.grayHighlight, size: 20),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.captionLight.copyWith(
                color: AppColors.grayHighlight, fontSize: 18),
          ),
        ),
      ],
    );
  }

  /// 속도 조절 박스 (치료 준비 11단계와 동일 크기)
  Widget _buildSpeedControl() {
    return Center(
      child: Container(
        width: 720,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          borderRadius:
              BorderRadius.circular(AppDimensions.mediumBorderRadius),
        ),
        child: Row(
          children: [
            Text(
              '속도 조절',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textWhite),
            ),
            const Spacer(),
            _speedButton(Icons.chevron_left, () {
              if (_verifySpeed > 1) setState(() => _verifySpeed--);
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$_verifySpeed',
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.textWhite),
              ),
            ),
            _speedButton(Icons.chevron_right, () {
              if (_verifySpeed < 10) setState(() => _verifySpeed++);
            }),
            const SizedBox(width: 120),
            GestureDetector(
              onTap: () => setState(() => _isPaused = !_isPaused),
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: _isPaused
                      ? AppColors.blue
                      : AppColors.settingsCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 0.5),
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
    );
  }

  /// 속도 조절 좌우 버튼
  Widget _speedButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textWhite, size: 32),
      ),
    );
  }

  /// 멀티 세그먼트 궤적 바
  /// 파랑 = 기존 궤적(1번), 초록 = 추가 궤적(2번) 진행 위치
  /// 원 도트 = 로봇암 현재 위치만 표시
  Widget _buildMultiSegmentBar() {
    const barHeight = 32.0;
    const seg1End = 0.50;        // 1번 궤적 끝 = 전체의 50% (동적 — ROS 연동 시 변수화)
    const seg2Progress = 0.50;   // 추가 궤적 진행률 (나머지 영역의 50%, 동적)
    // 현재 위치 = seg1End + (1 - seg1End) * seg2Progress
    final currentPos = seg1End + (1 - seg1End) * seg2Progress;

    const seg1Color = Color(0xFF3057B9);     // 1번 궤적 (파랑)
    const seg2Color = Color(0xFF10B981);     // 2번 궤적 (초록)
    const trackColor = Color(0x263057B9);    // 미완료 영역
    const trackBorderColor = AppColors.grayHighlight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 바 본체
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: barHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final seg1Width = totalWidth * seg1End;
                final currentWidth = totalWidth * currentPos;

                return Stack(
                  children: [
                    // 전체 배경 (미완료)
                    Container(
                      width: totalWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: trackColor,
                        border: Border.all(
                            color: trackBorderColor, width: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // 초록 영역 (1번 궤적 끝 ~ 현재 위치)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: seg2Color,
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(6),
                          right: currentPos >= 1.0
                              ? const Radius.circular(6)
                              : Radius.zero,
                        ),
                      ),
                    ),
                    // 파랑 영역 (1번 궤적: 시작 ~ 1번 끝)
                    Container(
                      width: seg1Width,
                      height: barHeight,
                      decoration: const BoxDecoration(
                        color: seg1Color,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(6),
                        ),
                      ),
                    ),
                    // 현재 위치 마커 (세로선)
                    Positioned(
                      left: currentWidth - 1.5,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        color: AppColors.trajectoryMarker,
                      ),
                    ),
                    // 현재 위치 도트 (로봇암 위치)
                    Positioned(
                      left: (currentWidth - 6).clamp(0.0, totalWidth - 12),
                      top: barHeight / 2 - 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.green, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardBlack
                                  .withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 라벨
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            return SizedBox(
              width: totalWidth,
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1번 궤적 시작 (파란 영역 시작 = 좌측 끝)
                  Positioned(
                    left: 0,
                    child: Text(
                      '1번 궤적 시작',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textWhite, fontSize: 14),
                    ),
                  ),
                  // 1번 궤적 끝 (파란/초록 경계 = 50%)
                  Positioned(
                    left: totalWidth * seg1End,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, 0),
                      child: Text(
                        '1번 궤적 끝',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textWhite, fontSize: 14),
                      ),
                    ),
                  ),
                  // 2번 궤적 끝 (우측 끝)
                  Positioned(
                    right: 0,
                    child: Text(
                      '2번 궤적 끝',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

}
