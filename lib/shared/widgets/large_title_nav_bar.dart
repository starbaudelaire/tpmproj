import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LargeTitleNavBar extends SliverPersistentHeaderDelegate {
  LargeTitleNavBar({required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 96;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final fontSize = lerpDouble(34, 17, progress)!;
    return Container(
      color: AppColors.backgroundPrimary.withOpacity(progress * 0.92),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.displayBold34.copyWith(fontSize: fontSize),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant LargeTitleNavBar oldDelegate) {
    return oldDelegate.title != title || oldDelegate.actions != actions;
  }
}
