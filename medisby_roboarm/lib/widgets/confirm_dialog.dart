import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';
import 'modal_overlay.dart';
import 'app_button.dart';

/// 확인/취소 다이얼로그
/// Figma: modal_card 970×544 위에
///   - 제목: x=224, y=30, 42px bold, 중앙 정렬
///   - 닫기 아이콘: x=890, y=24, 48×48
///   - 뒤로가기: x=29, y=32, 39×39 (선택적)
///   - 확인 버튼: btn_multi 218×70, borderRadius 35
///
/// 사용법:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.transparent,
///   builder: (_) => ConfirmDialog(
///     title: '장비 초기화',
///     message: '초기화를 진행하시겠습니까?',
///     confirmLabel: '확인',
///     onConfirm: () => Navigator.pop(context, true),
///   ),
/// );
/// ```
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final ButtonVariant confirmVariant;
  final ButtonVariant cancelVariant;

  /// true이면 좌상단 뒤로가기 아이콘 표시
  final bool showBack;

  /// 확인 버튼 아래 또는 메시지 대신 커스텀 콘텐츠
  final Widget? content;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = '확인',
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.confirmVariant = ButtonVariant.green,
    this.cancelVariant = ButtonVariant.dark,
    this.showBack = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ModalOverlay(
      dismissible: false,
      child: Container(
        width: AppDimensions.modalCardWidth,
        height: AppDimensions.modalCardHeight,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: Stack(
          children: [
            // ── 메인 콘텐츠 (중앙 정렬) ──
            Positioned.fill(
              child: Column(
                children: [
                  // 제목 영역
                  // Figma: x=224, y=30, w=521, h=50
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 521,
                    child: Text(
                      title,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.textBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // 메시지 또는 커스텀 콘텐츠
                  if (content != null)
                    content!
                  else if (message != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Text(
                        message!,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const Spacer(),

                  // 버튼 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cancelLabel != null) ...[
                        AppButton(
                          label: cancelLabel!,
                          variant: cancelVariant,
                          size: ButtonSize.medium,
                          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                        ),
                        const SizedBox(width: 20),
                      ],
                      AppButton(
                        label: confirmLabel,
                        variant: confirmVariant,
                        size: ButtonSize.medium,
                        onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),

                  // Figma: 버튼 하단 여백 ~72px
                  const SizedBox(height: 72),
                ],
              ),
            ),

            // ── 뒤로가기 아이콘 (선택적) ──
            // Figma: icon_back x=29, y=32, 39×39
            if (showBack)
              Positioned(
                left: 29,
                top: 32,
                child: GestureDetector(
                  onTap: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 39,
                    color: AppColors.textBlack,
                  ),
                ),
              ),

            // ── 닫기 아이콘 ──
            // Figma: icon_close x=890, y=24, 48×48
            Positioned(
              right: 32, // 970 - 890 - 48 = 32
              top: 24,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close,
                  size: 48,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
