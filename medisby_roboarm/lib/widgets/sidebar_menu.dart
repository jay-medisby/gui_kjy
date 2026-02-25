import 'package:flutter/material.dart';
import '../models/menu_type.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';

class SidebarMenu extends StatelessWidget {
  final MenuType currentMenu;
  final ValueChanged<MenuType> onMenuTap;
  final VoidCallback? onHomeTap;

  const SidebarMenu({
    super.key,
    required this.currentMenu,
    required this.onMenuTap,
    this.onHomeTap,
  });

  // Figma: 메인 메뉴 3개 (시작, 환자, 치료기록)
  static const _primaryMenus = [
    MenuType.start,
    MenuType.patient,
    MenuType.treatmentLog,
  ];

  // Figma: 하단 그룹 (설정, 종료)
  static const _secondaryMenus = [
    MenuType.settings,
    MenuType.exit,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sidebarWidth,
      color: AppColors.background,
      child: Padding(
        // Figma: 사이드바 요소 x=30 시작
        padding: const EdgeInsets.only(left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단: 홈 아이콘 + 로고 (Figma: y=43) ──
            const SizedBox(height: 43),
            _buildHomeHeader(),

            // ── 메인 메뉴 (Figma: y=150, gap=16) ──
            const SizedBox(height: 31),
            ..._buildMenuGroup(_primaryMenus, AppDimensions.gapMenuItems),

            const Spacer(),

            // ── 하단 구분선 + 설정/종료 (Figma: menu_group2) ──
            _buildSeparator(),
            const SizedBox(height: AppDimensions.gapMenuGroup),
            ..._buildMenuGroup(_secondaryMenus, AppDimensions.gapMedium),

            // Figma: 하단 여백 (status bar 위 28px)
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  /// 홈 버튼 + MEDISBY 로고
  Widget _buildHomeHeader() {
    return GestureDetector(
      onTap: onHomeTap,
      child: Row(
      children: [
        // Figma: btn_home 76×76, 원형, 흰색 border 2px
        Container(
          width: AppDimensions.homeButtonSize,
          height: AppDimensions.homeButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textWhite,
              width: AppDimensions.strokeMedium,
            ),
          ),
          child: const Icon(
            Icons.home,
            color: AppColors.textWhite,
            size: 40,
          ),
        ),
        const SizedBox(width: 12),
        // 로고 텍스트 (축약형)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEDISBY',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textWhite,
                fontSize: 14,
              ),
            ),
            Text(
              'ROBOARM',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textWhite,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }

  /// 메뉴 버튼 그룹 빌드
  List<Widget> _buildMenuGroup(List<MenuType> menus, double gap) {
    final widgets = <Widget>[];
    for (var i = 0; i < menus.length; i++) {
      if (i > 0) widgets.add(SizedBox(height: gap));
      widgets.add(_buildMenuButton(menus[i]));
    }
    return widgets;
  }

  /// 개별 메뉴 버튼
  /// Figma: row, padding 10 10 10 16, gap 10, borderRadius 10
  Widget _buildMenuButton(MenuType menu) {
    final isActive = currentMenu == menu;
    final isExit = menu == MenuType.exit;
    final isSecondary = menu == MenuType.settings || menu == MenuType.exit;

    // Figma 색상 매핑
    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isActive) {
      // 활성: 블루 배경 (Figma: #3B82F6)
      backgroundColor = AppColors.blue;
      textColor = AppColors.textWhite;
    } else if (isSecondary) {
      // 하단 그룹: 투명 배경, 테두리 없음
      backgroundColor = Colors.transparent;
      textColor = isExit ? AppColors.textRed : AppColors.textWhite;
    } else {
      // 비활성: Figma rgba(255,255,255,0.05) + border
      backgroundColor = AppColors.buttonInactive;
      textColor = AppColors.textWhite;
      border = Border.all(color: AppColors.borderGray, width: 1);
    }

    return GestureDetector(
      onTap: () => onMenuTap(menu),
      child: Container(
        width: AppDimensions.sidebarMenuButtonWidth,
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          border: isActive ? null : border,
        ),
        child: Row(
          children: [
            Icon(
              menu.icon,
              color: textColor,
              size: AppDimensions.iconSizeDefault,
            ),
            const SizedBox(width: AppDimensions.gapMedium),
            Text(
              menu.label,
              style: AppTextStyles.bodyLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  /// 구분선 (Figma: line 5, stroke rgba(136,153,166,0.5))
  Widget _buildSeparator() {
    return SizedBox(
      width: AppDimensions.sidebarMenuButtonWidth,
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderGray,
      ),
    );
  }
}
