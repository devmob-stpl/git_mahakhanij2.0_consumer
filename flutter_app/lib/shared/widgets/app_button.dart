import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }
enum AppButtonSize { sm, md, lg, small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final double? width;
  final bool fullWidth;
  final AppButtonSize? size;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 48,
    this.width,
    this.fullWidth = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (onPressed == null && !isLoading) return AppColors.neutral200;
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary700;
        case AppButtonVariant.secondary:
          return AppColors.primary50;
        case AppButtonVariant.outline:
          return Colors.transparent;
        case AppButtonVariant.danger:
          return AppColors.danger600;
      }
    }

    Color getForegroundColor() {
      if (onPressed == null && !isLoading) return AppColors.inkMuted;
      switch (variant) {
        case AppButtonVariant.primary:
        case AppButtonVariant.danger:
          return AppColors.neutral0;
        case AppButtonVariant.secondary:
        case AppButtonVariant.outline:
          return AppColors.primary700;
      }
    }

    BorderSide? getBorderSide() {
      if (variant == AppButtonVariant.outline) {
        return BorderSide(
          color: onPressed == null ? AppColors.neutral300 : AppColors.lineStrong,
          width: 1.5,
        );
      }
      return BorderSide.none;
    }

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getForegroundColor(),
          elevation: 0,
          side: getBorderSide(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(getForegroundColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: getForegroundColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
