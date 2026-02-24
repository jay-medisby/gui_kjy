import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 반투명 어두운 오버레이 + 중앙 child 배치
/// Figma: overlay_dimmer rgba(0,0,0,0.6) 전체 1280×720
/// modal_card: 970×544, 위치 x=155, y=88 → 화면 중앙
///
/// 사용법:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.transparent, // ModalOverlay가 자체 배경 처리
///   builder: (_) => ModalOverlay(child: yourContent),
/// );
/// ```
class ModalOverlay extends StatelessWidget {
  final Widget child;

  /// true이면 배경 탭으로 닫기 가능
  final bool dismissible;

  /// 오버레이 배경 색상 (기본: rgba(0,0,0,0.6))
  final Color barrierColor;

  const ModalOverlay({
    super.key,
    required this.child,
    this.dismissible = true,
    this.barrierColor = AppColors.modalOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: dismissible ? () => Navigator.of(context).pop() : null,
        child: Container(
          color: barrierColor,
          alignment: Alignment.center,
          child: GestureDetector(
            // child 영역 탭 시 dismiss 방지
            onTap: () {},
            child: child,
          ),
        ),
      ),
    );
  }
}
