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

  const SettingsModalBase({
    super.key,
    required this.title,
    this.breadcrumb,
    this.showBack = false,
    this.showClose = true,
    this.onBack,
    this.onClose,
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
          color: AppColors.settingsCardBg,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: Stack(
          children: [
            // ── 메인 콘텐츠 ──
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // 타이틀 영역
                  _buildTitleBar(),
                  const SizedBox(height: 20),
                  // 콘텐츠 영역
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),

            // ── 뒤로가기 아이콘 (모달 외부 왼쪽) ──
            if (showBack)
              Positioned(
                left: -60,
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 40),
          ...breadcrumb!.map((item) {
            if (item.isCurrent) {
              return Text(
                item.label,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textWhite,
                ),
              );
            }
            return Row(
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
            );
          }),
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
