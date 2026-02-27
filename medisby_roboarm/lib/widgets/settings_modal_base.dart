import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';
import 'modal_overlay.dart';

/// Settings/Admin 다크 배경 모달 컨테이너
/// 스크린샷: 03_setting ~ 24_veltest — 모두 동일한 다크 카드(970×544) 사용
///
/// [title] 상단 중앙 흰색 타이틀
/// [breadcrumb] "관리자 모드 > 가동범위 테스트" 형태 (optional)
/// [showBack] ← 아이콘 표시 여부
/// [showClose] X 아이콘 표시 여부
/// [onBack] 뒤로가기 콜백
/// [onClose] 닫기 콜백
/// [child] 모달 내부 콘텐츠
class SettingsModalBase extends StatelessWidget {
  final String title;
  final List<BreadcrumbItem>? breadcrumb;
  final bool showBack;
  final bool showClose;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final Widget child;
  final Color? backgroundColor;

  const SettingsModalBase({
    super.key,
    required this.title,
    this.breadcrumb,
    this.showBack = false,
    this.showClose = true,
    this.onBack,
    this.onClose,
    this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ModalOverlay(
      dismissible: false,
      child: Container(
        width: AppDimensions.modalCardWidth,
        height: AppDimensions.modalCardHeight,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── 메인 콘텐츠 ──
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: child,
              ),
            ),

            // ── 타이틀 (콘텐츠 레이아웃에 영향 없음) ──
            if (title.isNotEmpty || (breadcrumb != null && breadcrumb!.isNotEmpty))
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: _buildTitleBar(),
              ),

            // ── 뒤로가기 아이콘 (X 버튼과 대칭) ──
            if (showBack)
              Positioned(
                left: 24,
                top: 24,
                child: GestureDetector(
                  onTap: onBack,
                  child: const Icon(
                    Icons.arrow_back,
                    size: 42,
                    color: AppColors.textWhite,
                  ),
                ),
              ),

            // ── 닫기 아이콘 ──
            if (showClose)
              Positioned(
                right: 24,
                top: 24,
                child: GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    size: 42,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    if (breadcrumb != null && breadcrumb!.isNotEmpty) {
      final prefixItems = breadcrumb!.where((item) => !item.isCurrent).toList();
      final currentItem = breadcrumb!.firstWhere((item) => item.isCurrent, orElse: () => breadcrumb!.last);

      return Row(
        children: [
          // 왼쪽: prefix를 오른쪽 정렬 → 현재 페이지 바로 옆에 붙음
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: prefixItems.map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: item.onTap,
                    child: Text(
                      item.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.green,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.textWhite,
                      size: 24,
                    ),
                  ),
                ],
              )).toList(),
            ),
          ),
          // 가운데: 현재 페이지 이름
          Text(
            currentItem.label,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          // 오른쪽: 대칭을 위한 빈 공간
          const Expanded(child: SizedBox()),
        ],
      );
    }

    return Text(
      title,
      style: AppTextStyles.displayMedium,
      textAlign: TextAlign.center,
    );
  }
}

/// 브레드크럼 항목
class BreadcrumbItem {
  final String label;
  final bool isCurrent;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.isCurrent = false,
    this.onTap,
  });
}
