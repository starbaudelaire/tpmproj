import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/metric_card.dart';

class QuickGuideRow extends StatelessWidget {
  const QuickGuideRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.money_dollar_circle,
            label: 'Kurs',
            value: 'IDR',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.time,
            label: 'Waktu',
            value: 'WIB (+7)',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.map,
            label: 'Offline',
            value: 'Ready',
          ),
        ),
      ],
    );
  }
}
