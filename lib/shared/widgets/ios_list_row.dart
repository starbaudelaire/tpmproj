import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class IosListRow extends StatelessWidget {
  const IosListRow({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        destructive ? CupertinoColors.systemRed : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textRegular17.copyWith(
                      color: titleColor,
                      fontWeight: destructive ? FontWeight.w600 : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.textRegular13.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  destructive
                      ? CupertinoIcons.square_arrow_right
                      : CupertinoIcons.chevron_right,
                  color: destructive
                      ? CupertinoColors.systemRed
                      : AppColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}
