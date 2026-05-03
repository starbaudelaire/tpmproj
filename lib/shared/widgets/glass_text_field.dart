import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    required this.controller,
    required this.placeholder,
    super.key,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppSpacing.cardRadius,
      color: AppColors.backgroundSecondary,
      opacity: 0.45,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.textRegular17,
              placeholder: placeholder,
              placeholderStyle: AppTypography.textRegular17.copyWith(
                color: AppColors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
