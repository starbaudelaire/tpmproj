import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/metric_card.dart';

class SensorFeatureCard extends StatelessWidget {
  const SensorFeatureCard({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MetricCard(icon: icon, label: label, value: value);
  }
}
