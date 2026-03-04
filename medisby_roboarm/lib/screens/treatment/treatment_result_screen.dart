import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/treatment_params_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimensions.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/circular_progress.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/video_popup.dart';

/// 치료 결과 → 구동장착부 탈착 → 착용 해제 → 홈 위치 이동 → 완료
enum _EndPage {
  result,          // 치료 결과 (56)
  separateArm,     // 장비의 암과 구동장착부 탈착 (54)
  separateWear,    // 구동장착부 착용 해제 (55)
  homeMove,        // 홈 위치 이동 (57-58)
}

class TreatmentResultScreen extends StatefulWidget {
  const TreatmentResultScreen({super.key});

  @override
  State<TreatmentResultScreen> createState() => _TreatmentResultScreenState();
}

class _TreatmentResultScreenState extends State<TreatmentResultScreen> {
  _EndPage _page = _EndPage.result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: switch (_page) {
          _EndPage.result => _buildResult(),
          _EndPage.separateArm => _buildSeparateArm(),
          _EndPage.separateWear => _buildSeparateWear(),
          _EndPage.homeMove => _buildHomeMove(),
        },
      ),
    );
  }

  // ──────────────────────────────────────────
  // 치료 결과
  // ──────────────────────────────────────────

  Widget _buildResult() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          '치료 결과',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 평균 속도
              _resultCard('평균 속도', 0.6, '6.0'),
              const SizedBox(width: 16),
              // 치료 시간
              _resultCard('치료 시간', 1.0, '00:30:30'),
              const SizedBox(width: 16),
              // 평균 부하도
              _resultCard('평균 부하도', 0.5, '5.0'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _page = _EndPage.separateArm),
            child: Container(
              width: AppDimensions.navButtonWidth,
              height: AppDimensions.navButtonHeight,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text('종료',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textWhite)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultCard(String title, double progressValue, String valueText) {
    final isTime = valueText.contains(':');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.textBlack)),
            const SizedBox(height: 12),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgress(
                    value: progressValue,
                    size: 160,
                    activeColor: AppColors.background,
                    hidePercent: true,
                  ),
                  Text(
                    valueText,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.textBlack,
                      fontSize: isTime ? 28 : 36,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 구동장착부 탈착 (암 분리)
  // ──────────────────────────────────────────

  Widget _buildSeparateArm() {
    final params = context.read<TreatmentParamsProvider>();
    final limb = params.limbLabel;
    final isUpper = params.isUpper;
    final imgPath = isUpper
        ? 'assets/images/upper_mounting.png'
        : 'assets/images/lower_mounting.png';
    final videoPath = isUpper
        ? 'assets/videos/upper_unmounting.mp4'
        : 'assets/videos/lower_unmounting.mp4';

    return Column(
      children: [
        Text(
          '장비의 암과 $limb 구동장착부 탈착',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 24),
        Text(
          '장비의 암에 체결된 $limb 구동장착부를 탈착해 주세요',
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                  child: Image.asset(
                    imgPath,
                    width: 400,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                _videoButton('탈착 동영상', videoPath),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _greenButton('탈착 완료 →',
              () => setState(() => _page = _EndPage.separateWear)),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // 구동장착부 착용 해제
  // ──────────────────────────────────────────

  Widget _buildSeparateWear() {
    final params = context.read<TreatmentParamsProvider>();
    final limb = params.limbLabel;
    final isUpper = params.isUpper;
    final imgPath = isUpper ? 'assets/images/upper_wearing.png' : null;
    final videoPath = isUpper ? 'assets/videos/upper_takeoff.mp4' : null;

    return Column(
      children: [
        Text(
          '$limb 구동장착부 착용 해제',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 24),
        Text(
          '환자분으로부터 $limb 구동장착부 착용을 해제해 주세요',
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
                if (imgPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                    child: Image.asset(
                      imgPath,
                      width: 400,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 400,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.grayHighlight,
                      borderRadius: BorderRadius.circular(AppDimensions.smallBorderRadius),
                    ),
                    alignment: Alignment.center,
                    child: Text('이미지 준비 중',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textGray)),
                  ),
                const SizedBox(width: 16),
                _videoButton('해제 동영상', videoPath),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _greenButton('해제 완료 →',
              () => setState(() => _page = _EndPage.homeMove)),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // 홈 위치 이동
  // ──────────────────────────────────────────

  Widget _buildHomeMove() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          '홈 위치 이동',
          style:
              AppTextStyles.headingLarge.copyWith(color: AppColors.textBlack),
        ),
        const SizedBox(height: 16),
        Text(
          '버튼을 누른 상태를 유지하여 장비의 암을 홈 위치로 이동시켜 주세요.',
          style: AppTextStyles.titleMedium
              .copyWith(color: AppColors.textBlack),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 200),
          child: WarningBox(),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 250),
          child: LongPressMoveButton(
            onComplete: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                barrierDismissible: false,
                builder: (ctx) => ConfirmDialog(
                  title: '장비의 암이 홈 위치로 이동을 완료하였습니다',
                  confirmLabel: '확인',
                  onConfirm: () {
                    Navigator.of(ctx).pop();
                    context.go('/');
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '이동을 멈추려면 즉시 버튼에서 손을 떼주세요',
          style: AppTextStyles.captionLight
              .copyWith(color: AppColors.textBlack),
        ),
        const Spacer(),
      ],
    );
  }

  // ════════════════════════════════════════════
  // Shared helpers
  // ════════════════════════════════════════════

  Widget _greenButton(String label, VoidCallback onTap) {
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
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite)),
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
            Text(label,
                style: AppTextStyles.captionLight.copyWith(
                    color: color, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
