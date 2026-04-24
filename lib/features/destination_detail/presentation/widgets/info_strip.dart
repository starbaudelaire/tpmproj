import 'package:flutter/cupertino.dart';

import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/metric_card.dart';

class InfoStrip extends StatelessWidget {
  const InfoStrip({required this.destination, super.key});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.clock,
            label: 'Open',
            value: destination.openHours,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.money_dollar,
            label: 'Tiket',
            value: destination.ticketPrice,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: MetricCard(
            icon: CupertinoIcons.location_solid,
            label: 'Durasi',
            value: '2-3 jam',
          ),
        ),
      ],
    );
  }
}
