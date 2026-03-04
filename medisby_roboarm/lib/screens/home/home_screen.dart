import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/content_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/device_status_badge.dart';
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
  final HomeStatus? initialStatus;
  const HomeScreen({super.key, this.initialStatus});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeStatus _status = widget.initialStatus ?? HomeStatus.ready;

  @override
  void initState() {
    super.initState();
    _syncDeviceStatus();
    if (_status == HomeStatus.initializing) {
      _simulateInitializing();
    }
  }

  /// HomeStatus → DeviceStatus 동기화
  void _syncDeviceStatus() {
    final deviceStatus = _status == HomeStatus.ready
        ? DeviceStatus.ready
        : DeviceStatus.online;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeviceProvider>().setStatus(deviceStatus);
    });
  }

  void _setStatus(HomeStatus newStatus) {
    setState(() => _status = newStatus);
    _syncDeviceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Dev Catalog 버튼 (우측 상단) ──
        Positioned(
          top: 3,
          right: 35,
          child: Material(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/dev'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.developer_mode, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('Go to Dev Catalog',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── 메인 콘텐츠 ──
        Padding(
      // Figma: contentsaria x=261(→31 from sidebar), y=123, 984×549
      padding: const EdgeInsets.fromLTRB(31, 123, 35, 19),
      child: ContentCard(
        padding: const EdgeInsets.fromLTRB(24, 24, 40, 24),
        child: Row(
          children: [
            // ── Left: Robot image ──
            SizedBox(
              width: 450,
              child: Center(
                child: Image.asset(
                  'assets/images/roboarm.png',
                  width: 450,
                  height: 450,
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
    ),
      ],
    );
  }

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
      HomeStatus.moving => _buildArmNotHomeContent(),
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
          Icons.error, '암이 홈 위치에 있지 않습니다', const Color(0xFF1565C0)),
      const SizedBox(height: 16),
      Padding(
        padding: _descIndent,
        child: Text(
          '버튼을 길게 눌러서 장비의 암을\n홈 위치로 이동시켜 주세요.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textBlack),
        ),
      ),
      const SizedBox(height: 20),
      const WarningBox(iconSize: 20, compact: true),
      const SizedBox(height: 12),
      LongPressMoveButton(
        onComplete: _showMoveCompleteDialog,
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          '이동을 멈추려면 즉시 버튼에서 손을 떼주세요',
          style: AppTextStyles.captionLight.copyWith(color: AppColors.textBlack),
        ),
      ),
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
              '장비의 암이 홈 위치에 있습니다.',
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

  // ── Simulation (임시 — DeviceProvider 연동 전) ──

  void _simulateInitializing() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _setStatus(HomeStatus.armNotHome);
    });
  }

  /// Screen 4 — 이동 완료 모달
  void _showMoveCompleteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (dialogContext) => ConfirmDialog(
        title: '장비의 암이 홈 위치로 이동을 완료하였습니다',
        confirmLabel: '확인',
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _setStatus(HomeStatus.ready);
        },
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
