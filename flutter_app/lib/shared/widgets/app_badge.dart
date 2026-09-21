import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppBadgeVariant { success, warning, danger, neutral, primary }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;

    switch (variant) {
      case AppBadgeVariant.success:
        bg = AppColors.success50;
        text = AppColors.success700;
        border = AppColors.success200;
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.warning50;
        text = AppColors.warning700;
        border = AppColors.warning200;
        break;
      case AppBadgeVariant.danger:
        bg = AppColors.danger50;
        text = AppColors.danger700;
        border = AppColors.danger200;
        break;
      case AppBadgeVariant.primary:
        bg = AppColors.primary50;
        text = AppColors.primary700;
        border = AppColors.primary200;
        break;
      case AppBadgeVariant.neutral:
        bg = AppColors.neutral100;
        text = AppColors.neutral700;
        border = AppColors.neutral200;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
