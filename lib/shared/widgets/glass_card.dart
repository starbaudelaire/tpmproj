import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.blur = 24,
    this.opacity = 0.08,
    this.borderRadius = AppSpacing.cardRadius,
    this.borderColor = AppColors.glassBorder,
    this.padding = const EdgeInsets.all(AppSpacing.spaceSM),
    this.width,
    this.height,
    this.color,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: (color ?? CupertinoColors.white).withValues(alpha: opacity),
            borderRadius: radius,
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24,
                spreadRadius: -4,
                color: Color(0x73000000),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00FFFFFF),
                        AppColors.glassHighlight,
                        Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
