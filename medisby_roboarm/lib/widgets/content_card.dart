import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/dimensions.dart';

/// 흰색 라운드 카드 컨테이너
/// Figma: contentsaria 984×549, fill #FFFFFF
/// 대부분의 화면에서 메인 콘텐츠를 감싸는 용도
class ContentCard extends StatelessWidget {
  final Widget child;

  /// null이면 contentsaria 기본 크기 (984×549) 사용
  final double? width;
  final double? height;

  /// Figma 기본값: 16px (CLAUDE.md 기준), contentsaria는 borderRadius 없음
  /// Settings/Admin 내부 카드에서 borderRadius 20px 사용
  final double borderRadius;

  final EdgeInsetsGeometry padding;

  const ContentCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(AppDimensions.cardPaddingLarge),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: child,
    );
  }
}
