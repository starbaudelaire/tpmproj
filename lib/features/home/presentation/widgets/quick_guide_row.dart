import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/metric_card.dart';

class QuickGuideRow extends StatelessWidget {
  const QuickGuideRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.search,
                label: 'Cari',
                value: 'Global',
                onTap: () => context.push(RouteNames.globalSearch),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.money_dollar_circle,
                label: 'Kurs',
                value: 'IDR',
                onTap: () => context.push(RouteNames.converter),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.time,
                label: 'Waktu',
                value: 'WIB',
                onTap: () => context.push(RouteNames.converter),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.waveform_path_ecg,
                label: 'Sensor',
                value: 'Shake',
                onTap: () => context.push(RouteNames.sensor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.sparkles,
                label: 'Guide AI',
                value: 'Tanya',
                onTap: () => context.go(RouteNames.guide),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.gamecontroller_fill,
                label: 'Kuis',
                value: 'Budaya',
                onTap: () => context.push(RouteNames.game),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
