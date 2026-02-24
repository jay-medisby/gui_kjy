import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/dimensions.dart';

/// 버튼 색상 variant
enum ButtonVariant { green, blue, red, dark }

/// 버튼 크기
/// Figma 실측:
///   large  — 516×91, borderRadius 10, padding 10×30 (액션 버튼)
///   medium — 218×70, borderRadius 35, padding 10   (모달 확인 버튼)
///   small  — 170×60, borderRadius 35, padding 10   (미니 버튼)
enum ButtonSize { large, medium, small }

/// 공통 버튼 위젯
/// 모든 화면에서 재사용: 액션 버튼, 모달 확인, 일시정지 등
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool enabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.green,
    this.size = ButtonSize.medium,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _sizeConfig;
    final colors = _colorConfig;

    final bgColor = enabled ? colors.background : colors.background.withValues(alpha: 0.4);
    final fgColor = enabled ? colors.foreground : colors.foreground.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: config.width,
        height: config.height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
          border: colors.borderColor != null
              ? Border.all(color: colors.borderColor!, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fgColor, size: config.iconSize),
              const SizedBox(width: AppDimensions.gapMedium),
            ],
            Text(
              label,
              style: config.textStyle.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }

  _SizeConfig get _sizeConfig {
    switch (size) {
      case ButtonSize.large:
        return _SizeConfig(
          width: AppDimensions.actionButtonWidth,
          height: AppDimensions.actionButtonHeight,
          borderRadius: AppDimensions.buttonRadius,
          textStyle: AppTextStyles.titleLarge,
          iconSize: 32,
        );
      case ButtonSize.medium:
        return _SizeConfig(
          width: AppDimensions.modalButtonWidth,
          height: AppDimensions.modalButtonHeight,
          borderRadius: AppDimensions.buttonRadiusLarge,
          textStyle: AppTextStyles.headingMedium,
          iconSize: 24,
        );
      case ButtonSize.small:
        return _SizeConfig(
          width: 170,
          height: 60,
          borderRadius: AppDimensions.buttonRadiusLarge,
          textStyle: AppTextStyles.bodyLarge,
          iconSize: 20,
        );
    }
  }

  _ColorConfig get _colorConfig {
    switch (variant) {
      case ButtonVariant.green:
        // Figma: #10B981 fill, #10B981 stroke
        return _ColorConfig(
          background: AppColors.green,
          foreground: AppColors.textWhite,
          borderColor: AppColors.borderGreen,
        );
      case ButtonVariant.blue:
        // Figma: #3B82F6 fill
        return _ColorConfig(
          background: AppColors.blue,
          foreground: AppColors.textWhite,
        );
      case ButtonVariant.red:
        // Figma: #FF6D6D fill
        return _ColorConfig(
          background: AppColors.red,
          foreground: AppColors.textWhite,
        );
      case ButtonVariant.dark:
        // Figma: #262626 fill, #FFFFFF stroke 1px
        return _ColorConfig(
          background: const Color(0xFF262626),
          foreground: AppColors.textWhite,
          borderColor: AppColors.textWhite,
        );
    }
  }
}

class _SizeConfig {
  final double width;
  final double height;
  final double borderRadius;
  final TextStyle textStyle;
  final double iconSize;

  const _SizeConfig({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.textStyle,
    required this.iconSize,
  });
}

class _ColorConfig {
  final Color background;
  final Color foreground;
  final Color? borderColor;

  const _ColorConfig({
    required this.background,
    required this.foreground,
    this.borderColor,
  });
}
