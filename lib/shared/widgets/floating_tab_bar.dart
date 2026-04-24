import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (icon: CupertinoIcons.home, label: 'Home'),
      (icon: CupertinoIcons.compass, label: 'Explore'),
      (icon: CupertinoIcons.chat_bubble_2, label: 'Guide'),
      (icon: CupertinoIcons.person, label: 'Profile'),
      (icon: CupertinoIcons.dot_radiowaves_left_right, label: 'Sensor'),
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 420.0;
            final barWidth = availableWidth.clamp(280.0, 420.0);
            final showLabels = barWidth >= 360;

            return GlassCard(
              width: barWidth,
              height: 64,
              borderRadius: AppSpacing.tabBarRadius,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(items.length, (index) {
                  final active = currentIndex == index;
                  return Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (!kIsWeb) {
                          HapticFeedback.selectionClick();
                        }
                        onTap(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: showLabels ? 10 : 6,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accentPrimary.withValues(alpha: 0.18)
                              : null,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.pillRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: active ? 1.05 : 1,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                items[index].icon,
                                color: AppColors.textPrimary.withValues(
                                  alpha: active ? 1 : 0.4,
                                ),
                                size: 20,
                              ),
                            ),
                            if (active && showLabels) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  items[index].label,
                                  style: AppTypography.captionSmall11,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
