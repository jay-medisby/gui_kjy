import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// 궤적 바 위 북마크 데이터
class TrajectoryBookmark {
  final double position; // 0.0~1.0 (바 내 위치 비율)
  final bool isActive; // true=진한 파란색, false=회색
  final String? label; // 하단 라벨 텍스트

  const TrajectoryBookmark({
    required this.position,
    this.isActive = true,
    this.label,
  });
}

/// 궤적 내 위치 프로그레스 바
/// Figma: Treatment 화면 하단, 924px 너비
///   - 완료 영역: rgba(16,185,129,0.4) — 초록 40% 투명
///   - 미완료 영역: rgba(48,87,185,0.5) — 파랑 50% 투명
///   - 구분선: #6C6A6A (현재 위치 마커)
///   - 라벨: "궤적 시작"(좌측), "궤적 끝"(우측)
///
/// value: 0.0~1.0 (궤적 내 현재 위치 비율)
class TrajectoryProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final String startLabel;
  final String endLabel;
  final List<TrajectoryBookmark> bookmarks;

  const TrajectoryProgressBar({
    super.key,
    required this.value,
    this.height = 32,
    this.startLabel = '궤적 시작',
    this.endLabel = '궤적 끝',
    this.bookmarks = const [],
  });

  static const _bookmarkSize = 20.0;
  static const _activeBookmarkColor = Color(0xFF3057B9);
  static const _inactiveBookmarkColor = AppColors.grayHighlight;

  @override
  Widget build(BuildContext context) {
    const completedColor = Color(0xFF10B981); // rgb(16,185,129) 불투명
    const remainingColor = Color(0x263057B9); // rgba(48,87,185,0.15)
    const markerColor = AppColors.trajectoryMarker;
    const trackBorderColor = AppColors.grayHighlight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 프로그레스 바 본체 (북마크 포함) ──
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final completedWidth = totalWidth * value.clamp(0.0, 1.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 바 본체
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          // 전체 배경 (미완료)
                          Container(
                            width: totalWidth,
                            height: height,
                            decoration: BoxDecoration(
                              color: remainingColor,
                              border: Border.all(
                                color: trackBorderColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),

                          // 완료 영역 (좌측)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: completedWidth,
                            height: height,
                            decoration: BoxDecoration(
                              color: completedColor,
                              borderRadius: BorderRadius.horizontal(
                                left: const Radius.circular(6),
                                right: value >= 1.0
                                    ? const Radius.circular(6)
                                    : Radius.zero,
                              ),
                            ),
                          ),

                          // 현재 위치 마커 (세로선)
                          if (value > 0 && value < 1.0)
                            Positioned(
                              left: completedWidth - 1.5,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3,
                                color: markerColor,
                              ),
                            ),

                          // 현재 위치 도트
                          if (value > 0 && value < 1.0)
                            Positioned(
                              left: completedWidth - 6,
                              top: height / 2 - 6,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.green,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardBlack
                                          .withValues(alpha: 0.25),
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── 북마크 아이콘 (바 상하 중앙) ──
                  for (final bm in bookmarks)
                    Positioned(
                      left: (totalWidth * bm.position.clamp(0.0, 1.0) -
                              _bookmarkSize / 2)
                          .clamp(0.0, totalWidth - _bookmarkSize),
                      top: (height - _bookmarkSize) / 2,
                      child: Icon(
                        Icons.bookmark,
                        size: _bookmarkSize,
                        color: bm.isActive
                            ? _activeBookmarkColor
                            : _inactiveBookmarkColor,
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // ── 라벨 ──
        bookmarks.isEmpty ? _buildSimpleLabels() : _buildBookmarkLabels(),
      ],
    );
  }

  /// 북마크 없을 때: 기존 라벨
  Widget _buildSimpleLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          startLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textBlack,
            fontSize: 18,
          ),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.green,
            fontSize: 18,
          ),
        ),
        Text(
          endLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textBlack,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  /// 북마크 있을 때: startLabel + 북마크 라벨들을 position 기반으로 배치
  Widget _buildBookmarkLabels() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return SizedBox(
          width: totalWidth,
          height: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 시작 라벨 (좌측)
              Positioned(
                left: 0,
                child: Text(
                  startLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textBlack,
                    fontSize: 18,
                  ),
                ),
              ),
              // 각 북마크 라벨
              for (final bm in bookmarks)
                if (bm.label != null)
                  Positioned(
                    left: bm.position >= 1.0
                        ? null
                        : totalWidth * bm.position.clamp(0.0, 1.0),
                    right: bm.position >= 1.0 ? 0 : null,
                    child: bm.position >= 1.0 || bm.position <= 0.0
                        ? Text(
                            bm.label!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textBlack,
                              fontSize: 18,
                            ),
                          )
                        : FractionalTranslation(
                            translation: const Offset(-0.5, 0),
                            child: Text(
                              bm.label!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textBlack,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
