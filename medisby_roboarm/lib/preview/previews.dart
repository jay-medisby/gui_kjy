import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'preview_helpers.dart';

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

// ════════════════════════════════════════════
// Widgets
// ════════════════════════════════════════════

@Preview(name: 'AppButton — All Variants', wrapper: previewWrapper, size: Size(1200, 700))
Widget appButtonShowcase() {
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
}

@Preview(name: 'GaugeMeter — 25%', wrapper: previewWrapper, size: Size(250, 250))
Widget gaugeLow() => const Center(child: GaugeMeter(value: 0.25, label: '부하도', unit: '%'));

@Preview(name: 'GaugeMeter — 60%', wrapper: previewWrapper, size: Size(250, 250))
Widget gaugeMid() => const Center(child: GaugeMeter(value: 0.60, label: '부하도', unit: '%'));

@Preview(name: 'GaugeMeter — 90%', wrapper: previewWrapper, size: Size(250, 250))
Widget gaugeHigh() => const Center(child: GaugeMeter(value: 0.90, label: '부하도', unit: '%'));

@Preview(name: 'CircularProgress — 45%', wrapper: previewWrapper, size: Size(250, 250))
Widget circularProgress45() => const Center(child: CircularProgress(value: 0.45));

@Preview(name: 'CircularProgress — 100%', wrapper: previewWrapper, size: Size(250, 250))
Widget circularProgress100() => const Center(child: CircularProgress(value: 1.0, centerLabel: '완료'));

@Preview(name: 'TrajectoryProgressBar', wrapper: previewWrapper, size: Size(924, 100))
Widget trajectoryBar() => const Padding(
  padding: EdgeInsets.all(20),
  child: TrajectoryProgressBar(value: 0.45),
);

@Preview(name: 'StepIndicator — 3/12', wrapper: previewWrapper, size: Size(500, 60))
Widget stepIndicator3() => const Center(child: StepIndicator(currentStep: 3, totalSteps: 12));

@Preview(name: 'StepIndicator — 11/12', wrapper: previewWrapper, size: Size(500, 60))
Widget stepIndicator11() => const Center(child: StepIndicator(currentStep: 11, totalSteps: 12));

@Preview(name: 'DeviceStatusBadge — All States', wrapper: previewWrapper, size: Size(800, 100))
Widget deviceStatusAll() => Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    for (final s in DeviceStatus.values) DeviceStatusBadge(status: s),
  ],
);

@Preview(name: 'ContentCard', wrapper: previewWrapper, size: Size(600, 300))
Widget contentCardPreview() => const Padding(
  padding: EdgeInsets.all(20),
  child: ContentCard(
    child: Center(child: Text('Content Area', style: TextStyle(color: Colors.black, fontSize: 24))),
  ),
);

@Preview(name: 'ConfirmDialog', wrapper: previewWrapper, size: Size(1050, 620))
Widget confirmDialogPreview() => const Center(
  child: ConfirmDialog(
    title: '장비 초기화',
    message: '초기화를 진행하시겠습니까?\n모든 설정이 초기화됩니다.',
    confirmLabel: '확인',
    cancelLabel: '취소',
  ),
);

@Preview(name: 'WarningBox — boxed', wrapper: previewWrapper, size: Size(600, 80))
Widget warningBoxed() => const Padding(
  padding: EdgeInsets.all(16),
  child: WarningBox(boxed: true),
);

@Preview(name: 'WarningBox — inline', wrapper: previewWrapper, size: Size(600, 60))
Widget warningInline() => const Padding(
  padding: EdgeInsets.all(16),
  child: WarningBox(boxed: false),
);

@Preview(name: 'JointSelector', wrapper: previewWrapper, size: Size(500, 400))
Widget jointSelectorPreview() => Center(child: JointSelector(selectedJoint: 3, onJointSelected: (_) {}));

// ════════════════════════════════════════════
// Screens
// ════════════════════════════════════════════

@Preview(name: 'Home — Ready', wrapper: previewWrapper, size: Size(1050, 720))
Widget homeReady() => const HomeScreen(initialStatus: HomeStatus.ready);

@Preview(name: 'Home — Initializing', wrapper: previewWrapper, size: Size(1050, 720))
Widget homeInit() => const HomeScreen(initialStatus: HomeStatus.initializing);

@Preview(name: 'Home — Arm Not Home', wrapper: previewWrapper, size: Size(1050, 720))
Widget homeArmNotHome() => const HomeScreen(initialStatus: HomeStatus.armNotHome);

@Preview(name: 'Home — Moving', wrapper: previewWrapper, size: Size(1050, 720))
Widget homeMoving() => const HomeScreen(initialStatus: HomeStatus.moving);

@Preview(name: 'PreTreatmentFlow', wrapper: previewWrapper, size: Size(1050, 720))
Widget preTreatment() => const PreTreatmentFlow();

@Preview(name: 'TreatmentDashboard', wrapper: previewWrapper, size: Size(1050, 720))
Widget treatmentDashboard() => const TreatmentDashboard();

@Preview(name: 'TrajectoryAddFlow', wrapper: previewWrapper, size: Size(1050, 720))
Widget trajectoryAdd() => const TrajectoryAddFlow();

@Preview(name: 'TreatmentResultScreen', wrapper: previewWrapper, size: Size(1050, 720))
Widget treatmentResult() => const TreatmentResultScreen();

@Preview(name: 'SettingsFlow', wrapper: previewWrapper, size: Size(1280, 720))
Widget settingsFlow() => const SettingsFlow();

@Preview(name: 'ExitFlow', wrapper: previewWrapper, size: Size(1280, 720))
Widget exitFlow() => const ExitFlow();

@Preview(name: 'GoHomeFlow', wrapper: previewWrapper, size: Size(1280, 720))
Widget goHomeFlow() => const GoHomeFlow();

@Preview(name: 'Emergency Stop', wrapper: previewWrapper, size: Size(1280, 720))
Widget emergencyStop() => const StopFlow(type: StopType.emergency);

@Preview(name: 'Safe Stop', wrapper: previewWrapper, size: Size(1280, 720))
Widget safeStop() => const StopFlow(type: StopType.safe);
