import 'package:flutter/material.dart';

// ── Widgets ──
import '../widgets/app_button.dart';
import '../widgets/gauge_meter.dart';
import '../widgets/circular_progress.dart';
import '../widgets/trajectory_progress_bar.dart';
import '../widgets/step_indicator.dart';
import '../widgets/device_status_badge.dart';
import '../widgets/content_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/warning_box.dart';
import '../widgets/joint_selector.dart';

// ── Screens ──
import '../screens/home/home_screen.dart';
import '../screens/pre_treatment/pre_treatment_flow.dart';
import '../screens/treatment/treatment_dashboard.dart';
import '../screens/treatment/trajectory_add_flow.dart';
import '../screens/treatment/treatment_result_screen.dart';
import '../screens/settings/settings_flow.dart';
import '../screens/exit/exit_flow.dart';
import '../screens/home/go_home_flow.dart';
import '../screens/emergency/stop_flow.dart';

// ── Theme ──
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// /#/dev 카탈로그 — 위젯/화면 미리보기용 개발 도구
class DevCatalogScreen extends StatefulWidget {
  const DevCatalogScreen({super.key});

  @override
  State<DevCatalogScreen> createState() => _DevCatalogScreenState();
}

class _DevCatalogScreenState extends State<DevCatalogScreen> {
  int _selectedIndex = 0;

  static final List<_CatalogEntry> _entries = [
    // ── Widgets ──
    _CatalogEntry.header('Widgets'),
    _CatalogEntry.item('AppButton — All Variants', () {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final variant in ButtonVariant.values)
              for (final size in ButtonSize.values)
                AppButton(
                  label: '${variant.name} ${size.name}',
                  variant: variant,
                  size: size,
                ),
          ],
        ),
      );
    }),
    _CatalogEntry.item('GaugeMeter', () {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GaugeMeter(value: 0.25, label: '부하도', unit: '%'),
          GaugeMeter(value: 0.60, label: '부하도', unit: '%'),
          GaugeMeter(value: 0.90, label: '부하도', unit: '%'),
        ],
      );
    }),
    _CatalogEntry.item('CircularProgress', () {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularProgress(value: 0.45),
          CircularProgress(value: 1.0, centerLabel: '완료'),
        ],
      );
    }),
    _CatalogEntry.item('TrajectoryProgressBar', () {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: TrajectoryProgressBar(value: 0.45),
      );
    }),
    _CatalogEntry.item('StepIndicator', () {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StepIndicator(currentStep: 3, totalSteps: 12),
          StepIndicator(currentStep: 11, totalSteps: 12),
        ],
      );
    }),
    _CatalogEntry.item('DeviceStatusBadge', () {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final s in DeviceStatus.values) DeviceStatusBadge(status: s),
        ],
      );
    }),
    _CatalogEntry.item('ContentCard', () {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ContentCard(
          child: Center(
            child: Text('Content Area',
                style: TextStyle(color: Colors.black, fontSize: 24)),
          ),
        ),
      );
    }),
    _CatalogEntry.item('ConfirmDialog', () {
      return const Center(
        child: ConfirmDialog(
          title: '장비 초기화',
          message: '초기화를 진행하시겠습니까?\n모든 설정이 초기화됩니다.',
          confirmLabel: '확인',
          cancelLabel: '취소',
        ),
      );
    }),
    _CatalogEntry.item('WarningBox', () {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: WarningBox(),
      );
    }),
    _CatalogEntry.item('JointSelector', () {
      return Center(
          child: JointSelector(selectedJoint: 3, onJointSelected: (_) {}));
    }),

    // ── Screens ──
    _CatalogEntry.header('Screens'),
    _CatalogEntry.item('Home — Ready',
        () => const HomeScreen(initialStatus: HomeStatus.ready)),
    _CatalogEntry.item('Home — Initializing',
        () => const HomeScreen(initialStatus: HomeStatus.initializing)),
    _CatalogEntry.item('Home — Arm Not Home',
        () => const HomeScreen(initialStatus: HomeStatus.armNotHome)),
    _CatalogEntry.item('Home — Moving',
        () => const HomeScreen(initialStatus: HomeStatus.moving)),
    _CatalogEntry.item(
        'PreTreatmentFlow', () => const PreTreatmentFlow()),
    _CatalogEntry.item(
        'TreatmentDashboard', () => const TreatmentDashboard()),
    _CatalogEntry.item(
        'TrajectoryAddFlow', () => const TrajectoryAddFlow()),
    _CatalogEntry.item(
        'TreatmentResultScreen', () => const TreatmentResultScreen()),
    _CatalogEntry.item('SettingsFlow', () => const SettingsFlow()),
    _CatalogEntry.item('ExitFlow', () => const ExitFlow()),
    _CatalogEntry.item('GoHomeFlow', () => const GoHomeFlow()),
    _CatalogEntry.item('Emergency Stop',
        () => const StopFlow(type: StopType.emergency)),
    _CatalogEntry.item(
        'Safe Stop', () => const StopFlow(type: StopType.safe)),
  ];

  /// 실제 아이템만 (헤더 제외)
  List<_CatalogEntry> get _items =>
      _entries.where((e) => !e.isHeader).toList();

  @override
  Widget build(BuildContext context) {
    final selectedItem = _items[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── 좌측: 카탈로그 목록 ──
          Container(
            width: 260,
            color: AppColors.sidebarBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Dev Catalog',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textWhite)),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(child: _buildList()),
              ],
            ),
          ),
          // ── 우측: 미리보기 영역 ──
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: selectedItem.builder!(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    int itemIndex = 0;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final entry in _entries)
          if (entry.isHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(entry.name,
                  style: AppTextStyles.captionLight
                      .copyWith(color: Colors.white54, fontSize: 11)),
            )
          else
            _buildTile(entry, itemIndex++),
      ],
    );
  }

  Widget _buildTile(_CatalogEntry entry, int index) {
    final isSelected = index == _selectedIndex;
    return Material(
      color: isSelected ? AppColors.green.withValues(alpha: 0.2) : Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (isSelected)
                Container(
                  width: 3,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Expanded(
                child: Text(entry.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.textWhite
                          : Colors.white70,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogEntry {
  final String name;
  final Widget Function()? builder;
  final bool isHeader;

  const _CatalogEntry.item(this.name, this.builder) : isHeader = false;
  const _CatalogEntry.header(this.name)
      : builder = null,
        isHeader = true;
}
