import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/metric_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.bestQuizScore,
    required this.favoriteCount,
    required this.destinationCount,
    super.key,
  });

  final int bestQuizScore;
  final int favoriteCount;
  final int destinationCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.star_fill,
            label: 'Best Quiz',
            value: '$bestQuizScore',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.heart_fill,
            label: 'Tersimpan',
            value: '$favoriteCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.map_pin_ellipse,
            label: 'Places',
            value: '$destinationCount',
          ),
        ),
      ],
    );
  }
}
