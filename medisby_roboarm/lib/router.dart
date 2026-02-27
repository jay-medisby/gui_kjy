import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/menu_type.dart';
import 'providers/device_provider.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/device_status_badge.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/go_home_flow.dart';
import 'screens/settings/settings_flow.dart';
import 'screens/pre_treatment/pre_treatment_flow.dart';
import 'screens/treatment/treatment_dashboard.dart';
import 'screens/treatment/treatment_result_screen.dart';
import 'screens/exit/exit_flow.dart';
import 'screens/dev/dev_catalog_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Dev Catalog (사이드바 없이 독립 페이지) ──
    GoRoute(
      path: '/dev',
      builder: (context, state) => const DevCatalogScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        final menu = _menuFromLocation(location);
        final device = context.watch<DeviceProvider>();

        return AppScaffold(
          currentMenu: menu,
          onMenuTap: (menu) => _handleMenuTap(context, menu),
          onHomeTap: () => _handleHomeTap(context, location),
          isConnected: device.isConnected,
          deviceStatus: _effectiveStatus(location, device),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/pre-treatment',
          builder: (context, state) => const PreTreatmentFlow(),
        ),
        GoRoute(
          path: '/treatment',
          builder: (context, state) => const TreatmentDashboard(),
          routes: [
            GoRoute(
              path: 'result',
              builder: (context, state) => const TreatmentResultScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// 현재 라우트 경로 → 사이드바 활성 메뉴 매핑
MenuType _menuFromLocation(String location) {
  if (location.startsWith('/pre-treatment')) return MenuType.start;
  if (location.startsWith('/treatment')) return MenuType.start;
  return MenuType.start; // '/' → Home
}

/// 사이드바 메뉴 탭 → 라우트 이동 or 모달
void _handleMenuTap(BuildContext context, MenuType menu) {
  switch (menu) {
    case MenuType.start:
      // 시작 → Pre-treatment(12단계) → Treatment(대시보드) 순차 진행
      context.go('/pre-treatment');
    case MenuType.settings:
      SettingsFlow.show(context);
    case MenuType.exit:
      ExitFlow.show(context);
    case MenuType.patient:
    case MenuType.treatmentLog:
      // TODO: Phase 미구현
      break;
  }
}

/// 경로 + DeviceProvider 상태 → 실제 표시할 DeviceStatus
/// Home('/')에서는 HomeScreen이 provider를 갱신하므로 그대로 사용,
/// 다른 경로는 경로 기반으로 결정
DeviceStatus _effectiveStatus(String location, DeviceProvider device) {
  if (location == '/') return device.status;
  if (location.startsWith('/pre-treatment')) return DeviceStatus.readySetting;
  if (location == '/treatment/result') return DeviceStatus.returning;
  if (location.startsWith('/treatment')) return DeviceStatus.run;
  return device.status;
}

/// 홈 아이콘 탭 — 치료/준비 중이면 GoHomeFlow 확인, 아니면 홈 이동
void _handleHomeTap(BuildContext context, String location) {
  if (location.startsWith('/treatment') ||
      location.startsWith('/pre-treatment')) {
    GoHomeFlow.show(context);
  } else {
    context.go('/');
  }
}
