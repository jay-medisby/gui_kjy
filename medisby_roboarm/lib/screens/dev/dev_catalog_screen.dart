import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../models/menu_type.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/device_status_badge.dart';
import '../../widgets/confirm_dialog.dart';

// ── Screens ──
import '../home/home_screen.dart';
import '../pre_treatment/pre_treatment_flow.dart';
import '../treatment/treatment_dashboard.dart';
import '../treatment/trajectory_add_flow.dart';
import '../treatment/treatment_result_screen.dart';
import '../settings/settings_flow.dart';
import '../exit/exit_flow.dart';
import '../home/go_home_flow.dart';
import '../emergency/stop_flow.dart';

/// /#/dev — 버튼 기반 개발 카탈로그
/// 일반 플로우에서 접근하기 어려운 화면에 바로 진입할 수 있도록 제공
class DevCatalogScreen extends StatelessWidget {
  const DevCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  const Icon(Icons.developer_mode,
                      color: AppColors.green, size: 28),
                  const SizedBox(width: 12),
                  Text('Dev Catalog',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textWhite)),
                  const Spacer(),
                  _ActionChip(
                    icon: Icons.home,
                    label: 'Go to App',
                    onTap: () => context.go('/'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('실행 중 접근하기 어려운 화면에 바로 진입할 수 있습니다.',
                  style: AppTextStyles.captionLight
                      .copyWith(color: Colors.white54)),
              const SizedBox(height: 24),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Home Screen 상태별 ──
                      _SectionHeader(title: 'Home Screen 상태'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _CatalogButton(
                            icon: Icons.play_arrow,
                            label: 'Screen 1→5',
                            description: '순차 진행 (초기화→완료)',
                            color: AppColors.green,
                            onTap: () => _pushScreen(
                                context,
                                'Home — Screen 1→5',
                                const HomeScreen(
                                    initialStatus: HomeStatus.initializing),
                                deviceStatus: DeviceStatus.online),
                          ),
                          _CatalogButton(
                            icon: Icons.hourglass_top,
                            label: 'Initializing',
                            description: '초기화 중',
                            color: AppColors.blue,
                            onTap: () => _pushScreen(
                                context,
                                'Home — Initializing',
                                const HomeScreen(
                                    initialStatus: HomeStatus.initializing),
                                deviceStatus: DeviceStatus.online),
                          ),
                          _CatalogButton(
                            icon: Icons.error,
                            label: 'Arm Not Home',
                            description: '원점 이탈 상태',
                            color: const Color(0xFF1565C0),
                            onTap: () => _pushScreen(
                                context,
                                'Home — Arm Not Home',
                                const HomeScreen(
                                    initialStatus: HomeStatus.armNotHome),
                                deviceStatus: DeviceStatus.online),
                          ),
                          _CatalogButton(
                            icon: Icons.sync,
                            label: 'Moving',
                            description: '이동 중',
                            color: AppColors.blue,
                            onTap: () => _pushScreen(
                                context,
                                'Home — Moving',
                                const HomeScreen(
                                    initialStatus: HomeStatus.moving),
                                deviceStatus: DeviceStatus.online),
                          ),
                          _CatalogButton(
                            icon: Icons.check_circle,
                            label: 'Move Complete',
                            description: '이동 완료',
                            color: AppColors.green,
                            onTap: () => showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              barrierDismissible: false,
                              builder: (dialogContext) => ConfirmDialog(
                                title: '장비의 암이 홈 위치로 이동을 완료하였습니다',
                                confirmLabel: '확인',
                                onConfirm: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                            ),
                          ),
                          _CatalogButton(
                            icon: Icons.check_circle_outline,
                            label: 'Ready',
                            description: '준비 완료 상태',
                            color: AppColors.green,
                            onTap: () => _pushScreen(
                                context,
                                'Home — Ready',
                                const HomeScreen(
                                    initialStatus: HomeStatus.ready)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── 주요 화면 ──
                      _SectionHeader(title: '주요 화면'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _CatalogButton(
                            icon: Icons.playlist_play,
                            label: 'PreTreatment',
                            description: '치료 준비 12단계',
                            color: AppColors.blue,
                            onTap: () => _pushScreen(context,
                                'PreTreatmentFlow', const PreTreatmentFlow(),
                                deviceStatus: DeviceStatus.readySetting),
                          ),
                          _CatalogButton(
                            icon: Icons.monitor_heart,
                            label: 'Treatment',
                            description: '치료 대시보드',
                            color: AppColors.green,
                            onTap: () => _pushScreen(
                                context,
                                'TreatmentDashboard',
                                const TreatmentDashboard(),
                                deviceStatus: DeviceStatus.run),
                          ),
                          _CatalogButton(
                            icon: Icons.add_road,
                            label: 'Trajectory Add',
                            description: '궤적 추가',
                            color: AppColors.blue,
                            onTap: () => TrajectoryAddFlow.show(context),
                          ),
                          _CatalogButton(
                            icon: Icons.assessment,
                            label: 'Treatment Result',
                            description: '치료 결과',
                            color: AppColors.green,
                            onTap: () => _pushScreen(
                                context,
                                'TreatmentResultScreen',
                                const TreatmentResultScreen(),
                                deviceStatus: DeviceStatus.returning),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── 모달 플로우 ──
                      _SectionHeader(title: '모달 플로우'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _CatalogButton(
                            icon: Icons.settings,
                            label: 'Settings',
                            description: '설정',
                            color: Colors.white70,
                            onTap: () => SettingsFlow.show(context),
                          ),
                          _CatalogButton(
                            icon: Icons.logout,
                            label: 'Exit',
                            description: '종료 플로우',
                            color: AppColors.red,
                            onTap: () => ExitFlow.show(context),
                          ),
                          _CatalogButton(
                            icon: Icons.home_outlined,
                            label: 'Go Home',
                            description: '홈 복귀 플로우',
                            color: AppColors.green,
                            onTap: () => GoHomeFlow.show(context),
                          ),
                          _CatalogButton(
                            icon: Icons.emergency,
                            label: 'Emergency Stop',
                            description: '비상정지',
                            color: AppColors.emergencyAccent,
                            onTap: () =>
                                StopFlow.show(context, StopType.emergency),
                          ),
                          _CatalogButton(
                            icon: Icons.shield_outlined,
                            label: 'Safe Stop',
                            description: '보호정지',
                            color: AppColors.safeAccent,
                            onTap: () =>
                                StopFlow.show(context, StopType.safe),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 화면을 풀스크린 오버레이로 띄움 (뒤로가기 가능)
  void _pushScreen(
    BuildContext context,
    String title,
    Widget screen, {
    DeviceStatus deviceStatus = DeviceStatus.ready,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ScreenWrapper(
          title: title,
          initialDeviceStatus: deviceStatus,
          child: screen,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Private Widgets
// ═══════════════════════════════════════════════════════════

/// 화면 래핑 — AppScaffold(사이드바) + 뒤로가기 버튼
class _ScreenWrapper extends StatefulWidget {
  final String title;
  final Widget child;
  final DeviceStatus initialDeviceStatus;

  const _ScreenWrapper({
    required this.title,
    required this.child,
    this.initialDeviceStatus = DeviceStatus.ready,
  });

  @override
  State<_ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<_ScreenWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeviceProvider>().setStatus(widget.initialDeviceStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<DeviceProvider>().status;
    return AppScaffold(
      currentMenu: MenuType.start,
      onMenuTap: (_) {},
      onHomeTap: () => Navigator.of(context).pop(),
      deviceStatus: status,
      child: Stack(
        children: [
          widget.child,
          // 뒤로가기 버튼
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Dev Catalog',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite)),
      ],
    );
  }
}

/// 카탈로그 버튼
class _CatalogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _CatalogButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        hoverColor: color.withValues(alpha: 0.12),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textWhite)),
              const SizedBox(height: 4),
              Text(description,
                  style: AppTextStyles.captionLight
                      .copyWith(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 상단 액션 칩
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
