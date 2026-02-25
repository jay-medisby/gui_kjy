import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';
import 'modal_overlay.dart';
import 'app_button.dart';

/// 확인/취소 다이얼로그 (모두 970×544 통일, 다크 테마)
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

  /// 메시지 대신 커스텀 콘텐츠
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
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const Spacer(),

                  // 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      title,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.textWhite,
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
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (content != null || message != null) const Spacer(),

                  // 버튼
                  _buildButtons(context),

                  const Spacer(),
                ],
              ),
            ),

            if (showBack)
              Positioned(
                left: 29,
                top: 32,
                child: GestureDetector(
                  onTap: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 39,
                    color: AppColors.textWhite,
                  ),
                ),
              ),

            Positioned(
              right: 24,
              top: 24,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cancelLabel != null) ...[
          AppButton(
            label: cancelLabel!,
            variant: cancelVariant,
            size: ButtonSize.dialog,
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
    );
  }
}
