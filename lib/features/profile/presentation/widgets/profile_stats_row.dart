import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/metric_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.star_fill,
            label: 'Best Quiz',
            value: '80',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.location_solid,
            label: 'Visited',
            value: '12',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.heart_fill,
            label: 'Saved',
            value: '4',
          ),
        ),
      ],
    );
  }
}
