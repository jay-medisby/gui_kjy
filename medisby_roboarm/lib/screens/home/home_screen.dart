import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/modal_overlay.dart';
import '../../widgets/long_press_move_button.dart';
import '../../widgets/warning_box.dart';

/// Home 화면 상태
/// Figma: Home 섹션 (329:13651) — 5개 화면
///   Screen 1: initializing  — 장비 상태 초기화중
///   Screen 2: armNotHome    — 암이 홈 위치에 있지 않습니다
///   Screen 3: moving        — 홈 위치로 이동중
///   Screen 4: (모달)        — 이동 완료 확인
///   Screen 5: ready         — 준비 완료
enum HomeStatus {
  initializing, // 장비 상태 초기화중
  armNotHome,   // 암이 홈 위치에 있지 않습니다
  moving,       // 홈 위치로 이동중
  ready,        // 준비 완료
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeStatus _status = HomeStatus.ready;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Figma: contentsaria x=261(→31 from sidebar), y=123, 984×549
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 24, 40, 24),
        child: Row(
          children: [
            // ── Left: Robot image ──
            SizedBox(
              width: 340,
              child: Center(
                child: Image.asset(
                  _isMovingImage
                      ? 'assets/images/img_roboarm_moving.png'
                      : 'assets/images/img_roboarm.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _imagePlaceholder(),
                ),
              ),
            ),
            const SizedBox(width: 50),
            // ── Right: Text content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBrandHeader(),
                  const SizedBox(height: 50),
                  ..._buildStatusContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isMovingImage =>
      _status == HomeStatus.armNotHome || _status == HomeStatus.moving;

  // ── Brand Header: MEDISBY / ROBOARM ──

  Widget _buildBrandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEDISBY',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textBlack,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'ROBOARM',
          style: GoogleFonts.notoSansKr(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  // ── Status-specific content ──

  List<Widget> _buildStatusContent() {
    return switch (_status) {
      HomeStatus.initializing => _buildInitializingContent(),
      HomeStatus.armNotHome => _buildArmNotHomeContent(),
      HomeStatus.moving => _buildMovingContent(),
      HomeStatus.ready => _buildReadyContent(),
    };
  }

  /// 상태 아이콘 폭(28) + 간격(8) = 설명 텍스트 들여쓰기
  static const _descIndent = EdgeInsets.only(left: 36);

  /// Screen 1: 장비 상태 초기화중
  List<Widget> _buildInitializingContent() {
    return [
      _statusRow(Icons.hourglass_bottom, '장비 상태 초기화중...', AppColors.blue),
      const SizedBox(height: 12),
      Padding(
        padding: _descIndent,
        child: Text(
          '장비의 암의 위치를 감지하고 있습니다.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textBlack),
        ),
      ),
    ];
  }

  /// Screen 2: 암이 홈 위치에 있지 않습니다
  List<Widget> _buildArmNotHomeContent() {
    return [
      _statusRow(
          Icons.warning_amber_rounded, '암이 홈 위치에 있지 않습니다', AppColors.orange),
      const SizedBox(height: 16),
      Padding(
        padding: _descIndent,
        child: Text(
          '버튼을 길게 눌러서 장비의 암을\n홈 위치로 이동시켜 주세요.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
      ),
      const SizedBox(height: 20),
      const WarningBox(),
      const SizedBox(height: 12),
      LongPressMoveButton(
        isMoving: false,
        onLongPress: () {
          setState(() => _status = HomeStatus.moving);
          _simulateMovement();
        },
      ),
    ];
  }

  /// Screen 3: 홈 위치로 이동중
  List<Widget> _buildMovingContent() {
    return [
      _statusRow(Icons.autorenew, '홈 위치로 이동중...', AppColors.blue),
      const SizedBox(height: 16),
      Padding(
        padding: _descIndent,
        child: Text(
          '버튼을 길게 눌러서 장비의 암을\n홈 위치로 이동시켜 주세요.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
      ),
      const SizedBox(height: 20),
      const WarningBox(),
      const SizedBox(height: 12),
      const LongPressMoveButton(isMoving: true),
    ];
  }

  /// Screen 5: 준비 완료
  List<Widget> _buildReadyContent() {
    return [
      _statusRow(Icons.check_box_rounded, '준비 완료', AppColors.green),
      const SizedBox(height: 16),
      Padding(
        padding: _descIndent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '장비의 암(Arm)이 홈 위치에 있습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textBlack),
            ),
            const SizedBox(height: 4),
            Text(
              "'시작' 버튼을 눌러 치료를 시작하세요.",
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textBlack),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Shared components ──

  /// 상태 아이콘 + 텍스트 Row
  Widget _statusRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // _warningText, _buildLongPressButton, _buildMovingButton → 공통 위젯으로 교체됨

  // ── Movement simulation (임시 — DeviceProvider 연동 전) ──

  void _simulateMovement() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _showMoveCompleteDialog();
    });
  }

  /// Screen 4 — 이동 완료 모달
  /// Figma: 다크 오버레이 + 흰색 텍스트 + 초록 확인 버튼
  void _showMoveCompleteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (dialogContext) => ModalOverlay(
        dismissible: false,
        barrierColor: AppColors.modalOverlayDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '장비의 암이 홈 위치로 이동을 완료하였습니다',
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: '확인',
              variant: ButtonVariant.green,
              size: ButtonSize.medium,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() => _status = HomeStatus.ready);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── 이미지 에셋 로드 실패 시 플레이스홀더 ──

  Widget _imagePlaceholder() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.grayHighlight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.precision_manufacturing,
              size: 80, color: AppColors.grayHighlight),
          const SizedBox(height: 12),
          Text(
            'ROBOARM',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grayHighlight,
            ),
          ),
        ],
      ),
    );
  }
}
