import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/trajectory_progress_bar.dart';

/// 궤적 추가 플로우
/// 스크린샷: 46~50 — 기존 궤적 끝으로 이동 → 새 궤적 입력 → 확인 → 대시보드 복귀
enum _AddStep {
  moveToEnd,    // 기존 궤적 끝으로 이동 중
  inputNew,     // 새 궤적 입력 (발판)
  verify,       // 궤적 확인
}

class TrajectoryAddFlow extends StatefulWidget {
  const TrajectoryAddFlow({super.key});

  @override
  State<TrajectoryAddFlow> createState() => _TrajectoryAddFlowState();
}

class _TrajectoryAddFlowState extends State<TrajectoryAddFlow> {
  _AddStep _step = _AddStep.moveToEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: switch (_step) {
          _AddStep.moveToEnd => _buildMoveToEnd(),
          _AddStep.inputNew => _buildInputNew(),
          _AddStep.verify => _buildVerify(),
        },
      ),
    );
  }

  // ── Step 1: 기존 궤적 끝으로 이동 ──

  Widget _buildMoveToEnd() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '장비의 암이 기존 궤적 끝으로 이동합니다',
          style:
              AppTextStyles.headingMedium.copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '이동이 완료될 때까지 기다려 주세요.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 32),
        // Simulate loading
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: AppColors.green,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              label: '취소',
              variant: ButtonVariant.dark,
              size: ButtonSize.medium,
              onPressed: () => context.go('/treatment'),
            ),
            const SizedBox(width: 20),
            AppButton(
              label: '확인',
              variant: ButtonVariant.green,
              size: ButtonSize.medium,
              onPressed: () => setState(() => _step = _AddStep.inputNew),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: 새 궤적 입력 ──

  Widget _buildInputNew() {
    return Row(
      children: [
        // Left: 궤적 입력
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF0),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('추가 궤적 입력',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textBlack)),
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
                const SizedBox(height: 16),
                _bulletText('왼쪽 발판을 떼면 이동이 중단됩니다.'),
                const SizedBox(height: 8),
                _bulletText('필요시 왼쪽 발판을 다시 밟아 기록을 이어가 주세요'),
              ],
            ),
          ),
        ),
        Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFFE0E0E0)),
        // Right: 입력 완료
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('궤적 입력 완료',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.textBlack)),
                const SizedBox(height: 16),
                Text(
                  "오른쪽 발판을 밟거나\n'다음' 버튼을 눌러주세요",
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 3: 궤적 확인 ──

  Widget _buildVerify() {
    return Column(
      children: [
        Text('추가 궤적 확인',
            style: AppTextStyles.headingLarge
                .copyWith(color: AppColors.textBlack)),
        const SizedBox(height: 8),
        Text('장비의 암이 입력한 궤적을 따라 이동합니다\n입력한 궤적을 확인해 주세요',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TrajectoryProgressBar(value: 0.6),
        ),
        const Spacer(),
        Row(
          children: [
            _navButton('← 궤적 재설정',
                () => setState(() => _step = _AddStep.inputNew)),
            const Spacer(),
            _navButton('궤적 확인 완료 →', () => context.go('/treatment')),
          ],
        ),
      ],
    );
  }

  // ── Helpers ──

  Widget _navButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 380,
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite)),
      ),
    );
  }

  Widget _bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(' \u2022  ',
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack)),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textBlack)),
        ),
      ],
    );
  }
}
