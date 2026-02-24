import 'package:flutter/material.dart';
import '../models/menu_type.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';
import 'device_status_badge.dart';
import 'sidebar_menu.dart';
import 'status_bar.dart';

class AppScaffold extends StatelessWidget {
  /// 메인 콘텐츠 영역에 표시할 위젯
  final Widget child;

  /// 현재 활성 메뉴
  final MenuType currentMenu;

  /// 메뉴 탭 콜백
  final ValueChanged<MenuType> onMenuTap;

  /// 장비 연결 상태
  final bool isConnected;

  /// 장비 상태 (우상단 배지)
  final DeviceStatus deviceStatus;

  /// 홈 아이콘 탭 콜백
  final VoidCallback? onHomeTap;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentMenu,
    required this.onMenuTap,
    this.isConnected = true,
    this.deviceStatus = DeviceStatus.ready,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Figma: 1280×720 고정 레이아웃
        child: SizedBox(
          width: AppDimensions.screenWidth,
          height: AppDimensions.screenHeight,
          child: ColoredBox(
            color: AppColors.background,
            child: Column(
              children: [
                // ── 메인 영역 (사이드바 + 콘텐츠) ──
                Expanded(
                  child: Row(
                    children: [
                      // 좌측: 사이드바 (Figma: ~230px)
                      SidebarMenu(
                        currentMenu: currentMenu,
                        onMenuTap: onMenuTap,
                        onHomeTap: onHomeTap,
                      ),

                      // 우측: 상태 배지 + 메인 콘텐츠
                      Expanded(
                        child: Stack(
                          children: [
                            // 메인 콘텐츠 (Figma: contentsaria x=261, y=123)
                            Positioned.fill(
                              child: child,
                            ),

                            // 우상단: DeviceStatusBadge
                            // Figma: x=1076, y=42 → 우측 상단 고정
                            Positioned(
                              top: 42,
                              right: 34, // 1280 - 1076 - 170 = 34
                              child: DeviceStatusBadge(status: deviceStatus),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 하단: 상태바 (Figma: y=691, h=29) ──
                StatusBar(isConnected: isConnected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
